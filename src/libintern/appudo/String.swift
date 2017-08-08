/*
    String.swift is part of Appudo

    Copyright (C) 2015-2016
        1c411a37ab0d1e379627bbabc5b769a16c007a555ab1a667a84653a4c546f1a1 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo
import libappudo_bridge

public func String_SetOptValue(result : UnsafeMutablePointer<String?>, _ ptr : UnsafePointer<Int8>, _ len : CLong) -> Void {
    result.pointee = fromUTF8_nocheck(ptr, len)
}

public func String_SetUninitializedValue(result : UnsafeMutablePointer<String>, _ ptr : UnsafePointer<Int8>, _ len : CLong) -> Void {
    result.initialize(to:fromUTF8_nocheck(ptr, len))
}

public func Async_SetString(async : UnsafeMutablePointer<AsyncValue<String?>>, _ ptr : UnsafePointer<Int8>?, _ len : CLong, _ holder : UnsafeMutablePointer<AnyObject?>?) -> UnsafePointer<Int8>? {
    if(ptr == nil) {
        async.pointee.rawValue = nil
        if(holder != nil) {
            holder!.pointee = nil
        }
        return nil
    } else {
        let s = fromUTF8_nocheck(ptr!, len)
        async.pointee.rawValue = s
        if(holder != nil) {
            return AsyncArg.save(s, &holder!.pointee)
        }
        return nil
    }
}

public func Async_SetStringBuffer(async : UnsafeMutablePointer<AsyncValue<String?>>, _ buffer : UnsafeMutablePointer<ContiguousArray<UInt8>>) -> Void {
    async.pointee.rawValue = String._fromCodeUnitSequence(UTF8.self, input: buffer.pointee)
    buffer.deinitialize()
}

public func Async_SetArrayBuffer(async : UnsafeMutablePointer<AsyncValue<ContiguousArray<UInt8>?>>, _ buffer : UnsafeMutablePointer<ContiguousArray<UInt8>>) -> Void {
    async.pointee.rawValue = buffer.pointee
    buffer.deinitialize()
}

public func String_CreateArrayBuffer(result : UnsafeMutablePointer<ContiguousArray<UInt8>>, _ len : CLong) -> UnsafeMutablePointer<UInt8> {
    var buffer = ContiguousArray<UInt8>(repeating:0, count:0)
    buffer.reserveCapacity(Int(len));
    Array_SetCount(&buffer, Int(len))
    result.initialize(to:buffer)
    return result.pointee.withUnsafeMutableBufferPointer {
        return $0.baseAddress!
    }
}
