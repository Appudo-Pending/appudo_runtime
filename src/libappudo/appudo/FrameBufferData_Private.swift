/*
    FrameBufferData_Private.swift is part of Appudo

    Copyright (C) 2015-2016
        ae3453f1d271c32860dc06afd71f3918e396ff5139052cd38c33f6c4fafc98a4 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

public struct FrameBufferData : RandomAccessCollection {
    public typealias Indices = CountableRange<Int>

    public init(_ framePtr : UnsafeMutableRawPointer, _ size : Int) {
        _size = size
        _data = nil
        _framePtr = framePtr
    }

    public var indices : CountableRange<Int> {
        return 0..<_size
    }

    public var size : Int {
        return _size
    }

    public var endIndex : Int {
        return _size
    }

    public var startIndex : Int {
        return 0
    }
    public subscript(idx: Int) -> UTF8.CodeUnit {
        return _data!.advanced(by:idx).pointee
    }

    var _size : Int
    var _data : UnsafeMutablePointer<UInt8>?
    var _framePtr : UnsafeMutableRawPointer
}
