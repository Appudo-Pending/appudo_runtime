/*
    AsyncDelay.swift is part of Appudo

    Copyright (C) 2015-2016
        529fa9a39aa978e22b253d7636409ca95bd62a7a69442932bad54b470f47cd5a source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

public struct AsyncDelayData
{
    public init(millis:Int)
    {
    }
}

/**
An AsyncDelay can delay execution of code to a time where at least the specified milliseconds have passed.
*/
public typealias AsyncDelay =  AsyncValue<AsyncDelayData?> // AsyncStruct<AsyncDelayData>
