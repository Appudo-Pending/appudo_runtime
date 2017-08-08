/*
    Account_Private.swift is part of Appudo

    Copyright (C) 2015-2016
        f0c0606326222203d218d2cb3a3b46af3d6022c5a5ea9ae11d8100d62327f03a source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

public extension PrivateInterface {
    public static func Account_SetId(_ account : inout _AsyncStruct<Account>, _ id : Int) -> Void {
        account._value?._id = id
    }

    public static func Account_SetActive(_ account : inout _AsyncStruct<Account>, _ active : Bool) -> Void {
        account._value?._active = active
    }

    public static func Account_SetName(_ account : inout _AsyncStruct<Account>, _ name : String) -> Void {
        account._value?._name = name
    }

    public static func Account_SetInfo(_ info : inout _AsyncStruct<AccountInfo>, _ ouid : CInt, _ ruid : CInt,  _ rgid : CInt,  _ bgid : CInt) -> Void {
        info._value?._ouid = UserID(ouid)
        info._value?._ruid = UserID(ruid)
        info._value?._rgid = GroupID(rgid)
        info._value?._bgid = GroupID(bgid)
    }
}
