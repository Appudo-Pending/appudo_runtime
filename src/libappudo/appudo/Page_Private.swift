/*
    Page_Private.swift is part of Appudo

    Copyright (C) 2015-2016
        bc00940f92e19b5d84931da5bbb6bce10b8e341bdd9d98d016513a164e790c05 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

public struct _PagePathInfo {
    public init() {
    }
    public var ptr : UnsafePointer<Int8>? = nil
    public var len : CLong = 0
}

public extension PrivateInterface {
    public static func getPage(_ id : Int) -> Page {
        return Page(id)
    }
}
