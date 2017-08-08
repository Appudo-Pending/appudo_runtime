/*
    Link.swift is part of Appudo

    Copyright (C) 2015-2016
        48c43cf3fa27f38651415841249beb404bae737b543781675489887c65abc8b7 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge

/**
LinkType contains the type of the Link pointing to.
*/
public enum LinkType : Int32 {
    case Page = 0
    case View = 1
    case File = 2
    case Url  = 3
}

/**
Link is used to get and modify http links to different target types.
*/
public struct Link : CustomStringConvertible {
    let _base : String
    let _type : LinkType
    let _isSSL : Bool
    var _params : Dictionary<String, String>
    public init(_ base : String, _ type : LinkType, _ isSSL : Bool = false) {
        _base = base
        _type = type
        _params = [:]
        _isSSL = isSSL
    }

    /**
    Create a link to a page run in the run tree.

    - parameter page: The page to generate the link for.
    */
    static public func toPage(_ page : Page) -> AsyncStruct<Link> {
        var r = AsyncStruct<Link>(nil)
        Link_toPage(&r, page.id)
        return r
    }

    /**
    Create a link to a file accessible by the run.

    - parameter file: The file to generate the link for.
    - parameter forceSSL: Force the connection type to SSL.
    */
    static public func toFile(_ file : FileItem, _ forceSSL : Bool = false) -> Link? {
        var a = file.path;
        let b = "data/pub/"
        let c = "data/"
        if(String_beginsWith(a, a.characters.count, b, b.characters.count) == 0) {
            let r = c.startIndex...c.endIndex;
            a.removeSubrange(r)
            return Link(a, .File, forceSSL)
        }
        return nil
    }

    /**
    Create a link to a custom url.

    If the url parameter starts with "https://" the link is forced to SSL.
    If the url parameter does not start with "https://" it can be forced to SSL with the forceSSL paramter.

    - parameter url: The url to generate the link for.
    - parameter forceSSL: Force the connection type to SSL.
    */
    static public func toUrl(_ url : String, _ forceSSL : Bool = false) -> Link {
        // parse the uri to extract params and ssl
        return Link(url, .Url, forceSSL)
    }

    /**
    Returns the link as a String to print.

    - parameter rel: Return a relative link with respect to the current run.
    */
    public func toString(_ rel : Bool = false) -> String {
        // if url and no host then add one
        var result = ""
        if(rel)
        {
            var num = Page_CountSubPath();
            while(num > 0) {
                result += "../"
                num -= 1;
            }
        }
        switch(_type) {
            case .Page:
                if(rel && result != "") {
                    result.remove(at: result.index(before: result.endIndex))
                }
                result += _base
                for (key, value) in _params {
                    result += "&" + key + "=" + value
                }
            case .View:
                break
            case .File:
                result += _base
                for (key, value) in _params {
                    result += "&" + key + "=" + value
                }
                break
            case .Url:
                result += _base
                for (key, value) in _params {
                    result += "&" + key + "=" + value
                }
                break
        }
        return result
    }

    /**
    Returns true if the link points to a target using SSL.
    */
    public var isSSL : Bool {
        return _isSSL
    }

    /**
    Returns true if the link points to a local target.
    */
    public var isLocal : Bool {
        switch(_type) {
        case .Url:
            return false
        default:
            return true
        }
    }

    /**
    */
    public var description : String {
        return toString()
    }

    /**
    Url parameters are added with "link[name] = value".

    - parameter name: The name to set the value for.
    */
    public subscript(name: String) -> String {
        get {
            return _params[name] ?? ""
        }
        set {
            _params[name] = newValue
        }
    }
}
