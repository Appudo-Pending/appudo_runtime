/*
    MenuItem.swift is part of Appudo

    Copyright (C) 2015-2016
        8c363e70b3d1ed86d1c8bf704f4c7f423ce1d6c1d0bb40f933cbd46dd4cf1304 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge

/**
The MenuItem is used to walk and access the ordered pages of the run tree.
Mirroring the tree structure of accessible menu pages.

- SeeAlso: Link
*/
public struct MenuItem {
    let _path : _MenuPath
    let _index : Int32
    init(_ path : _MenuPath, _ index : Int32 = 0) {
        _path = path
        _index = index
    }

    private var data : _MenuData {
        return _path[Int(_index)]
    }

    /**
    Get a MenuItem tree with a single page as root.

    - parameter pageId: The id for the root page.
    - parameter height: The height of the tree.
    */
    public static func get(_ pageId : Page, _ height : Int32, shift : Int = 0) -> AsyncValue<MenuItem?> {
        var ret = AsyncValue<MenuItem?>(nil)
        MenuItem_get(&ret, pageId.id, shift, height)
        return ret
    }

    /**
    Get a child of the MenuItem.

    - parameter idx: The index of the child to return.
    */
    public func getChildAt(_ idx : Int) -> MenuItem? {
        return idx >= Int(data._numChildren) ? nil : MenuItem(_path, data._firstChild + Int32(idx))
    }

    /**
    Get the number of children of the MenuItem.
    */
    public var numChildren : Int {
        get {
            return Int(data._numChildren)
        }
    }

    /**
    Returns true if the MenuItem is the item of the current page.
    */
    public var active : Bool {
        get {
            return data._isActive
        }
    }

    /**
    Returns the Link to the page of the MenuItem.
    */
    public var link : Link {
        get {
            return Link(data._entry, LinkType.Page)
        }
    }

    /**
    Returns the name of the page visible in the run tree.
    */
    public var name : String {
        get {
            return data._name
        }
    }
}
