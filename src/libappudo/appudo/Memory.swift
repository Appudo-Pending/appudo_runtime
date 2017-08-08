/*
    Memory.swift is part of Appudo

    Copyright (C) 2015-2016
        8c363e70b3d1ed86d1c8bf704f4c7f423ce1d6c1d0bb40f933cbd46dd4cf1304 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge

/**
Memory provides information about the used and maximum memory of the current run.
The maximum memory each run can use is limited.
If there is no memory pressure a run can use more memory than its initial maximum.
If there is memory pressure the runs with higher memory usage are slowed down or terminated.
A run should be designed to not use more memory than the allowed maximum at any time.
*/
public struct Memory {
    /**
    Returns the used memory of the current run in bytes.
    */
    static public var used : Int {
        var ret : CLong = 0
        Memory_GetUsed(&ret)
        return ret
    }

    /**
    Returns the maximum usable memory of the current run in bytes.
    */
    static public var max : Int {
        var ret : CLong = 0
        Memory_GetMax(&ret)
        return ret
    }
}
