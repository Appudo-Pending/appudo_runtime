/*
    Page.swift is part of Appudo

    Copyright (C) 2015-2016
        bc00940f92e19b5d84931da5bbb6bce10b8e341bdd9d98d016513a164e790c05 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge
import libappudo

/**
PageEventType holds the different types of page events.
*/
public enum PageEventType : Int {
    case UPLOAD       = 1
    case ERROR        = 2
    case CACHE        = 3
}

/**
The page run receives PageEvent items on events like uploads or errors.
*/
public struct PageEvent {
    public init(id : PageEventType, data : Any?) {
        _id = id
        _data = data
    }

    /**
    Returns the data for the message.
    */
    public var data : Any? {
        return _data
    }

    var _id : PageEventType
    var _data : Any?
}

public extension Page {
    private static var runData : RunData {
        get {
            return PrivateInterface.getRunData4Page(__getStackBase())
        }
    }

    /**
    Return the current output position for the page result data.
    */
    public static var position : Int {
        // TODO
        return 0
    }

    /**
    Return true if it is possible to push assets to the receiver.
    */
    public static var canPush : Bool {
        // TODO
        return true
    }

    /**
    Push a file to the receiver.

    - parameter target: The target to identify the pushed file.
    - parameter file: The file to push.
    */
    public static func push(_ target : StringData, _ file : FileItem) -> Bool {
        // TODO
        return true
    }

    /**
    Get or set the resulting HTTP status code.
    */
    public static var resultStatus : HTTPRequestStatus {
        get {
            return HTTPRequestStatus(rawValue:Page_GetStatus())!
        }
        set {
            Page_SetStatus(newValue.rawValue)
        }
    }
    /**
    Force a Page Error result.
    */
    public static var error : PageResultError {
        get {
            return PageResultError(rawValue:Page_GetError())!
        }
        set {
            Page_SetError(newValue.rawValue)
        }
    }

    /**
    If set to false, onGetCache is not called.
    */
    public static var doCache : Bool {
        get {
            return Page_GetDoCache() == 1
        }
        set {
            Page_SetDoCache(newValue ? 1 : 0)
        }
    }

    /**
    Get or set the current skin id. Pages can have different skins for their templates.
    */
    public static var skinId : UInt32 {
        get {
            return Page_GetSkinId()
        }
        set {
            Page_SetSkinId(newValue)
        }
    }

    /**
    Get get current path the page was accessed with.
    */
    public static var path : String? {
        var path : _PagePathInfo = _PagePathInfo()
        Page_GetPath(&path)
        if(path.ptr != nil && path.len != 0) {
                return fromUTF8_check(path.ptr!, path.len)
        }
        return nil
    }

    /**
    Get get current domain the page was accessed with.
    */
    public static var domain : StaticDomain {
        var domain : StaticDomain? = nil
        Page_GetDomain(&domain)
        return domain!
    }

    /**
    Returns true if the current view is the target for a get or post request.
    A page can consist of multiple parts which can be targeted.
    */
    public static var target : Bool {
        return Page_GetTarget() == 0 ? false : true
    }

    /** Get the current request method.

    - SeeAlso: HTTPRequestType
    */
    public static var requestMethod : HTTPRequestType {
        return HTTPRequestType(rawValue:Page_GetRequestType())!
    }

    /**
    Get the root of the page in the run tree. The root can be used to get a menu for that part or the run tree.

    - SeeAlso: MenuItem
    */
    public static var root : Page {
        return PrivateInterface.getPage(Page_GetRoot())
    }

    /**
    Get the current page.
    */
    public static var current : Page {
        return PrivateInterface.getPage(Page_GetCurrent())
    }
}
