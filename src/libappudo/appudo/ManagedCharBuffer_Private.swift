/*
    ManagedCharBuffer_Private.swift is part of Appudo

    Copyright (C) 2015-2016
        ae3453f1d271c32860dc06afd71f3918e396ff5139052cd38c33f6c4fafc98a4 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

public struct CharBufferData : RandomAccessCollection {
    public typealias Indices = CountableRange<Int>

    public init(_ data:UnsafeMutablePointer<UInt8>, _ size : Int) {
        _size = size
        _data = data
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
        return _data.advanced(by:idx).pointee
    }

    var _size : Int
    var _data : UnsafeMutablePointer<UInt8>
}

struct _ManagedCharBufferData {
    public init(_ size : Int) {
        _size = size
    }
    var _size : Int
}

public class ManagedCharBuffer {

    private init() {
    }

    public static func  create(_ capacity:Int) -> ManagedCharBuffer {
        let p = ManagedBufferPointer<_ManagedCharBufferData, UInt8>(
        bufferClass: self,
        minimumCapacity: capacity,
        makingHeaderWith: { buffer, _ in
            _ManagedCharBufferData(capacity)
        })

        return unsafeDowncast(p.buffer, to: ManagedCharBuffer.self)
    }

    public func memset(_ c : UInt8 = 0) -> Void {
        let base = firstElementAddress
        for i in 0...data.size-1 {
            base.advanced(by:Int(i)).pointee = c
        }
    }

    public var firstElementAddress : UnsafeMutablePointer<UInt8> {
        return ManagedBufferPointer<_ManagedCharBufferData, UInt8>(unsafeBufferObject: self).withUnsafeMutablePointerToElements {
            return $0
        }
    }

    public var data : CharBufferData {
        return ManagedBufferPointer<_ManagedCharBufferData, UInt8>(unsafeBufferObject: self).withUnsafeMutablePointerToHeader {
            return CharBufferData(firstElementAddress, $0.pointee._size)
        }
    }

}
