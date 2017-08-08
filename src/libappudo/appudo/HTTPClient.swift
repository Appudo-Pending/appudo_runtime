/*
    HTTPClient.swift is part of Appudo

    Copyright (C) 2015-2016
        4bea15c834854bf9670dc6a1cbc9a9dda7cf418ef53b8edbb11b3df946a0c45e source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge

/**
HTTPClient is used to transfer data to and from internal or external REST APIs with the http protocol.
*/
public final class HTTPClient {
    /**
    HTTPVersion contains the HTTP versions useable with the HTTPClient.
    */
    public struct HTTPVersion : OptionSet {
        public let rawValue: Int32
        public init(rawValue:Int32) {
            self.rawValue = rawValue
        }

        /** HTTP Version "1.1".  */
        public static let V11 = HTTPVersion(rawValue: 11)
    }

    enum State : Int {
        case Pending = 0
        case Ok = 1
        case Error = 2
    }
    var _state : State = .Ok
    var _headers : Dictionary<String, String> = [:]
    var _cookies : [String] = []
    var _files : [FileItem] = []
    var _link : Link? = nil
    var _type : HTTPRequestType = HTTPRequestType.GET
    var _result : _FilePath? = nil
    var _connection : CInt = -1

    /**
    Get a HTTPClient instance for a link.

    - parameter type: The request type for the request.
    - parameter link: The target link for the request.

    - SeeAlso: Link
    - SeeAlso: HTTPRequestType
    */
    public static func get(_ type : HTTPRequestType, _ link : Link) -> HTTPClient {
        let ret = HTTPClient()
        ret._type = type
        ret._link = link
        return ret
    }

    /**
    Get a HTTPClient instance for a link as a POST request.

    - parameter link: The target link for the request.

    - SeeAlso: Link
    */
    public static func POST(_ link : Link) -> HTTPClient {
        let ret = HTTPClient()
        ret._type = HTTPRequestType.POST
        ret._link = link
        return ret
    }

    /**
    Get a HTTPClient instance for a link as a GET request.

    - parameter link: The target link for the request.

    - SeeAlso: Link
    */
    public static func GET(_ link : Link) -> HTTPClient {
        let ret = HTTPClient()
        ret._type = HTTPRequestType.GET
        ret._link = link
        return ret
    }

    /**
    Get a HTTPClient instance for a link as a DELETE request.

    - parameter link: The target link for the request.

    - SeeAlso: Link
    */
    public static func DELETE(_ link : Link) -> HTTPClient {
        let ret = HTTPClient()
        ret._type = HTTPRequestType.DELETE
        ret._link = link
        return ret
    }

    /**
    Close the current connection to the peer.
    */
    public func close() -> Bool {
        if(!isPending && _connection != -1) {
            HTTPClient_Close(_connection)
            _connection = -1
            return true
        }
        return false
    }

    /**
    Create a keep alive connection to a peer with a link.

    - parameter link: The target link to connect to.
    */
    public func connect(_ link : Link) -> AsyncBool {
        var ret = AsyncBool(false)
        if(!isPending) {
            _ = close()
            struct ArgPad {
                var url : AnyObject? = nil
                var body : AnyObject? = nil
            }
            var pad = ArgPad()
            let curl = ret.arg(_link!.toString(), &pad.url)
            ret.store(&pad)
            _state = .Pending
            HTTPClient_Connect(&ret, toUnretainedVoid(self), curl)
            if(ret.hasError) {
                _state = .Error
            }
        }
        return ret
    }

    /**
    Send an HTTP request to the target with optional body data.

    - parameter body: The body data to send.
    - parameter removeEncoding: Remove the encoding of the result file.
    - parameter updateHeaders: Update the headers with the received data.
    - parameter updateCookies: Update the cookies with the received data.
    - parameter httpVersion: The HTTP version used with the send.
    */
    public func send(_ body : String? = nil, removeEncoding : Bool = true, updateHeaders : Bool = true, updateCookies : Bool = true, httpVersion : HTTPVersion = .V11) -> AsyncBool {
        var ret = AsyncBool(false)
        if(!isPending && _link != nil) {
            struct ArgPad {
                var url : AnyObject? = nil
                var body : AnyObject? = nil
            }
            var pad = ArgPad()
            let curl = ret.arg(_link!.toString(), &pad.url)
            var cbody : UnsafePointer<Int8>? = nil
            if(body != nil) {
                cbody = ret.arg(body!, &pad.body)
            }
            ret.store(&pad)
            var info = HTTPSendInfo()
            info.type = CInt(_type.rawValue)
            info.cookies = _cookies.count != 0
            info.headers = _headers.count != 0
            info.files = _files.count != 0
            info.removeEncoding = removeEncoding
            info.updateHeaders = updateHeaders
            info.updateCookies = updateCookies
            info.version = httpVersion.rawValue
            info.con = _connection
            _state = .Pending
            HTTPClient_Send(&ret, toUnretainedVoid(self), curl, cbody, &info)
            if(ret.hasError) {
                _state = .Error
            }
        }
        return ret
    }

    /**
    Get and set the files to send with the request.
    */
    public var postFiles : [FileItem] {
        get {
            return _files
        }
        set {
            _files = newValue
        }
    }

    /**
    Get and set the cookies to send with the request.
    */
    public var cookies : [String] {
        get {
            return _cookies
        }
        set {
            _cookies = newValue
        }
    }

    /**
    Get and set additional headers to send with the request.
    */
    public var headers : Dictionary<String, String> {
        get {
            return _headers
        }
        set {
            _headers = newValue
        }
    }

    /**
    Get and set the encoding to send with the request.
    */
    public var encoding : String {
        get {
            return _headers["Encoding"] ?? ""
        }
        set {
            _headers["Encoding"] = newValue
        }
    }

    /**
    Returns true if the target is using the ssl protocol.
    */
    public var isSSL : Bool {
        get {
            return _link != nil ? _link!.isSSL : false
        }
    }

    /**
    Get and set the request type for the request.

    - SeeAlso: HTTPRequestType
    */
    public var type : HTTPRequestType {
        get {
            return _type
        }
        set {
            _type = newValue
        }
    }

    /**
    Returns true if the current request has not finished.
    */
    public var isPending : Bool {
        return _state == .Pending
    }

    /**
    Returns true if the request has failed.
    */
    public var hasError : Bool {
        return _state == .Error
    }

    /**
    Returns the body data as an unlinked file.

    - SeeAlso: FileItem
    */
    public var bodyData : FileItem? {
        return _state != .Ok || _result == nil ? nil : FileItem(_result!)
    }

    /**
    Returns the body data as String.
    */
    public var bodyText : String? {
        var data = bodyData
        if(data != nil) {
            return <!data!.readAsText()
        }
        return nil
    }
}
