/*
    FileItem_Private.swift is part of Appudo

    Copyright (C) 2015-2016
        ae3453f1d271c32860dc06afd71f3918e396ff5139052cd38c33f6c4fafc98a4 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge

public extension PrivateInterface {
    public static func getFileItem(_ path : _FilePath) -> FileItem {
        return FileItem(path)
    }
    public static func getFileStat(_ info : UnsafeRawPointer) -> FileStat {
        return FileStat(info.assumingMemoryBound(to:FileItemInfo.self).pointee)
    }
}

public struct FileViewInfo {
    public var _offset : Int
    public var _size : Int
    public var _source : CInt
    public init(_ source : FileSendSource, offset : Int = 0, size : Int = Int.max) {
        _offset = offset
        _size = size
        _source = source.fileFd
    }

    public init(_ view : FileView) {
        _offset = view._offset
        _size = view._size
        _source = view._source.fileFd
    }

}

public struct DataView {
    public var _offset : Int
    public var _size : Int
    public var _source : DataWriteSource
    public var _data : AnyObject?
    public var _ptr : UnsafePointer<Int8>?
    public init(_ source : DataWriteSource) {
        _offset = 0
        _size = Int.max
        _source = source
        _data = nil
        _ptr = nil
    }
}

public protocol _FilePath {
    var parent : _FilePath? { get }
    var name_data : UnsafePointer<Int8> { get }
    var name : String { get }
    var full : String { get }
    var fileFd : CInt { get set }
    var type : CInt { get }
    var data : CLong { get }
    var isOpen : Bool { get }
    func _close() -> Void
    func listDir(_ order:FileItem.Sorter?, _ chunkLimit:Int32) -> AsyncClass<FileItemList>
}

public struct _UTF8SerialFileReader : Collection {
    private let _fileFd : CInt
    private var _offset : Int
    private var _size : Int
    private var _tmp : ContiguousArray<UTF8.CodeUnit>
    public init(_ fileFd : CInt, _ offset : Int, _ size : Int) {
        let capacity = size > 4096 ? 4096 : size;
        _fileFd = fileFd
        _tmp = ContiguousArray<UTF8.CodeUnit>(repeating:0, count:0)
        _tmp.reserveCapacity(capacity)
        Array_SetCount(&_tmp, capacity)
        _offset = offset
        _size = size
    }

    public var startIndex: Int { get { return 0 } }
    public var endIndex: Int { get { return _size } }

    public func index(after: Int) -> Int {
        return after + 1
    }

    private func readFile(_ index : Int) -> Void {
        let ptr = _tmp.withUnsafeBufferPointer {
            return $0.baseAddress!
        }
        let _ptr = UnsafeMutableRawPointer(mutating:ptr).assumingMemoryBound(to:Int8.self)
        FileItem_PREAD(_fileFd, _ptr, _size - index, _offset + index)
    }

    public subscript(i:Int) -> UTF8.CodeUnit {
        let index = i % 4096
        if(index == 0) {
            readFile(i)
        }
        return _tmp[index]
    }
}
