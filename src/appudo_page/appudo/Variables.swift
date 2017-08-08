/*
    Variables.swift is part of Appudo

    Copyright (C) 2015-2016
        bc00940f92e19b5d84931da5bbb6bce10b8e341bdd9d98d016513a164e790c05 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge
import libappudo

/**
Get variables are accessed and updated with a GetVar.
All registered get variables of a page are statically accessible by name from the Get struct.

- SeeAlso: Get
*/
public struct GetVar : CustomStringConvertible {
    let _index : Int32
    init(_ ptr : UnsafeMutablePointer<Int32>, _ str : String = "") {
        var index = ptr.pointee
        if(index == -1) {
            index = Int32(PrivateInterface.getRunData4Page(__getStackBase()).stringStore.count)
            if(index < Int32.max - 1)
            {
                ptr.pointee = index
                PrivateInterface.getRunData4Page(__getStackBase()).stringStore.append(str)
            } else {
                index = -1
            }
        }
        _index = index
    }

    /**
    Get and set the value of the get variable as String.
    */
    public var value : String  {
        get {
            return PrivateInterface.getRunData4Page(__getStackBase()).stringStore[Int(_index)]
        }

        set {
            PrivateInterface.getRunData4Page(__getStackBase()).stringStore[Int(_index)] = newValue
        }
    }

    /**
    Check if there was an error parsing the get variable.
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

/**
Post variables are accessed and updated with a PostVar.
All registered post variables of a page are statically accessible by name from the Post struct.

- SeeAlso: Post
*/
public struct PostVar : CustomStringConvertible {
    let _index : Int32
    init(_ ptr : UnsafeMutablePointer<Int32>, _ str : String = "") {
        var index = ptr.pointee
        if(index == -1) {
            index = Int32(PrivateInterface.getRunData4Page(__getStackBase()).stringStore.count)
            if(index < Int32.max - 1)
            {
                ptr.pointee = index
                PrivateInterface.getRunData4Page(__getStackBase()).stringStore.append(str)
            } else {
                 index = -1
            }
        }
        _index = index
    }

    /**
    Get and set the value of the post variable as String.
    */
    public var value : String  {
        get {
            return PrivateInterface.getRunData4Page(__getStackBase()).stringStore[Int(_index)]
        }

        set {
            PrivateInterface.getRunData4Page(__getStackBase()).stringStore[Int(_index)] = newValue
        }
    }

    /**
    Check if there was an error parsing the get variable.
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
