/*
    Group.swift is part of Appudo

    Copyright (C) 2015-2016
        f0c0606326222203d218d2cb3a3b46af3d6022c5a5ea9ae11d8100d62327f03a source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo
import libappudo_bridge

public func AsyncObj_SetGroupId(_ async : UnsafeRawPointer, _ id : CInt) -> Void {
    let v = Unmanaged<Async>.fromOpaque(async)
    var a = v.takeUnretainedValue() as! _AsyncStruct<Group>

    PrivateInterface.Group_SetId(&a, id)
}

public func AsyncObj_SetGroupActive(_ async : UnsafeRawPointer, _ active : CInt) -> Void {
    let v = Unmanaged<Async>.fromOpaque(async)
    var a = v.takeUnretainedValue() as! _AsyncStruct<Group>

    PrivateInterface.Group_SetActive(&a, active == 1)
}
