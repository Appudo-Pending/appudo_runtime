/*
    Blob.swift is part of Appudo

    Copyright (C) 2015-2016
        ae3453f1d271c32860dc06afd71f3918e396ff5139052cd38c33f6c4fafc98a4 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge

/**
A Blob is the read only representation of raw data used by other APIs to hand over data.
*/
public protocol Blob {
    /**
    Create a new Blob as a segment of the parent.

    - parameter offset: The offset into the parent to start with.
    - parameter size: The size of the new Blob used from the parent.
    */
    func slice(_ offset : Int, _ size: Int) -> AsyncClass<Blob>
}

struct DataBlobInternal {
    let _size : Int = 0
}

/**
A DataBlob is used to hand over binary data to other APIs. The websocket run accepts data blobs to send bytes.
*/
public final class DataBlob : Blob, DataWriteSource {
    /**
    Create a new DataBlob.

    - parameter size: The size of the new Blob.
    */
    static func  create(_ size:Int) -> DataBlob {
        let p = ManagedBufferPointer<DataBlobInternal, UInt8>(
        bufferClass: self,
        minimumCapacity: size,
        makingHeaderWith: { buffer, _ in
            DataBlobInternal()
        })

        return unsafeDowncast(p.buffer, to: DataBlob.self)
    }

    public func getData(_ offset : Int, _ maxSize : Int, _ info : inout DataView) -> UnsafePointer<Int8>? {
        // TODO
        return nil
    }

    /**
    Create a new Blob as a segment of the parent.

    - parameter offset: The offset into the parent to start with.
    - parameter size: The size of the new Blob used from the parent.
    */
    public func slice(_ offset : Int, _ size: Int = 0) -> AsyncClass<Blob> {
        var ret = AsyncClass<Blob>(nil)
        // TODO
        return ret
    }
}
