/*
    WebSocketEvent.swift is part of Appudo

    Copyright (C) 2015-2016
        4bea15c834854bf9670dc6a1cbc9a9dda7cf418ef53b8edbb11b3df946a0c45e source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo
import libappudo_special
import libappudo_bridge

public func WebSocketEvent_Init(id : CInt, _ target : CInt, _ fkt : @convention(swift) (WebSocketEvent) -> Void) -> Void {
    fkt(WebSocketEvent(id : WebSocketEventType(rawValue : Int(id))!, data : nil, target : Socket(v : UInt32(target))))
}

public func WebSocketEvent_InitStr_check(id : CInt, _ ptr : UnsafeMutableRawPointer, _ len : CInt, _ target : CInt, _ fkt : @convention(swift) (WebSocketEvent) -> Void) -> Void {
    let buffer = ManagedCharBuffer.create(Int(len))
    _ = libappudo_bridge.CopyFrameData(ptr, buffer.firstElementAddress, CLong(len))
    if let str = String._fromCodeUnitSequence(UTF8.self, input: buffer.data) {
        fkt(WebSocketEvent(id : WebSocketEventType(rawValue : Int(id))!, data : str, target : Socket(v : UInt32(target))))
    }
}

public func WebSocketEvent_InitStr(id : CInt, _ ptr : UnsafeMutableRawPointer, _ len : CInt, _ target : CInt, _ fkt : @convention(swift) (WebSocketEvent) -> Void) -> Void {
    let buffer = ManagedCharBuffer.create(Int(len))
    _ = libappudo_bridge.CopyFrameData(ptr, buffer.firstElementAddress, CLong(len))
    let str = String._fromWellFormedCodeUnitSequence(UTF8.self, input: buffer.data)

    fkt(WebSocketEvent(id : WebSocketEventType(rawValue : Int(id))!, data : str, target : Socket(v : UInt32(target))))
}

public func WebSocketEvent_InitBytes(id : CInt, _ ptr : UnsafeMutableRawPointer, _ len : CInt, _ target : CInt, _ fkt : @convention(swift) (WebSocketEvent) -> Void) -> Void {
    let buffer = ManagedCharBuffer.create(Int(len))
    _ = libappudo_bridge.CopyFrameData(ptr, buffer.firstElementAddress, CLong(len))

    fkt(WebSocketEvent(id : WebSocketEventType(rawValue : Int(id))!, data : buffer, target : Socket(v : UInt32(target))))
}
