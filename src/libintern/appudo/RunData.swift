/*
    RunData.swift is part of Appudo

    Copyright (C) 2015-2016
        bc00940f92e19b5d84931da5bbb6bce10b8e341bdd9d98d016513a164e790c05 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge
import libappudo

/*
 * RunData itself not reference counted and not allocated. 
 */
public func RunData_Init() {
    let ptr = getSwiftRunData().assumingMemoryBound(to:RunData.self)
    ptr.initialize(to:PrivateInterface.newRunData())
}

/*
 * RunData itself not reference counted and not allocated. 
 */
public func RunData_Release() {
    let ptr = getSwiftRunData().assumingMemoryBound(to:RunData.self)
    ptr.deinitialize()
}
