/*
    Socket.swift is part of Appudo

    Copyright (C) 2015-2016
        4bea15c834854bf9670dc6a1cbc9a9dda7cf418ef53b8edbb11b3df946a0c45e source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

/**
A single connection to a run is managed with a Socket.
A Socket is not the same as a linux socket.
It is not possible to send data to the Socket of a different run.
It is even possible for two runs to have the same Socket value but different peers.
Some properties are static and refer to the current active socket of the run.
*/
public struct Socket {
    let _value : UInt32
    public init(v : UInt32) {
        _value = v
    }

    /**
    Returns the raw socket value.
    */
    public var value : UInt32 {
        return _value
    }
}
