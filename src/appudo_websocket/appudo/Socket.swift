/*
    Socket.swift is part of Appudo

    Copyright (C) 2015-2016
        4bea15c834854bf9670dc6a1cbc9a9dda7cf418ef53b8edbb11b3df946a0c45e source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge
import libappudo


extension Socket {
    /**
    The normal mode for socket is to store the current login user.
    For custom data handling dataMode must be set to true.
    This is a static property for the current active socket of the run.
    */
    static public var dataMode : Bool {
        get {
            return WebSocket_GetDataMode() != 0
        }
        set {
            WebSocket_SetDataMode(newValue ? 1 : 0)
        }
    }

    /**
    If in dataMode the socket can store an Int.
    This is a static property for the current active socket of the run.

    - SeeAlso: dataMode
    */
    static public var data : Int {
        get {
            return WebSocket_GetData()
        }
        set {
            WebSocket_SetData(newValue)
        }
    }

    /**
    Normally a run that uses sockets does have notification events when errors happen.
    With the async send APIs it is not possible to know when a send is complete without an error.
    With notifyComplete set to true for this socket there are notification events for completed sends without errors.
    This is a static property for the current active socket of the run.
    */
    static public var notifyComplete : Bool {
        get {
            return WebSocket_GetNotify() != 0
        }
        set {
            WebSocket_SetNotify(newValue ? 1 : 0)
        }
    }

    /**
    Close the socket connection.
    */
    public func Close(_ hard : Bool = false) -> Void {
        WebSocket_Close(value, hard ? 1 : 0)
    }
}
