/*
    WebSocketEvent.swift is part of Appudo

    Copyright (C) 2015-2016
        4bea15c834854bf9670dc6a1cbc9a9dda7cf418ef53b8edbb11b3df946a0c45e source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge
import libappudo

/**
WebSocketEventType holds the different types of websocket events.
*/
public enum WebSocketEventType : Int {
    case TEXT_MESSAGE = 0
    case BYTE_MESSAGE = 1
    case CONTROL      = 2
    case START        = 3
    case CONNECT      = 4
    case DISCONNECT   = 5
    case ERROR        = 6
    case COMPLETE     = 7
}

/**
The websocket run receives WebSocketEvent items on events like incomming messages or errors.
*/
public struct WebSocketEvent {
    public init(id : WebSocketEventType, data : Any?, target : Socket) {
        _id = id
        _data = data
        _target = target
    }

    /**
    Returns true if data is a text message.
    */
    public var isText : Bool {
        return _id == .TEXT_MESSAGE
    }

    /**
    Returns the socket for the message.
    */
    public var target : Socket {
        return _target
    }

    /**
    Returns the data for the message.
    */
    public var data : Any? {
        return _data
    }

    var _id : WebSocketEventType
    var _data : Any?
    var _target : Socket
}
