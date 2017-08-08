/*
    Error.swift is part of Appudo

    Copyright (C) 2015-2016
        4bea15c834854bf9670dc6a1cbc9a9dda7cf418ef53b8edbb11b3df946a0c45e source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge
import libappudo

public func AsyncObj_SetError(async : UnsafeRawPointer, _ value :CInt) -> Void {
    let v = Unmanaged<Async>.fromOpaque(async).takeUnretainedValue()
    v.errorValue = AppudoError(rawValue:value) ?? AppudoError.Unknown
}

public func Async_SetError(async : UnsafeMutablePointer<AsyncValue<AsyncVoid>>, _ value :CInt) -> Void {
    async.pointee.rawError = AppudoError(rawValue:value) ?? AppudoError.Unknown
}
