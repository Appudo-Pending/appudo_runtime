/*
    Redirect.swift is part of Appudo

    Copyright (C) 2015-2016
        4bea15c834854bf9670dc6a1cbc9a9dda7cf418ef53b8edbb11b3df946a0c45e source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge
import libappudo

/**
Possible states to redirect a page.
*/
public enum RedirectState : Int32 {
    case STATE_303 = 303
}

/**
Redirect is used to redirect pages to other locations.
*/
public struct Redirect {
    /**
    Redirect a page to another location.

    - parameter link: The target to redirect to.
    - parameter state: The state to redirect with.
    */
    public static func to(_ target : Link, _ state : RedirectState) -> Bool {
        var vholder : AnyObject? = nil
        let cvalue = AsyncArg.save(target.toString(), &vholder)
        return Redirect_Set(cvalue, target.isLocal ? 1 : 0, state.rawValue) != 0
    }
}
