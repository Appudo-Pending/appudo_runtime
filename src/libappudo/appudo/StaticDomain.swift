/*
    StaticDomain.swift is part of Appudo

    Copyright (C) 2015-2016
        bc00940f92e19b5d84931da5bbb6bce10b8e341bdd9d98d016513a164e790c05 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

/**
Each host of an account is identified by a StaticDomain.
This can be used to set a different skin for a run dependent on the host used to view it.
*/
public struct StaticDomain {
    let _id : Int
    let _host : StaticString
    init(_ id : Int, _ host : StaticString) {
        _id = id
        _host = host
    }

    /**
    Returns the unique id for the host.
    */
    public var id : Int {
        return _id
    }

    /**
    Returns the host as string.
    */
    public var host : StaticString {
        return _host
    }
}
