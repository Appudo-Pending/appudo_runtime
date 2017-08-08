/*
    User_Private.swift is part of Appudo

    Copyright (C) 2015-2016
        f0c0606326222203d218d2cb3a3b46af3d6022c5a5ea9ae11d8100d62327f03a source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

public extension PrivateInterface {
    public static func getUser(_ id : CInt, _ name : String, _ active : Bool) -> User {
        return User(id, name, active)
    }

    public static func User_SetId(_ u : inout _AsyncStruct<User>, _ id : CInt) -> Void {
       u._value?._id = id
    }

    public static func User_SetActive(_ u : inout _AsyncStruct<User>, _ active : Bool) -> Void {
        u._value?._active = active
    }

    public static func User_SetName(_ u : inout _AsyncStruct<User>, _ name : String) -> Void {
        u._value?._name = name
    }

    public static func User_GetUserInfo(uid:UserID, gid:GroupID) -> UserInfo {
        return UserInfo(uid:uid,gid:gid)
    }
}
