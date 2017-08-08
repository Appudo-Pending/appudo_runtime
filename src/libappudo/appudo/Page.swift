/*
    Page.swift is part of Appudo

    Copyright (C) 2015-2016
        bc00940f92e19b5d84931da5bbb6bce10b8e341bdd9d98d016513a164e790c05 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

/**
A single page run from the run tree is represented by a Page.
*/
public struct Page {
    let _id : Int

    init(_ id : Int)
    {
        _id = id
    }

    /**
    Returns the unique id of the page.
    */
    public var id : Int {
        return _id
    }
}
