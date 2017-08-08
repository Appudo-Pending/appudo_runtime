/*
    Cookie.swift is part of Appudo

    Copyright (C) 2015-2016
        bc00940f92e19b5d84931da5bbb6bce10b8e341bdd9d98d016513a164e790c05 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge
import libappudo

/**
    Single cookie values are accessed, updated or removed with a CookieVar.
    All registered cookies of a page are statically accessible by name from the Cookie struct.

    - SeeAlso: Cookie
*/
public struct CookieVar : CustomStringConvertible {
    let _index : Int32
    let _keySlot : UnsafeMutableRawPointer
    init(_ ptr : UnsafeMutablePointer<Int32>, _ keySlot : UnsafeMutableRawPointer, _ value : String = "") {
        var index = ptr.pointee
        _keySlot = keySlot
        if(index == -1) {
            index = Int32(PrivateInterface.getRunData4Page(__getStackBase()).stringStore.count)
            if(index < Int32.max - 1)
            {
                ptr.pointee = index
                PrivateInterface.getRunData4Page(__getStackBase()).stringStore.append(value)
            } else {
                index = -1
            }
        }
        _index = index
    }

    /**
    Get the value of the cookie as String.
    */
    public var value : String  {
        get {
            return PrivateInterface.getRunData4Page(__getStackBase()).stringStore[Int(_index)]
        }
    }

    /**
    Remove the cookie.
    */
    public func remove() -> Void {
        PrivateInterface.getRunData4Page(__getStackBase()).stringStore[Int(_index)] = ""
        Cookie_Remove(_keySlot)
    }

    /**
    Update the cookie value.
    The domain of the cookie is set to the current domain of the page run.
    The path of the cookie is set to the path of the page where the cookie is registered.
    Inherited cookies are only valid in sub pages when they match a sub path with their parent.

    - parameter value: The new value for the cookie.
    - parameter expires: The time until the cookie expires or -1 for infinite.
    - parameter noJS: A flag to prevent javascript access to the cookie.
    - parameter secureOnly: A flag to force the cookie transfer to only happen on a secure connection.
    */
    public func set(_ value : String, expire : Int32 = 3600, noJS : Bool = true, secureOnly : Bool = false) -> Void {
        PrivateInterface.getRunData4Page(__getStackBase()).stringStore[Int(_index)] = value
        Cookie_Update(_keySlot, expire, noJS ? 1 : 0, secureOnly ? 1 : 0)
    }

    /**
    Check if there was an error parsing the cookie.
    */
    public var isValid : Bool {
        return _index != -1
    }

    /**
    */
    public var description : String {
        return value
    }
}
