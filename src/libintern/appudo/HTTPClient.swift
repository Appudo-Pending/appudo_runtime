/*
    HTTPClient.swift is part of Appudo

    Copyright (C) 2015-2016
        4bea15c834854bf9670dc6a1cbc9a9dda7cf418ef53b8edbb11b3df946a0c45e source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo

public func HTTPClient_Keep(_ http : UnsafeRawPointer, _ fileFd : CInt) -> Void {
    let v = Unmanaged<HTTPClient>.fromOpaque(http)
    let a = v.takeUnretainedValue()
    _ = Unmanaged.passRetained(a)
    PrivateInterface.setHTTPClient(a, UnlinkedFilePath(fileFd))
}

public func HTTPClient_GetFd(_ http : UnsafeRawPointer) -> CInt {
    let v = Unmanaged<HTTPClient>.fromOpaque(http)
    let a = v.takeUnretainedValue()
    return PrivateInterface.getHTTPClientFd(a)
}

public func HTTPClient_Release(_ http : UnsafeRawPointer, _ error : CInt) -> Void {
    let v = Unmanaged<HTTPClient>.fromOpaque(http)
    let a = v.takeRetainedValue()
    PrivateInterface.finishHTTPClient(a, error)
}
