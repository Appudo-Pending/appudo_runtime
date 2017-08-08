/*
    FileView.swift is part of Appudo

    Copyright (C) 2015-2016
        ae3453f1d271c32860dc06afd71f3918e396ff5139052cd38c33f6c4fafc98a4 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge

/**
The FileView is used to hand over a partial view of a file to other APIs.

*/
public struct FileView {
    internal var _offset : Int
    internal var _size : Int
    internal var _source : FileSendSource
    internal init(_ source : FileSendSource, offset : Int = 0, size : Int = Int.max) {
        _offset = offset
        _size = size
        _source = source
    }
}
