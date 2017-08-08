/*
    Async.swift is part of Appudo

    Copyright (C) 2015-2016
        89a46e2bb720c7ec116d9e3c4c4f722938c13856d1277fd8c551db4c0c8f087e source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo
import libappudo_bridge

public func AsyncObj_Keep(async : UnsafeRawPointer) -> Void {
    let v = Unmanaged<Async>.fromOpaque(async)
    let a = v.takeUnretainedValue()
    let _ = Unmanaged<Async>.passRetained(a)
}

public func AsyncObj_Release(async : UnsafeRawPointer) -> Void {
    let v = Unmanaged<Async>.fromOpaque(async)
    let a = v.takeRetainedValue()
    a.releaseArgs()
}

public func Async_toAsync(_ async : UnsafeMutablePointer<AsyncValue<AsyncVoid>>) -> UnsafeMutablePointer<Int8>? {
    let a = async.pointee.toAsync()
    return a?.data
}

public func Async_SetIntValue(_ async : UnsafeMutablePointer<AsyncValue<Int>>, value : CLong) -> CLong {
    let v = async.pointee.internalInt
    async.pointee.rawValue = value
    return v
}

public func Async_SetInternalInt(_ async : UnsafeMutablePointer<AsyncValue<AsyncVoid>>, value : CLong) -> CLong {
    let v = async.pointee.internalInt
    async.pointee.internalInt = value
    return v
}

public func Async_GetInternalInt(_ async : UnsafeMutablePointer<AsyncValue<AsyncVoid>>) -> CLong {
    return async.pointee.internalInt
}


public func AsyncObj_SetInternalInt(_ async : UnsafeRawPointer, value : CLong) -> CLong {
    let v = Unmanaged<Async>.fromOpaque(async)
    let a = v.takeUnretainedValue()

    let ov = a.internalInt
    a.internalInt = value
    return ov
}

public func AsyncObj_GetInternalInt(_ async : UnsafeRawPointer) -> CLong {
    let v = Unmanaged<Async>.fromOpaque(async)
    let a = v.takeUnretainedValue()
    return a.internalInt
}

public func AsyncObj_CallClosure(_ closure : UnsafeMutablePointer<(_ : Async) -> Void>, _ async : UnsafeRawPointer) -> Void {
    let v = Unmanaged<Async>.fromOpaque(async)
    let a = v.takeUnretainedValue()
    closure.pointee(a)
    closure.deinitialize()
}

public func Async_CallClosure(_ closure : UnsafeMutablePointer<() -> Void>) -> Void {
    closure.pointee()
    closure.deinitialize()
}

public func Async_GetPad(_ async : UnsafeRawPointer) -> UnsafeMutableRawPointer? {
    let v = Unmanaged<Async>.fromOpaque(async)
    let a = v.takeUnretainedValue()
    return a.rawArgPad
}
