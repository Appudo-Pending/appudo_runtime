/*
    Group.swift is part of Appudo

    Copyright (C) 2015-2016
        f0c0606326222203d218d2cb3a3b46af3d6022c5a5ea9ae11d8100d62327f03a source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge

/**
GroupInfo holds the owning user and group of a group.
*/
public struct GroupInfo {
    var uid : UserID
    var gid : GroupID
}

/**
GroupID holds a group's unique id. Other APIs can accept GroupIDs to modify group ownership.
*/
public struct GroupID {
    private var _data : CInt

    public init(_ id : CInt) {
        _data = id
    }

    /**
    Returns the raw value of the unique group id.
    */
    public var rawValue : CInt {
        return _data
    }
}

/**
Single groups are added, modified or removed with a Group.
Files and other items can be owned by groups and users.
Users that are owners or members of an owner group can access an item depending on the the items access mode.
For example to modify a group the current login user must have the right to modify the group
by being the owning user or being member of the owner group.
Groups are initially owned by the current login user and the backend group.
All registered groups are statically accessible as roles by name from the Role struct.

- SeeAlso: FileItem.Mode
- SeeAlso: Role
*/
public struct Group {
    var _id : CInt
    var _active : Bool
    private var _async : AsyncOnSuccess<Group> = AsyncOnSuccess()

    init(_ id : CInt, _ active : Bool) {
        _id = id
        _active  = active
    }

    /**
    Add a group to the account.
    The current user must be a member of the backend group.

    - parameter name: The unique name for the group.
    - parameter active: The initial active state for the group.
    */
    public static func add(_ name : String, _ active : Bool) -> AsyncStruct<Group> {
        var ret = AsyncStruct<Group>(Group(0, active))
        struct ArgPad {
            var name : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cname = ret.arg(name, &pad.name)
        ret.store(&pad)
        Group_Add(&ret, cname, active ? 1 : 0)
        return ret
    }

    /**
    Get a group from the current account by it's unique name.
    The current user must be a member of the backend group.

    - parameter name: The unique name of the group.
    */
    public static func get(_ name : String) -> AsyncStruct<Group> {
        var ret = AsyncStruct<Group>(Group(0, false))
        struct ArgPad {
            var name : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cname = ret.arg(name, &pad.name)
        ret.store(&pad)
        Group_Get(&ret, cname)
        return ret
    }

    /**
    Remove a group from the current account by it's unique name.
    The current user must be either the owner or a member of the master group.

    - parameter name: The unique name of the group.
    */
    public static func remove(_ name : String) -> AsyncBool {
        var ret = AsyncBool(false)
        struct ArgPad {
            var name : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cname = ret.arg(name, &pad.name)
        ret.store(&pad)
        Group_DelByName(&ret, cname)
        return ret
    }

    /**
    Returns the current effective group id.
    Each run starts with the accounts runner group.
    The effective group can change with a swap to
    a different group the current user is a member of.
    A swap of the current user will revert the effective
    group to the runner group.
    */
    static public var current : GroupID {
        let ret = User_CurrentGID()
        return GroupID(ret)
    }

    /**
    Switch to another effective group.
    Members of the backend group can do a temporary switch to another group they are member of.
    Switch back to the runner group with GroupID(-1).

    - parameter group: The group to switch to.
    */
    static public func swap(_ group : GroupID = GroupID(-1)) -> AsyncBool {
        var ret = AsyncBool(false)
        User_SwapGID(&ret, group.rawValue)
        return ret
    }

    /**
    Returns the initial group id for the current run.
    Each run starts with the group that owns it
    or the runner group if not owned by a group.
    The current group can change with a swap to
    a different group.
    */
    static public var runner : GroupID {
        let ret = User_DefaultGID()
        return GroupID(ret)
    }

    /**
    Returns the unique id of the group.
    */
    public var id : GroupID {
        return GroupID(_id)
    }

    /**
    Returns true if the group is active.
    */
    public var active : Bool {
        mutating get {
            var a = _async;
            _ = a.isPending(&self)
            return _active
        }
    }

    /**
    Returns the UserID and GroupID for the current user and group owning the group.
    */
    public var info : AsyncStruct<GroupInfo> {
        var ret = AsyncStruct<GroupInfo>(nil)
        User_GetGroupOwner(&ret, _id)
        return ret
    }

    /**
    Set the owning user and group for the group.
    To change the owning user the current user must be either
    the owner of that user or a member of the master group.
    To change the owning group the current user must additionally
    be a member of that group.

    - parameter user: The user's id to set as the new owner.
    - parameter group: The group's id to set as the new owner.
    */
    public func setOwner(_ user : UserID, _ group : GroupID) -> AsyncBool {
        var ret = AsyncBool(false)
        User_SetGroupOwner(&ret, _id, user.rawValue, group.rawValue)
        return ret
    }

    /**
    Set the owning user for the group.

    - parameter user: The user's id to set as the new owner.
    */
    public func setOwner(_ user : UserID) -> AsyncBool {
        return setOwner(user, GroupID(-1))
    }

    /**
    Set the owning group for the group.

    - parameter group: The group's id to set as the new owner.
    */
    public func setOwner(_ group : GroupID) -> AsyncBool {
        return setOwner(UserID(-1), group)
    }

    /**
    Set the active property for the group.
    The current user must be either the owner or a member of the master group.

    - parameter value: The value to set the active property to.
    */
    mutating public func setActive(_ value:Bool) -> AsyncBool {
        var ret = AsyncBool(false)
        var a = _async;
        if(!a.isPending(&self)) {
            Group_SetActive(&ret, _id, value ? 1 : 0)
            _async = AsyncOnSuccess(&self, ret, { (_ , v : inout Group) in v._active = value })
        }
        return ret
    }

    /**
    Remove the group from the current account.
    The current user must be either the owner or a member of the master group.
    */
    public func remove() -> AsyncBool {
        var ret = AsyncBool(false)
        Group_DelById(&ret, _id)
        return ret
    }
}

extension Group : Equatable {
    public static func ==(lhs: Group, rhs: Group) -> Bool {
        return lhs.id == rhs.id
    }
}

extension GroupID : Equatable {
    public static func ==(lhs: GroupID, rhs: GroupID) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
