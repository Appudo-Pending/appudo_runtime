/*
    Account.swift is part of Appudo

    Copyright (C) 2015-2016
        f0c0606326222203d218d2cb3a3b46af3d6022c5a5ea9ae11d8100d62327f03a source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge

/**
AccountID holds an account's unique id. Other APIs can accept AccountIDs.
*/
public struct AccountID {
    private var _data : CLong

    public init(_ id : CLong) {
        _data = id
    }

    /**
    Returns the raw value of the unique group id.
    */
    public var rawValue : CLong {
        return _data
    }

    /**
    Returns the account for the unique account id.
    */
    public var value : AsyncValue<Account?> {
        var ret = AsyncStruct<Account>(Account(-2, "", false))
        Account_GetById(&ret, _data)
        return ret
    }
}

public struct AccountInfo {
    var _ouid : UserID = UserID(-1);
    var _ruid : UserID = UserID(-1);
    var _rgid : GroupID = GroupID(-1);
    var _bgid : GroupID = GroupID(-1);

    public var ouid : UserID {
        return _ouid;
    }

    public var ruid : UserID {
        return _ruid;
    }

    public var rgid : GroupID {
        return _rgid;
    }

    public var bgid : GroupID {
        return _bgid;
    }
}

/**
Single accounts are added, updated and removed with an Account. Appudo is a multi account system where each account has multiple users. An Account can have multiple domains to access its runs. To use this API the user of the current login must be in the master group.
*/
public struct Account {

    /**
    Add an account.
    The current user must be a member of the master group.

    - parameter accountName: The unique name for the new account.
    - parameter userName: The unique name for the backend user of the new account.
    - parameter userPassword: The password for the backend user of the new account.
    - parameter master: Set this to true if the backend user should also be added to the master group.

    - SeeAlso: User
    */
    public static func add(_ accountName : String, _ userName : String, _ userPassword : String, _ master : Bool) -> AsyncStruct<Account> {
        var ret = AsyncStruct<Account>(Account(0, accountName, false))
        struct ArgPad {
            var name : AnyObject? = nil
            var uname : AnyObject? = nil
            var password : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cname = ret.arg(accountName, &pad.name)
        let cuname = ret.arg(userName, &pad.uname)
        let cpassword = ret.arg(userPassword, &pad.password)
        ret.store(&pad)
        Account_Add(&ret, cname, cuname, cpassword, master ? 1 : 0)
        return ret
    }

    /**
    Get an existing account by its unique name.
    The current user must be a member of the master group.

    - parameter name: The unique name of the account.
    */
    public static func get(_ name : String) -> AsyncStruct<Account> {
        var ret = AsyncStruct<Account>(Account(-1, name, false))
        struct ArgPad {
            var name : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cname = ret.arg(name, &pad.name)
        ret.store(&pad)
        Account_Get(&ret, cname)
        return ret
    }

    /**
    Remove an existing account by its unique name.
    The current user must be a member of the master group.

    - parameter name: The unique name of the account.
    */
    public static func remove(_ name : String) -> AsyncBool {
        var ret = AsyncBool(false)
        struct ArgPad {
            var name : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cname = ret.arg(name, &pad.name)
        ret.store(&pad)
        Account_DelByName(&ret, cname)
        return ret
    }

    /**
    Returns the current account id executing the run.
    */
    public static var current : AccountID {
        get {

            return AccountID(Account_Current())
        }
    }

    internal init(_ id : Int, _ name : String, _ active : Bool) {
        _id = id
        _name = name
        _active = active
    }

    var _id : Int
    var _name : String
    var _active : Bool
    private var _async : AsyncOnSuccess<Account> = AsyncOnSuccess()

    /**
    The unique id of the account.
    */
    public var id : AccountID {
        return AccountID(_id)
    }

    /**
    The unique name of the account.
    */
    public var name : String {
        return _name
    }

    /**
    Returns true if the account is active.
    */
    public var active : Bool {
        mutating get {
	    var a = _async;
            _ = a.isPending(&self)
            return _active
        }
    }

    /**
    Set the accounts active property.
    The current user must be a member of the master group.

    - parameter value: The value to set the active property to.
    */
    mutating public func setActive(_ value:Bool) -> AsyncBool {
        var ret = AsyncBool(false)
        var a = _async;
	if(!a.isPending(&self)) {
            Account_SetActive(&ret, _id, value ? 1 : 0)
            _async = AsyncOnSuccess(&self, ret, { (_ , v : inout Account) in v._active = value })
        }
        return ret
    }

    public var info : AsyncStruct<AccountInfo> {
        var ret = AsyncStruct<AccountInfo>(AccountInfo())
        Account_Info(&ret, _id)
        return ret
    }

    /**
    Remove the account.
    The current user must be a member of the master group.
    */
    mutating public func remove() -> AsyncBool {
        var ret = AsyncBool(false)
	var a = _async;
        if(!a.isPending(&self)) {
            Account_DelById(&ret, _id)
            //_async = AsyncOnSuccess(&self, ret, {(_ , v : inout Account) in v._id = -1 })
        }
        return ret
    }

    /**
    Add a domain to the account.
    The current user must be a member of the master group.

    - parameter host: The host name for the domain.
    */
    mutating public func addDomain(_ host : String) -> AsyncBool {
        var ret = AsyncBool(false)
        var a = _async;
	if(!a.isPending(&self)) {
            struct ArgPad {
                var host : AnyObject? = nil
            }
            var pad : ArgPad = ArgPad()
            let chost = ret.arg(host, &pad.host)
            ret.store(&pad)
            Account_AddDomain(&ret, _id, chost)
            _async = AsyncOnSuccess(&self, ret)
        }
        return ret
    }

    /**
    Remove a domain from the account.
    The current user must be a member of the master group.

    - parameter host: The host name of the domain.
    */
    mutating public func removeDomain(_ host : String) -> AsyncBool {
        var ret = AsyncBool(false)
        var a = _async;
	if(!a.isPending(&self)) {
            struct ArgPad {
                var host : AnyObject? = nil
            }
            var pad : ArgPad = ArgPad()
            let chost = ret.arg(host, &pad.host)
            ret.store(&pad)
            Account_DelDomain(&ret, _id, chost)
            _async = AsyncOnSuccess(&self, ret.unpack)
        }

        return ret
    }
}


extension Account : Equatable {
    public static func ==(lhs : Account, rhs : Account) -> Bool {
        return lhs.id == rhs.id
    }
}

extension AccountID : Equatable {
    public static func ==(lhs : AccountID, rhs : AccountID) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
