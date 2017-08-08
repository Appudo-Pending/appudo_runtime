/*
    Setting.swift is part of Appudo

    Copyright (C) 2015-2016
        bc00940f92e19b5d84931da5bbb6bce10b8e341bdd9d98d016513a164e790c05 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge

/**
Single setting values are accessed or updated with a SettingVar.
All registered settings of a run are statically accessible by name from the Setting struct.

- SeeAlso: Setting
*/
public struct SettingVar : CustomStringConvertible {
    let _stackBase : UnsafeMutablePointer<CChar>
    let _index : Int32
    init(_ base : UnsafeMutablePointer<CChar>, _ ptr : UnsafeMutablePointer<Int32>, _ str : UnsafeMutablePointer<UInt8>, _ len : CInt) {
        var index = ptr.pointee
        _stackBase = base
        if(index == -1) {
            index = Int32(PrivateInterface.getRunData().stringStore.count)
            if(index < Int32.max - 1)
            {
                let s = String._fromWellFormedCodeUnitSequence(UTF8.self, input: CharBufferData(str, Int(len)))
                ptr.pointee = index
                PrivateInterface.getRunData().stringStore.append(s)
            } else {
                index = -1
            }
        }
        _index = index
    }

    /**
    Get the value of the setting as String.
    */
    public var value : String  {
        get {
            return PrivateInterface.getRunData().stringStore[Int(_index)]
        }

        set {
            PrivateInterface.getRunData().stringStore[Int(_index)] = newValue
        }
    }

    /**
    Check if there was an error parsing the setting.
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
