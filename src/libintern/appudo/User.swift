/*
    User.swift is part of Appudo

    Copyright (C) 2015-2016
        f0c0606326222203d218d2cb3a3b46af3d6022c5a5ea9ae11d8100d62327f03a source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo
import libappudo_bridge

public func AsyncObj_SetUserId(_ async : UnsafeRawPointer, _ id : CInt) -> Void {
    let v = Unmanaged<Async>.fromOpaque(async)
    var a = v.takeUnretainedValue() as! _AsyncStruct<User>

    PrivateInterface.User_SetId(&a, id)
}

public func AsyncObj_SetUserActive(_ async : UnsafeRawPointer, _ active : CInt) -> Void {
    let v = Unmanaged<Async>.fromOpaque(async)
    var a = v.takeUnretainedValue() as! _AsyncStruct<User>

    PrivateInterface.User_SetActive(&a, active == 1)
}

public func AsyncObj_SetUserName(_ async : UnsafeRawPointer, _ ptr : UnsafePointer<Int8>, _ len : CLong) -> Void {
    let v = Unmanaged<Async>.fromOpaque(async)
    var a = v.takeUnretainedValue() as! _AsyncStruct<User>

    PrivateInterface.User_SetName(&a, fromUTF8_nocheck(ptr, len))
}

public func AsyncObj_SetUserInfo(_ async : UnsafeRawPointer, _ uid : CInt, _ gid : CInt) -> Void {
    let v = Unmanaged<Async>.fromOpaque(async)
    let a = v.takeUnretainedValue() as! _AsyncStruct<UserInfo>

    a._value = PrivateInterface.User_GetUserInfo(uid:UserID(uid),gid:GroupID(gid))
}

public struct UserItemInfo {
    var itemSize : CInt
    var fullSize : CInt
    var nameOffset : CInt
}

public func AsyncObj_CreateSetUserList(_ async : UnsafeRawPointer, _ numUser : Int, _ numGroup : Int, _ info : UnsafeMutablePointer<UserItemInfo>) -> UnsafeMutablePointer<_UserListItem>  {
    let count = MemoryLayout<_UserListItem>.stride / MemoryLayout<CInt>.stride
    let v = Unmanaged<Async>.fromOpaque(async)
    let a = v.takeUnretainedValue() as! _AsyncStruct<UserList>
    let num = numUser * count + numGroup
    let l = _UserList.create(num)
    l._value.pointee = UserListValue(_data:nil, _size:num, _index:0)
    a._value = l
    info.pointee.itemSize = CInt(MemoryLayout<_UserListItem>.stride)
    info.pointee.fullSize = CInt(num * MemoryLayout<CInt>.stride)
    return UnsafeMutableRawPointer(mutating:l._items).assumingMemoryBound(to:_UserListItem.self);
}

public struct UserListValue {
    public var _data : UnsafeRawPointer? = nil
    public var _size : Int = 0
    public var _index : Int = 0
}

public struct UserSortHolder {
    let owner : CInt
    let info : CInt
    let chunkLimit : CInt
    let sorter : _UserListItem.Sorter?
}

public func User_SortList(_ a : UnsafePointer<_UserListItem>, _ b : UnsafePointer<_UserListItem>, _ sorter : UnsafePointer<UserSortHolder>) -> Int32  {
    return sorter.pointee.sorter!(a.pointee, b.pointee)
}

public class _UserList : UserList {

    deinit {
        _buffer.withUnsafeMutablePointerToHeader {
            if($0.pointee._data != nil) {
                User_DestroyList($0.pointee._data!)
            }
            var index = 0
            while(index != $0.pointee._size) {
                nextItem(&index).deinitialize(count:1)
            }
            $0.deinitialize()
        }
    }

    static func create(_ size:Int) -> _UserList {
        let p = ManagedBufferPointer<UserListValue, CInt>(
            bufferClass: self,
            minimumCapacity: size,
            makingHeaderWith: { buffer, _ in
                return UserListValue()
            })

          return unsafeDowncast(p.buffer, to:self)
    }

    var _buffer : ManagedBufferPointer<UserListValue, CInt> {
        get {
            return ManagedBufferPointer<UserListValue, CInt>(unsafeBufferObject:self)
        }
    }

    var _items : UnsafeMutablePointer<CInt> {
        get {
            return _buffer.withUnsafeMutablePointerToElements {
                return $0
            }
        }
    }

    var _value : UnsafeMutablePointer<UserListValue> {
        get {
            return _buffer.withUnsafeMutablePointerToHeader {
                return $0
            }
        }
    }

    func nextItem(_ current : inout Int) -> UnsafeMutablePointer<_UserListItem> {
        return _buffer.withUnsafeMutablePointerToElements {
            let ptr = $0.advanced(by:current)
            let res = UnsafeMutableRawPointer(mutating:ptr).assumingMemoryBound(to:_UserListItem.self)
            let size = MemoryLayout<_UserListItem>.stride / MemoryLayout<CInt>.stride
            var count = 0
            if(res.pointee.groups) {
                let groups = UnsafePointer<CInt>(ptr.advanced(by:size))
                count += Int(groups[0]) + 1
            }
            current += size + count
            return res
        }
    }

    override public func next() -> UserListItem?
    {
        if(_value.pointee._index == endIndex) {
            return nil
        }
        return _buffer.withUnsafeMutablePointers {
            let ptr = $1.advanced(by:$0.pointee._index)
            let res = UnsafeMutableRawPointer(mutating:ptr).assumingMemoryBound(to:_UserListItem.self)
            let size = MemoryLayout<_UserListItem>.stride / MemoryLayout<CInt>.stride
            var count = 0
            var groups : UnsafePointer<CInt>? = nil
            if(res.pointee.groups) {
                groups = UnsafePointer<CInt>(ptr.advanced(by:size))
                count += Int(groups![0]) + 1
            }
            $0.pointee._index += size + count
            return UserListItem(self, groups, Int32(res.pointee.id), res.pointee.name, res.pointee.active)
        }
    }

    override public func nextList(_ sorter:_UserListItem.Sorter?, _ chunkLimit:Int32) -> AsyncValue<UserList?> {
        var ret = AsyncValue<UserList?>(nil)
        if(_value.pointee._data != nil) {
            struct ArgPad {
                var owner : CInt
                var info : CInt
                var chunkLimit : CInt
                var sorter : _UserListItem.Sorter?
            }
            var pad : ArgPad = ArgPad(owner:-1, info:(sorter != nil ? 4 : 0), chunkLimit:chunkLimit, sorter:sorter)
            ret.store(&pad)
            User_CreateList(&ret, &pad, _value.pointee._data!)
            _value.pointee._data = nil
        }
        return ret
    }

    override public var startIndex: Int {
        get {
            return 0
        }
    }

    override public var endIndex: Int {
        get {
            return _value.pointee._size
        }
    }
}
