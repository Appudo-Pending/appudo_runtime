/*
    StringData_Private.swift is part of Appudo

    Copyright (C) 2015-2016
        ae3453f1d271c32860dc06afd71f3918e396ff5139052cd38c33f6c4fafc98a4 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

public protocol StringData {
    var _info : (AnyObject?, UnsafePointer<Int8>) { get }
}


extension String : StringData {
    public var _info : (AnyObject?, UnsafePointer<Int8>) {
        return _convertConstStringToUTF8PointerArgument(self)
    }
}
