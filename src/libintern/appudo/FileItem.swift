/*
    FileItem.swift is part of Appudo

    Copyright (C) 2015-2016
        ae3453f1d271c32860dc06afd71f3918e396ff5139052cd38c33f6c4fafc98a4 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo
import libappudo_bridge

extension ContiguousArray : DataWriteSource {
    public func getData(_ offset : Int, _ maxSize : Int, _ info : inout DataView) -> UnsafePointer<Int8>? {
        return withUnsafeBufferPointer {
            let realSize = offset < count ? count - offset : 0
            info._size = realSize < maxSize ? realSize : maxSize

            let base = UnsafeRawPointer($0.baseAddress!).assumingMemoryBound(to:Int8.self)
            let r : UnsafePointer<Int8>? = base.advanced(by:offset)
            let start = realSize != 0 ? r : nil as UnsafePointer<Int8>?
            info._offset = offset
            return start
        }
    }
}

extension ManagedCharBuffer : DataWriteSource {
    public func getData(_ offset : Int, _ maxSize : Int, _ info : inout DataView) -> UnsafePointer<Int8>? {
        let d = data
        let realSize = offset < d.size ? d.size - offset : 0
        info._size = realSize < maxSize ? realSize : maxSize

        let base = UnsafeRawPointer(firstElementAddress).assumingMemoryBound(to:Int8.self)
        let r : UnsafePointer<Int8>? = base.advanced(by:offset)
        let start = realSize != 0 ? r : nil as UnsafePointer<Int8>?
        info._offset = offset
        return start
    }
}

extension String : DataWriteSource {
    public func getData(_ offset : Int, _ maxSize : Int, _ info : inout DataView) -> UnsafePointer<Int8>? {
        let realSize = offset < utf8.count ? utf8.count - offset : 0
        info._size = realSize < maxSize ? realSize : maxSize

        var ptr = info._ptr

        if(info._data == nil) {
            let a : (AnyObject?, UnsafePointer<Int8>) = _convertConstStringToUTF8PointerArgument(self)
            info._data = a.0
            ptr = a.1
            info._ptr = a.1
        }

        let base = ptr!
        let r : UnsafePointer<Int8>? = base.advanced(by:offset)
        let start = realSize != 0 ? r : nil as UnsafePointer<Int8>?
        info._offset = offset
        return start
    }
}

private protocol _FilePathInternal : _FilePath {
    var name_data : UnsafePointer<Int8> { get }
    var _len : Int { get }
}

private struct _FullPathData {
    var next : UnsafeMutablePointer<_FullPathData>
    var name : UnsafePointer<Int8>
    var len : CShort
    init(_ nx : UnsafeMutablePointer<_FullPathData>, _ nm : UnsafePointer<Int8>, _ ln : CShort) {
        next = nx
        name = nm
        len = ln
    }

    static func null() -> UnsafeMutablePointer<_FullPathData> {
        return UnsafeMutablePointer<_FullPathData>(OpaquePointer(bitPattern:1)!)
    }
}

private func getFullPath(_ result : inout String?, _ item : _FilePathInternal, _ next : UnsafeMutablePointer<_FullPathData>) -> Void {
    var current : _FullPathData = _FullPathData(next, item.name_data, CShort(item._len))
    if(item.parent != nil) {
        getFullPath(&result, item.parent as! _FilePathInternal, &current)
    } else {
        FileItem_GetFullPath(&result, &current)
    }
}

public struct _FilePathBase {
    var _parent : _FilePath?
    var _len : Int
    var _fileFd : CInt
    init(_ parent : _FilePath?, _ len : Int) {
        _parent = parent
        _len = len
        _fileFd = -1
    }
}

public final class UnlinkedFilePath : _FilePathInternal {
    var _fileFd : CInt = -1

    init(_ fileFd : CInt) {
        _fileFd = fileFd
    }

    deinit {
        _close()
    }

    public func _close() -> Void {
        if(_fileFd != -1) {
            FileItem_CloseFile(_fileFd)
            _fileFd = -1
        }
    }

    var _len : Int {
        return 0
    }

    public var isOpen : Bool {
        return fileFd != -1
    }

    public var type : CInt {
        return 1
    }

    public var data : CLong {
        return CLong(fileFd)
    }

    public var fileFd : CInt {
        get {
            return _fileFd
        }
        set{
        }
    }

    public func listDir(_ sorter:FileItem.Sorter?, _ chunkLimit:Int32) -> AsyncValue<FileItemList?> {
        return AsyncValue<FileItemList?>(nil)
    }

    public var name_data : UnsafePointer<Int8> {
        return UnsafePointer<Int8>(OpaquePointer(bitPattern:1))!
    }

    public var parent : _FilePath? {
        return nil
    }

    public var name : String {
        return ""
    }

    public var full : String {
        return ""
    }
}

public final class DeviceFilePath : _FilePathInternal {
    var _moduleId : Int
    var _type : CInt
    init(_ type : CInt, _ moduleId : Int) {
        if(type > 2) {
            _type = type
            _moduleId = moduleId
        } else {
            _type = -1
            _moduleId = -1
        }
    }

    public static func createPath(_ type : CInt, _ moduleId : CLong) -> DeviceFilePath {
        return DeviceFilePath(type, moduleId)
    }

    public var name_data : UnsafePointer<Int8> {
        return String_empty()
    }

    public func _close() -> Void {
    }

    public var _len : Int {
        return 0
    }

    public var isOpen : Bool {
        return true
    }

    public var type : CInt {
        return _type
    }

    public var data : CLong {
        return _moduleId;
    }

    public var fileFd : CInt {
        get {
            return -1
        }
        set{
        }
    }

    public var parent : _FilePath? {
        return nil
    }

    public var name : String {
        get {
            return "" // TODO
        }
    }

    public var full : String {
        get {
            return "" // TODO
        }
    }

    public func listDir(_ sorter:FileItem.Sorter?, _ chunkLimit:Int32) -> AsyncValue<FileItemList?> {
        return AsyncValue<FileItemList?>(nil)
    }
}

public final class DynamicFilePath : ManagedBuffer<_FilePathBase, Int8>, _FilePathInternal {

    public static func createPath(_ parent : _FilePath?, _ ptr : UnsafePointer<Int8>, _ len : CLong) -> DynamicFilePath {
        let path = DynamicFilePath.create(minimumCapacity:Int(len+1), makingHeaderWith:{ _ in
            return _FilePathBase(parent, len)
        }) as! DynamicFilePath
        path.withUnsafeMutablePointerToElements {
            memcpy($0, ptr, len)
            $0.advanced(by:len).pointee = 0
        }
        return path
    }

    deinit {
        _close()
    }

    public func _close() -> Void {
        if(_value.pointee._fileFd != -1) {
            FileItem_CloseFile(_value.pointee._fileFd)
            _value.pointee._fileFd = -1
        }
    }

    var _len : Int {
        return _value.pointee._len
    }

    var _path : UnsafeMutablePointer<Int8> {
        return ManagedBufferPointer<_FilePathBase, Int8>(unsafeBufferObject: self).withUnsafeMutablePointerToElements { return $0 }
    }

    var _value : UnsafeMutablePointer<_FilePathBase> {
        return ManagedBufferPointer<_FilePathBase, Int8>(unsafeBufferObject: self).withUnsafeMutablePointerToHeader { return $0 }
    }

    public var type : CInt {
        return 0
    }

    public var isOpen : Bool {
        return fileFd != -1
    }

    public var data : CLong {
        return CLong(fileFd)
    }

    public var fileFd : CInt {
        get {
            return _value.pointee._fileFd
        }
        set{
            _value.pointee._fileFd = newValue
        }
    }

    public var name_data : UnsafePointer<Int8> {
        return UnsafePointer<Int8>(_path)
    }

    public var parent : _FilePath? {
        return _value.pointee._parent
    }

    public var name : String {
        return fromUTF8_nocheck(name_data, Int(_len))
    }

    public var full : String {
        var result : String? = nil
        getFullPath(&result, self, _FullPathData.null())
        return result!
    }

    public func listDir(_ sorter:FileItem.Sorter?, _ chunkLimit:Int32) -> AsyncValue<FileItemList?> {
        return _FileItemList.createList(self, sorter, chunkLimit)
    }
}

struct FilePathData {
    var _len : CShort = 0
    var _path_len : CShort = 0
    var _data0 : CChar = 0
}

struct StaticFilePath : _FilePathInternal {
    let _ptr : UnsafeMutablePointer<FilePathData>
    init(_ ptr:UnsafeMutablePointer<FilePathData>) {
        _ptr = ptr
    }

    func _close() -> Void {
    }

    var _len : Int {
        return Int(_ptr.pointee._len)
    }

    public var type : CInt {
        return 2
    }

    public var isOpen : Bool {
        return false
    }

    public var data : CLong {
        return CLong(fileFd)
    }

    var fileFd : CInt {
        get {
            return -1
        }
        set{
        }
    }

    var name_data : UnsafePointer<Int8> {
        return withUnsafePointer(to:&_ptr.pointee._data0) { return $0 }
    }

    var parent : _FilePath? {
        return nil
    }

    var name : String {
        let path_len = Int(_ptr.pointee._path_len)
        return fromUTF8_nocheck(name_data.advanced(by:path_len), Int(_len - path_len))
    }

    var full : String {
        var result : String? = nil
        getFullPath(&result, self, _FullPathData.null())
        return result!
    }

    func listDir(_ sorter:FileItem.Sorter?, _ chunkLimit:Int32) -> AsyncValue<FileItemList?> {
        return _FileItemList.createList(self, sorter, chunkLimit)
    }
}

public struct FileItemListValue {
    public var _data : UnsafeRawPointer? = nil
    public var _size : Int = 0
    public var _index : Int = 0
}

private func AddPath(_ name : UnsafePointer<CChar>, _ len : Int, _ parent : _FilePath? = nil) -> DynamicFilePath
{
    return DynamicFilePath.createPath(parent, name, len)
}

private func AddDevicePath(_ type : CInt, _ moduleId : Int) -> DeviceFilePath
{
    return DeviceFilePath.createPath(type, moduleId)
}

public struct PathHolder {
    var _path : _FilePath
    var _sorter : FileItem.Sorter?
    init(_ path : _FilePath, _ sorter:FileItem.Sorter?) {
        _path = path
        _sorter = sorter
    }
}

public func Async_SetFileStat(async : UnsafeMutablePointer<AsyncValue<FileStat?>>, _ info : UnsafeRawPointer) -> Void {
    async.pointee.rawValue = PrivateInterface.getFileStat(info)
}

public func Async_SetFileList(_ async : UnsafeMutablePointer<AsyncValue<_FileItemList?>>, _ size:CInt, _ data:UnsafeRawPointer, _ elemets:UnsafeMutablePointer<UnsafeMutablePointer<DynamicFilePath>>) -> UnsafeMutableRawPointer {
    let l = _FileItemList.create(Int(size))
    let v = l._value
    v.pointee._data = data
    elemets.pointee = l._items
    async.pointee.rawValue = l
    return Unmanaged.passUnretained(l).toOpaque()
}

public func FileItem_AddPath(_ list : UnsafeRawPointer, _ parent : UnsafePointer<PathHolder>, _ ptr : UnsafePointer<Int8>, _ len : CLong) -> Void  {
    let l = Unmanaged<_FileItemList>.fromOpaque(list).takeUnretainedValue()
    let v = l._value
    let pos = UnsafeMutablePointer<DynamicFilePath>(l._items).advanced(by:l.endIndex)
    pos.initialize(to:AddPath(ptr, len, parent.pointee._path))
    v.pointee._size += 1
}

public func Async_SetPath(_ parent : UnsafeMutablePointer<PathHolder>, _ ptr : UnsafePointer<Int8>, _ len : CLong) -> Void  {
    let p = AddPath(ptr, len, parent.pointee._path)
    parent.pointee._path = p
}

public func Async_SetFileItem(async : UnsafeMutablePointer<AsyncValue<FileItem?>>?, _ parent : UnsafeMutablePointer<PathHolder>, _ fileFd : CInt) -> Void  {
    var p = parent.pointee._path
    if let a = async {
        let f = PrivateInterface.getFileItem(p)
        a.pointee.rawValue = f
        a.pointee.errorValue = AppudoError.None
    }

    p._close()
    p.fileFd = fileFd
}

public func Async_SetDevicePath(async : UnsafeMutablePointer<AsyncValue<FileItem?>>, _ moduleId : CLong, _ type : CInt) -> Void  {
    let p = AddDevicePath(type, moduleId)
    async.pointee.rawValue = PrivateInterface.getFileItem(p)
}

public func AsyncObj_SetDevicePath(_ async : UnsafeRawPointer, _ moduleId : CLong, _ type : CInt) -> Void  {
    let v = Unmanaged<Async>.fromOpaque(async)
    let a = v.takeUnretainedValue() as! _AsyncStruct<FileItem>
    let p = AddDevicePath(type, moduleId)
    a.rawValue = PrivateInterface.getFileItem(p)
}


public func Async_SetEmptyPath(async : UnsafeMutablePointer<AsyncValue<FileItem?>>, _ ptr : UnsafePointer<Int8>, _ len : CLong, _ fileFd : CInt) -> Void  {
    let p = AddPath(ptr, len, nil)
    p.fileFd = fileFd
    async.pointee.rawValue = PrivateInterface.getFileItem(p)
}

public func FileItem_Sort(_ a : UnsafePointer<DynamicFilePath>, _ b : UnsafePointer<DynamicFilePath>, _ holder : UnsafePointer<PathHolder>) -> Int32  {
    return holder.pointee._sorter!(PrivateInterface.getFileItem(a.pointee), PrivateInterface.getFileItem(b.pointee))
}

public class _FileItemList : FileItemList {
    static func createList(_ path : _FilePath, _ sorter : FileItem.Sorter?, _ chunkLimit:Int32) -> AsyncValue<FileItemList?> {
        var ret = AsyncValue<FileItemList?>(nil)
        var holder = PathHolder(path, sorter)
        FileItem_CreateList(&ret, &holder, path.full, sorter == nil ? 0 : 1, Int32(chunkLimit), nil)
        return ret
    }

    deinit {
        _buffer.withUnsafeMutablePointers {
            if($0.pointee._data != nil) {
                FileItem_DestroyList($0.pointee._data!)
            }
            $1.deinitialize(count:$0.pointee._size)
            $0.deinitialize()
        }
    }

    static func create(_ size:Int) -> _FileItemList {
        let p = ManagedBufferPointer<FileItemListValue, DynamicFilePath>(
            bufferClass: self,
            minimumCapacity: size,
            makingHeaderWith: { buffer, _ in
                return FileItemListValue()
            })

          return unsafeDowncast(p.buffer, to:self)
    }

    var _buffer : ManagedBufferPointer<FileItemListValue, DynamicFilePath> {
        get {
            return ManagedBufferPointer<FileItemListValue, DynamicFilePath>(unsafeBufferObject:self)
        }
    }

    var _items : UnsafeMutablePointer<DynamicFilePath> {
        get {
            return _buffer.withUnsafeMutablePointerToElements {
                return $0
            }
        }
    }

    var _value : UnsafeMutablePointer<FileItemListValue> {
        get {
            return _buffer.withUnsafeMutablePointerToHeader {
                return $0
            }
        }
    }

    override public func next() -> FileItem?
    {
        if(_value.pointee._index == endIndex) {
            return nil
        }
        return PrivateInterface.getFileItem(_buffer.withUnsafeMutablePointers {
            let res = $1[$0.pointee._index]
            $0.pointee._index += 1
            return res
        })
    }

    override public func nextList(_ sorter:FileItem.Sorter?, _ chunkLimit:Int32) -> AsyncValue<FileItemList?> {
        var ret = AsyncValue<FileItemList?>(nil)
        if(_value.pointee._data != nil) {
            let path = _items[0].parent!
            var holder = PathHolder(path, sorter)
            FileItem_CreateList(&ret, &holder, path.full, sorter == nil ? 0 : 1, Int32(chunkLimit), _value.pointee._data!)
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

    override public subscript(i:Int) -> FileItem {
        return PrivateInterface.getFileItem(_buffer.withUnsafeMutablePointerToElements {
            return $0[i]
        })
    }
}

public func FilePath_Get(_ data : OpaquePointer) -> _FilePath
{
    return StaticFilePath(UnsafeMutablePointer<FilePathData>(data))
}

public func FileItem_WriteInfo(_ info : UnsafeMutablePointer<DataView>, _ offset : CLong, _ maxSize : CLong) -> UnsafePointer<Int8>? {
    let readable = info.pointee._source
    return readable.getData(offset, maxSize, &info.pointee)
}
