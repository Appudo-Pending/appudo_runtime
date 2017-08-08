/*
    Mail.swift is part of Appudo

    Copyright (C) 2015-2016
        48c43cf3fa27f38651415841249beb404bae737b543781675489887c65abc8b7s source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge

/**
Mail is used to send mails.
*/
public struct Mail {
    private var _sender : String
    /**
    The headers to send with the mail.
    */
    public var headers : Dictionary<String, String> = [:]
    /**
    The files to send with the mail.
    */
    public var attachments : [FileItem] = []

    private init(_ sender : String) {
        _sender = sender
    }

     /**
     A Mail must be created with a sender domain to prevent spam.

     - parameter name: The sender name to add to the domain.
     - parameter domain: The sender domain for the mail.
     */
    public static func from(_ name : String, _ domain : StaticDomain) -> AsyncStruct<Mail> {
        let email = name + String(describing:domain.host)
        var ret = AsyncStruct<Mail>(Mail(email))
        struct ArgPad {
            var email : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cemail = ret.arg(email, &pad.email)
        ret.store(&pad)
        Mail_GetFrom(&ret, cemail)
        return ret
    }

    struct MailInfo {
        var numHeaders : CInt = 0
        var numAttachments : CInt = 0
        var cfrom : UnsafePointer<Int8>? = nil
        var cto : UnsafePointer<Int8>? = nil
        var csubject : UnsafePointer<Int8>? = nil
        var cbody : UnsafePointer<Int8>? = nil
    }

    /**
    Send a mail with a String body.

    - parameter to: The receiver for the mail to send.
    - parameter subject: The subject for the mail to send.
    - parameter body: The body for the mail to send.
    */
    mutating public func send(_ to : String, _ subject : String, _ body : String) -> AsyncBool {
        var ret = AsyncBool(false)
        struct ArgPad {
            var from : AnyObject? = nil
            var to : AnyObject? = nil
            var subject : AnyObject? = nil
            var body : AnyObject? = nil
        }
        var minfo = MailInfo()
        var pad : ArgPad = ArgPad()
        minfo.cfrom = ret.arg(_sender, &pad.from)
        minfo.cto = ret.arg(to, &pad.to)
        minfo.csubject = ret.arg(subject, &pad.subject)
        minfo.cbody = ret.arg(body, &pad.body)
        ret.store(&pad)
        Mail_SendText(&ret, &self, &minfo)
        return ret
    }

    /**
    Send a mail with data from a Link as body.

    - parameter to: The receiver for the mail to send.
    - parameter subject: The subject for the mail to send.
    - parameter link: The link to send as body for the mail.

    - SeeAlso: Link
    */
    public func send(_ to : String, _ subject : String, _ link : Link) -> AsyncBool {
        return AsyncBool(false)
    }
}
