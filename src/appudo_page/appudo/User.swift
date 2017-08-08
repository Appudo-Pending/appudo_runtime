/*
    User.swift is part of Appudo

    Copyright (C) 2015-2016
        f0c0606326222203d218d2cb3a3b46af3d6022c5a5ea9ae11d8100d62327f03a source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo
import libappudo_bridge

extension User {
    /**
    Returns true if the user is connected from a mobile device.
    This is not always accurate since users can be connected in different ways.
    For pages this is derived from the user agent header field.
    */
    static public var mobile : Bool {
        var ret : CInt = 0
        User_IsMobile(&ret)
        return ret != 0
    }

    /**
    Returns the first priority language of a user.
    For pages this is parsed from a http header.
    */
    static public var lang : Lang {
        get {
            return Lang(rawValue:Page_GetLang(0))!
        }
        set {
            Page_SetLang(0, newValue.rawValue)
        }
    }

    /**
    Returns the second priority language of a user.
    For pages this is parsed from a http header.
    */
    static public var lang2 : Lang {
        get {
            return Lang(rawValue:Page_GetLang(1))!
        }
        set {
            Page_SetLang(1, newValue.rawValue)
        }
    }

    /**
    Returns the third priority language of a user.
    For pages this is parsed from a http header.
    */
    static public var lang3 : Lang {
        get {
            return Lang(rawValue:Page_GetLang(2))!
        }
        set {
            Page_SetLang(2, newValue.rawValue)
        }
    }

    /**
    Get the remote clients browser agent.
    */
    public static var agent : String? {
        var path : _PagePathInfo = _PagePathInfo()
        Page_GetAgent(&path)
        if(path.ptr != nil && path.len != 0) {
                return fromUTF8_check(path.ptr!, path.len)
        }
        return nil
    }

    /**
    Returns the inet address of the connections remote client.
    */
    static public var remoteAddr : InetAddr {
        var addr : sockaddr = sockaddr()
        switch(InetAddrType(rawValue:Page_GetAddr(&addr)) ?? .Invalid) {
            case .INET:
                return withUnsafePointer(to:&addr) {
                    let ptr = UnsafeMutableRawPointer(mutating:$0).assumingMemoryBound(to:sockaddr_in.self)
                    return .V4(addr:ptr.pointee)
                }
            case .INET6:
                return withUnsafePointer(to:&addr) {
                    let ptr = UnsafeMutableRawPointer(mutating:$0).assumingMemoryBound(to:sockaddr_in6.self)
                    return .V6(addr:ptr.pointee)
                }
            default:
                return .Invalid
        }
    }
}
