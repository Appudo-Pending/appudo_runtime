/*
    Link.swift is part of Appudo

    Copyright (C) 2015-2016
        48c43cf3fa27f38651415841249beb404bae737b543781675489887c65abc8b7 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo
import libappudo_bridge

extension Link {
    /**
    Create a Link to the current page as a whole.
    */
    static public func toSelf() -> AsyncValue<Link?> {
        var ret = AsyncValue<Link?>(nil)
        Link_toPage(&ret, Page.current.id)
        return ret
    }

    /**
    Create a Link to the current view.
    */
    static public func toView(_ viewId : Int, _ viewIdx : Int = 0) -> AsyncValue<Link?> {
        var ret = AsyncValue<Link?>(nil)
        Link_toView(&ret, viewId, viewIdx)
        return ret
    }
}
