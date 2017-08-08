/*
    MenuItem.swift is part of Appudo

    Copyright (C) 2015-2016
        8c363e70b3d1ed86d1c8bf704f4c7f423ce1d6c1d0bb40f933cbd46dd4cf1304 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo
import libappudo_bridge
import libappudo_special

struct _MenuTemp {
        var entry : UnsafePointer<Int8>? =  nil
        var name : UnsafePointer<Int8>? = nil
        var lastIdx : CInt = -1
        var entryLen : CInt = 0
        var nameLen : CInt = 0
        var firstChild : CInt = 0
        var numChildren : CInt = 0
        var moduleId: CLong = 0
        var isSSL : CBool = false
        var isActive : CBool = false
        var needUpdate : CBool = false
}

struct _MenuPathBase {
}

class _DynamicMenuPath : ManagedBuffer<_MenuPathBase, _MenuData>, _MenuPath {
    subscript(index: Int) -> _MenuData {
        get {
            return items[index]
        }
    }

    var items : UnsafeMutablePointer<_MenuData> {
        get {
            return ManagedBufferPointer<_MenuPathBase, _MenuData>(unsafeBufferObject: self).withUnsafeMutablePointerToElements { return $0 }
        }
    }
}

public func Async_SetMenuItem(async : UnsafeMutablePointer<AsyncValue<MenuItem?>>, info : UnsafeMutablePointer<Int8>, _ num : CInt) -> Void {
    let data : _DynamicMenuPath = _DynamicMenuPath.create(minimumCapacity:Int(num), makingHeaderWith:{ (_) in return _MenuPathBase()}) as! _DynamicMenuPath
    var tmp = _MenuTemp()
    var i = 0

    withUnsafePointer(to:&tmp) {
        while(MenuItem_getNext(info, UnsafeMutableRawPointer(mutating:$0).assumingMemoryBound(to:UInt8.self)) != 0) {
            let ptr = data.items.advanced(by:i)
            ptr.initialize(to:PrivateInterface.getMenuData(entry:fromUTF8_nocheck(tmp.entry!, Int(tmp.entryLen)),
                                                         name:fromUTF8_nocheck(tmp.name!, Int(tmp.nameLen)),
                                                         firstChild:0,
                                                         numChildren:0,
                                                         moduleId:tmp.moduleId,
                                                         isSSL:tmp.isSSL,
                                                         isActive:tmp.isActive))
            i += 1
            if(tmp.needUpdate) {
                data.items[Int(tmp.lastIdx)]._firstChild = tmp.firstChild
                data.items[Int(tmp.lastIdx)]._numChildren = tmp.numChildren
                tmp.needUpdate = false
            }
        }
    }

    async.pointee.rawValue = PrivateInterface.getMenuItem(data)
    async.pointee.errorValue = AppudoError.None
}
