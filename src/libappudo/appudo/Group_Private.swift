/*
    Group_Private.swift is part of Appudo

    Copyright (C) 2015-2016
        f0c0606326222203d218d2cb3a3b46af3d6022c5a5ea9ae11d8100d62327f03a source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

public extension PrivateInterface {
    public static func getGroup(_ id : CInt, _ active : Bool) -> Group {
        return Group(id, active)
    }

    public static func getGroupID(_ id : CInt) -> GroupID {
        return GroupID(id)
    }

    public static func Group_SetId(_ u : inout _AsyncStruct<Group>, _ id : CInt) -> Void {
       u._value?._id = id
    }

    public static func Group_SetActive(_ u : inout _AsyncStruct<Group>, _ active : Bool) -> Void {
       u._value?._active = active
    }
}
