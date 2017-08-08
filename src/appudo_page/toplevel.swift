/*
    toplevel.swift is part of Appudo

    Copyright (C) 2015-2016
        bc00940f92e19b5d84931da5bbb6bce10b8e341bdd9d98d016513a164e790c05 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge

/**
printSub is part of the template engine for pages.
To walk and output a subpart the function is called as often as the subpart should be repeated.
Each subpart has its own function from within printSub must be called.
With the call to printSub the subpart is parsed and nested subparts and markers are executed.
*/
public func printSub() {libappudo_bridge.printSub()}
