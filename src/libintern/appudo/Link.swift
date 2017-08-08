/*
    Link.swift is part of Appudo

    Copyright (C) 2015-2016
        48c43cf3fa27f38651415841249beb404bae737b543781675489887c65abc8b7 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo

public func Async_SetLink(async : UnsafeMutablePointer<AsyncValue<Link?>>, entry : UnsafePointer<Int8>, _ entryLen : CInt, _ type : CInt, _ isSSL : CBool) -> Void {
    async.pointee.rawValue = Link(fromUTF8_nocheck(entry, Int(entryLen)), LinkType(rawValue:type) ?? LinkType.Page, Bool(isSSL))
}
