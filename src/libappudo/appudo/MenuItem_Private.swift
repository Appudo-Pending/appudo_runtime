/*
    MenuItem_Private.swift is part of Appudo

    Copyright (C) 2015-2016
        8c363e70b3d1ed86d1c8bf704f4c7f423ce1d6c1d0bb40f933cbd46dd4cf1304 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.appudo.com/LICENSE.txt for more information
*/

public extension PrivateInterface {
    public static func getMenuItem(_ path : _MenuPath, _ index : Int32 = 0) -> MenuItem {
        return MenuItem(path, index)
    }

    public static func getMenuData(entry : String, name : String, firstChild : Int32, numChildren : Int32, moduleId : Int, isSSL : Bool, isActive : Bool) -> _MenuData {
        return _MenuData(entry:entry,
                        name:name,
                        firstChild:firstChild,
                        numChildren:numChildren,
                        moduleId:moduleId,
                        isSSL:isSSL,
                        isActive:isActive)
    }
}

public struct _MenuData {
    let _entry : String
    let _name : String
    public var _firstChild : Int32
    public var _numChildren : Int32
    let _moduleId : Int
    let _isSSL : Bool
    let _isActive : Bool
    init(entry : String, name : String, firstChild : Int32, numChildren : Int32, moduleId : Int, isSSL : Bool, isActive : Bool) {
        _entry = entry
        _name = name
        _firstChild = firstChild
        _numChildren = numChildren
        _moduleId = moduleId
        _isSSL = isSSL
        _isActive = isActive
    }
}

public protocol _MenuPath {
    subscript(index: Int) -> _MenuData { get }
}
