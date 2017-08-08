/*
    User.swift is part of Appudo

    Copyright (C) 2015-2016
        f0c0606326222203d218d2cb3a3b46af3d6022c5a5ea9ae11d8100d62327f03a source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge
import Foundation

/**
UserInfo holds the owning user and group of a user.
*/
public struct UserInfo {
    public let uid : UserID
    public let gid : GroupID
}

/**
UserID holds a user's unique id. Other APIs can accept UserIDs to modify user ownership.
*/
public struct UserID {
    private var _data : CInt

    public init(_ id : CInt) {
        _data = id
    }

    /**
    Returns the raw value of the unique user id.
    */
    public var rawValue : CInt {
        return _data
    }

    /**
    Returns the user for the unique user id.
    */
    public var value : AsyncValue<User?> {
        var ret = AsyncValue<User?>(PrivateInterface.getUser(-1, "", false))
        User_GetById(&ret, _data)
        return ret
    }
}

/**
Single users are added, modified or removed with a User.
Other APIs depend on the current login user and it's group membership.
Also files and other items are owned by users.
*/
public struct User {
    var _id : CInt
    var _name : String = ""
    var _active : Bool
    var _async : AsyncOnSuccess<User> = AsyncOnSuccess()

    init(_ id : CInt, _ name : String, _ active : Bool) {
        _id = id
        _name = name
        _active = active
    }

    /**
    Update the current login user before the login expires. Logins can be set to automatically expire after a time period.

    - parameter expire: The time until the login expires in seconds.
    */
    static public func update(_ expire : Int) -> Void {
        User_Update(expire)
    }

    /**
    Switch to another user.
    Members of the backend group can do a temporary switch to another user if they own it.
    Switch back to the initial login user with UserID(-1).
    If the new user is a member of the master group the current user also must be a member.
    A switch to the initial owner of the current run is always possible.
    Be aware that a run owned by a member of e.g. the admin group is a security risk and
    should be avoided if not absolutely necessary.

    - parameter user: The user to switch to.
    */
    static public func swap(_ user : UserID = UserID(-1)) -> AsyncBool {
        var ret = AsyncBool(false)
        User_SwapUID(&ret, user.rawValue)
        return ret
    }

