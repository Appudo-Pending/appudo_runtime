/*
    Cookie_Private.swift is part of Appudo

    Copyright (C) 2015-2016
        bc00940f92e19b5d84931da5bbb6bce10b8e341bdd9d98d016513a164e790c05 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo
import libappudo_bridge

public extension PrivateInterface {
    public static func getCookieVar(_ ptr : UnsafeMutablePointer<Int32>, _ keySlot : UnsafeMutableRawPointer, _ value : String = "") -> CookieVar {
        return CookieVar(ptr, keySlot, value)
    }
}

public func Cookie_WriteValue(_ request : UnsafeMutableRawPointer, _ cookie : UnsafeMutableRawPointer, _ namePtr : UnsafePointer<Int8>, _ valueIdx : CInt) -> Void {
    var holder : AnyObject? = nil
    var str = PrivateInterface.getRunData4Page(__getStackBase()).stringStore[Int(valueIdx)]
    let value = AsyncArg.save(str, &holder)
    Cookie_Write(request, cookie, namePtr, value)
}
