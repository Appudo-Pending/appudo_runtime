/*
    ErrorEvent.swift is part of Appudo

    Copyright (C) 2015-2016
        4bea15c834854bf9670dc6a1cbc9a9dda7cf418ef53b8edbb11b3df946a0c45e source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge

/**
ErrorEventType holds the different types of error events.
*/
public enum ErrorEventType : Int {
    case PAGE = 0
    case WEBSOCKET = 1
}

/**
A run receives ErrorEvent items on errors.
*/
public struct ErrorEvent {
    public init(id : ErrorEventType, data : Any?) {
        _id = id
        _data = data
    }

    /**
    Returns the data for the message.
    */
    public var data : Any? {
        return _data
    }

    var _id : ErrorEventType
    var _data : Any?
}
