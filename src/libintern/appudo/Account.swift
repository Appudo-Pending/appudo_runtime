/*
    Account.swift is part of Appudo

    Copyright (C) 2015-2016
        f0c0606326222203d218d2cb3a3b46af3d6022c5a5ea9ae11d8100d62327f03a source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo
import libappudo_bridge

public func AsyncObj_SetAccountId(_ async : UnsafeRawPointer, _ id : CLong) -> Void {
    let v = Unmanaged<Async>.fromOpaque(async)
    var a = v.takeUnretainedValue() as! _AsyncStruct<Account>

    PrivateInterface.Account_SetId(&a, id)
}

public func AsyncObj_SetAccountActive(_ async : UnsafeRawPointer, _ active : CInt) -> Void {
    let v = Unmanaged<Async>.fromOpaque(async)
    var a = v.takeUnretainedValue() as! _AsyncStruct<Account>

    PrivateInterface.Account_SetActive(&a, active == 1)
}

public func AsyncObj_SetAccountName(_ async : UnsafeRawPointer, _ ptr : UnsafePointer<Int8>, _ len : CLong) -> Void {
    let v = Unmanaged<Async>.fromOpaque(async)
    var a = v.takeUnretainedValue() as! _AsyncStruct<Account>

    PrivateInterface.Account_SetName(&a, fromUTF8_nocheck(ptr, len))
}

public func AsyncObj_SetAccountInfo(_ async : UnsafeRawPointer, _ ouid : CInt, _ ruid : CInt,  _ rgid : CInt,  _ bgid : CInt) -> Void {
    let v = Unmanaged<Async>.fromOpaque(async)
    var a = v.takeUnretainedValue() as! _AsyncStruct<AccountInfo>

    PrivateInterface.Account_SetInfo(&a, ouid, ruid, rgid, bgid)
}