    /**
    Remove a user from the current account by it's unique name.   
    The current user must be either the owner or a member of the master group.

    - parameter name: The unique name of the user.
    */
    static public func remove(_ name : String) -> AsyncBool {
        var ret = AsyncBool(false)
        struct ArgPad {
            var name : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cname = ret.arg(name, &pad.name)
        ret.store(&pad)
        User_DelByName(&ret, cname)
        return ret
    }

    /**
    Register a user with a unique name and password to get a ticket.
    Users can be added with a register and validate cycle.
    This is typically used to validate users by email before adding them.
    In this case the mail can be used as the name.
    The current user must be a member of the backend group.

    - parameter name: The unique name for the user.
    - parameter password: The password to login the user.
    */
    public static func register(_ name : String, _ password : String) -> AsyncStruct<String> {
        var ret = AsyncStruct<String>(nil)
        struct ArgPad {
            var name : AnyObject? = nil
            var password : AnyObject? = nil
            var ret : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cname = ret.arg(name, &pad.name)
        let cpassword = ret.arg(password, &pad.password)
        ret.store(&pad)
        User_Register(&ret, cname, cpassword, &pad.ret)
        return ret
    }

    /**
    Validate a registered user.
    The current user must be a member of the backend group.

    - parameter name: The unique name of the user.
    - parameter password: The ticket returned from the call to register for the user to add.

    - SeeAlso: register
    */
    public static func validate(_ name : String, _ ticket : String) -> AsyncStruct<User> {
        var ret = AsyncStruct<User>(User(0, name, true))
        struct ArgPad {
            var name : AnyObject? = nil
            var ticket : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cname = ret.arg(name, &pad.name)
        let cticket = ret.arg(ticket, &pad.ticket)
        ret.store(&pad)
        User_Validate(&ret, cname, cticket)
        return ret
    }

    /**
    Add a new user to the current account.
    The current user must be a member of the backend group.

    - parameter name: The unique name for the user.
    - parameter password: The password to login the user.
    - parameter active: The initial active state for the user.
    */
    static public func add(_ name : String, _ password : String, _ active : Bool) -> AsyncStruct<User> {
        var ret = AsyncStruct<User>(User(0, name, active))
        struct ArgPad {
            var name : AnyObject? = nil
            var password : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cname = ret.arg(name, &pad.name)
        let cpassword = ret.arg(password, &pad.password)
        ret.store(&pad)
        User_Add(&ret, cname, cpassword, active ? 1 : 0)
        return ret
    }

    /**
    Get a user from the current account by it's unique name.
    The current user must be a member of the backend group.

    - parameter name: The unique name of the user.
    */
    static public func get(_ name : String) -> AsyncStruct<User> {
        var ret = AsyncStruct<User>(User(0, name, false))
        struct ArgPad {
            var name : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cname = ret.arg(name, &pad.name)
        ret.store(&pad)
        User_Get(&ret, cname)
        return ret
    }


    /**
    Login as a user. This will logout a current user.
    There can only be one login sesssion per user. It is possible to join a current login session by using a valid loginHash.
    - parameter name: The login name of the user.
    - parameter password: The login password of the user.
    - parameter expire: The expiration time for the login in seconds.
    - parameter loginHash: The login hash of an active login to reuse.
    */
    static public func login(_ name : String, _ password : String, _ expire : Int = 3600, _ loginHash : String? = nil) -> AsyncBool {
        var ret = AsyncBool(false)
        struct ArgPad {
            var name : AnyObject? = nil
            var password : AnyObject? = nil
            var loginHash : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cname = ret.arg(name, &pad.name)
        let cpassword = ret.arg(password, &pad.password)
        var chash : UnsafePointer<Int8>? = nil
        if(loginHash != nil) {
            chash = ret.arg(loginHash!, &pad.loginHash)
        }
        ret.store(&pad)
        User_Login(&ret, cname, cpassword, chash, expire)
        return ret
    }

    /**
    Logout the current login user.
    */
    static public func logout() -> Void {
        User_Logout()
    }

    /**
    Returns the owner user id for the current run.
    Each run starts with the user that owns it.
    The current user can change with a user login
    or a swap to a different user.
    */
    static public var owner : UserID {
        let ret = User_DefaultUID()
        return UserID(ret)
    }

    /**
    Returns the current effective user id.
    Each run starts with the user that owns it.
    The current user can change with a user login
    or a swap to a different user.
    */
    static public var current : UserID {
        let ret = User_CurrentUID()
        return UserID(ret)
    }

    /**
    Returns the login user id.
    Each run can have a single user at a time to be logged in.
    The login and current user can differ due to a user swap.
    */
    static public var logon : UserID? {
        let ret = User_Logon()
        return ret == -1 ? nil : UserID(ret)
    }

    /**
    Returns the login hash for the current login session.
    This is useful to join an active login session.
    The hash can only be used in addition to a full credential user login.

    - SeeAlso: login
    */
    static public var loginHash : String? {
        var res : String? = nil
        User_CurrentHash(&res)
        return res
    }

    /**
    Returns the custom data value of the current login user or nil if there is no login.
    The data itself can not be set to nil.
    The current user must be either the owner, a member of the master group or the user itself.
    */
    static public var data : Int? {
        get {
            var res : Int? = nil
            User_GetCurrentData(&res)
            return res
        }
        set {
            if(newValue != nil) {
                User_SetCurrentData(newValue!)
            }
        }
    }

    /**
    Returns the unique id of the user.
    */
    public var id : UserID {
        return UserID(_id)
    }

    /**
    Returns the unique name of the user.
    */
    public var name : String {
        return _name
    }

    /**
    Returns true if the user is active.
    */
    public var active : Bool {
        mutating get {
            var a = _async;
            _ = a.isPending(&self)
            return _active
        }
    }

    /**
    Returns true if the login of the user has expired.
    */
    public var expired : Bool {
        let res : CInt = User_LoginExpired(_id)
        return res != 0
    }

    /**
    Returns the time of the last login of the user.
    */
    public var lastLogin : AsyncStruct<Date> {
        var ret = AsyncStruct<Date>(nil)
        User_LastLogin(&ret, _id)
        return ret
    }

    /**
    Returns the UserID and GroupID for the current user and group owning the user.
    */
    public var info : AsyncStruct<UserInfo> {
        var ret = AsyncStruct<UserInfo>(nil)
        User_GetOwner(&ret, _id)
        return ret
    }

    /**
    Set the owning user and group for the user.
    To change the owning user the current user must be either
    the owner of that user or a member of the master group.
    To change the owning group the current user additionally must be
    a member of that group.

    - parameter user: The user's id to set as the new owner.
    - parameter group: The group's id to set as the new owner.
    */
    public func setOwner(_ user : UserID, _ group : GroupID) -> AsyncBool {
        var ret = AsyncBool(false)
        User_SetOwner(&ret, _id, user.rawValue, group.rawValue)
        return ret
    }

    /**
    Set the owning user for the user.

    - parameter user: The user's id to set as the new owner.
    */
    public func setOwner(_ user : UserID) -> AsyncBool {
        return setOwner(user, GroupID(-1))
    }

    /**
    Set the owning group for the user.

    - parameter group: The group's id to set as the new owner.
    */
    public func setOwner(_ group : GroupID) -> AsyncBool {
        return setOwner(UserID(-1), group)
    }

    /**
    Remove the user from the current account.
    The current user must be either the owner or a member of the master group.
    */
    mutating public func remove() -> AsyncBool {
        var ret = AsyncBool(false)
        var a = _async;
        if(!a.isPending(&self)) {
            User_DelById(&ret, _id)
            //_async = AsyncOnSuccess(&self, ret, {(_ , v : inout User) in v._id = -1 })
        }
        return ret
    }

    /**
    Set a new password for the user.
    The current user must be either the owner, a member of the master group or the user itself.

    - parameter password: The new password for the user.
    */
    mutating public func setPassword(_ password:String) -> AsyncBool {
        var ret = AsyncBool(false)
        var a = _async;
        if(!a.isPending(&self)) {
            struct ArgPad {
                var password : AnyObject? = nil
            }
            var pad : ArgPad = ArgPad()
            let cpassword = ret.arg(password, &pad.password)
            ret.store(&pad)
            User_SetPassword(&ret, _id, cpassword)
            _async = AsyncOnSuccess(&self, ret)
        }
        return ret
    }

    /**
    Set the active property for the user.
    The current user must be either the owner or a member of the master group.

    - parameter value: The value to set the active property to.
    */
    mutating public func setActive(_ value:Bool) -> AsyncBool {
        var ret = AsyncBool(false)
        var a = _async;
        if(!a.isPending(&self)) {
            User_SetActive(&ret, _id, value ? 1 : 0)
            _async = AsyncOnSuccess(&self, ret, { (_ , v : inout User) in v._active = value })
        }
        return ret
    }

    /**
    Check if the user is a member of the group.

    - parameter group: The group id to check ownership for.
    */
    public func hasGroup(_ group : GroupID) -> AsyncBool {
        var ret = AsyncBool(false)
        User_HasGroup(&ret, _id, group.rawValue)
        return ret
    }

    /**
    Add the user as a member of the group.
    The current user must be either the owner or a member of the master group.
    Additionally the current user must be a member of the group to add.

    - parameter group: The group id to set ownership for.
    */
    public func addGroup(_ group : GroupID) -> AsyncBool {
        var ret = AsyncBool(false)
        User_AddGroup(&ret, _id, group.rawValue)
        return ret
    }

    /**
    Remove the user as a member of the group.
    The current user must be either the owner or a member of the master group.

    - parameter group: The group id to set ownership for.
    */
    public func removeGroup(_ group : GroupID) -> AsyncBool {
        var ret = AsyncBool(false)
        User_DelGroup(&ret, _id, group.rawValue)
        return ret
    }

    /**
    Get the list of users owned by a user.

    - parameter user: The user owning the users.
    - parameter order: The sort function to order the list.
    - parameter chunkLimit: The chunk limit for the list.
    - parameter withGroups: Also load the groups with each user.
    The list is created in chunks. Only the current chunk is held in memory and sorted.
    */
    static public func listOwned(_ user : UserID, order : (_UserListItem.Sorter?) = nil, chunkLimit : Int32 = 0, withGroups : Bool = false) -> AsyncClass<UserList> {
        return createUserList(user.rawValue, order, chunkLimit, true, withGroups)
    }

    /**
    Get the list of users owned by a group.

    - parameter group: The group owning the users.
    - parameter order: The sort function to order the list.
    - parameter chunkLimit: The chunk limit for the list.
    - parameter withGroups: Also load the groups with each user.
    The list is created in chunks. Only the current chunk is held in memory and sorted.
    */
    static public func listOwned(_ group : GroupID, order:(_UserListItem.Sorter?) = nil, chunkLimit:Int32 = 0, withGroups: Bool = false) -> AsyncClass<UserList> {
        return createUserList(group.rawValue, order, chunkLimit, false, withGroups)
    }
}

extension User : Equatable {
    public static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

extension UserID : Equatable {
    public static func ==(lhs: UserID, rhs: UserID) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

public struct _UserListItem {
    public typealias Sorter = (_ a:_UserListItem, _ b:_UserListItem) -> Int32
    public let id : CInt
    public let info : CInt
    public let name : String = ""
    public var active : Bool {
        return (info & CInt(1)) != 0
    }
    public var groups : Bool {
        return (info & CInt(2)) != 0
    }
    public var user : User {
        return User(id, name, active)
    }
}

/**
UserListItem represents a single item in a UserList.
*/
public struct UserListItem {
    let _list : UserList
    let _groups : UnsafePointer<CInt>?
    public let id : Int32
    public let name : String
    public let active : Bool
    public init(_ list : UserList, _ groups : UnsafePointer<CInt>?, _ id_: Int32, _ name_: String, _ active_: Bool) {
        _list = list
        _groups = groups
        id = id_
        name = name_
        active = active_
    }

    /**
    Returns number of groups for this user.
    */
    public var numGroups : Int {
        return _groups != nil ? Int(_groups![0]) : 0
    }

    /**
    Returns the users group at a given index.
    - parameter idx: The index of the group to return.
    */
    public func getGroupAt(_ idx : Int) -> GroupID {
        if(_groups != nil) {
            let size = Int(_groups![0])
            if(idx < size) {
                return GroupID(_groups![idx + 1])
            }
        }
        return GroupID(-1)
    }
}

/**
UserList is a chunked list representation for user listings.
*/
open class UserList : Sequence, IteratorProtocol {
    open var startIndex: Int { get { return 0 } }
    open var endIndex: Int { get { return 0 } }

    public func index(after: Int) -> Int {
            return after + 1
    }

    open func next() -> UserListItem? {
        fatalError("must implement")
    }

    open func nextList(_ order:(_UserListItem.Sorter?) = nil, _ chunkLimit:Int32 = 64) -> AsyncClass<UserList> {
        fatalError("must implement")
    }
}

/**
AlphasortASC is a comparison function for user listings with ascending alphabetical order.

- SeeAlso: UserList
*/
public func AlphasortASC(a:_UserListItem, b:_UserListItem) -> Int32 {
    return String_strcoll(a.name, b.name)
}

/**
AlphasortASC is a comparison function for user listings with descending alphabetical order.

- SeeAlso: UserList
*/
public func AlphasortDSC(a:_UserListItem, b:_UserListItem) -> Int32 {
    return String_strcoll(b.name, a.name)
}

func createUserList(_ owner : Int32, _ sorter : _UserListItem.Sorter?, _ chunkLimit:Int32, _ user : Bool, _ withGroups : Bool) -> AsyncValue<UserList?> {
    var ret = AsyncValue<UserList?>(nil)
    struct ArgPad {
        var owner : CInt
        var info : CInt
        var chunkLimit : CInt
        var sorter : _UserListItem.Sorter?
    }
    var pad : ArgPad = ArgPad(owner:owner, info:(user ? 1 : 0) + (withGroups ? 2 : 0) + (sorter != nil ? 4 : 0), chunkLimit:chunkLimit, sorter:sorter)
    ret.store(&pad)
    User_CreateList(&ret, &pad, nil)
    return ret
}
