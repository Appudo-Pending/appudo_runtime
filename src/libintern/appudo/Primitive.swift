/*
    Primitive.swift is part of Appudo

    Copyright (C) 2015-2016
        1c411a37ab0d1e379627bbabc5b769a16c007a555ab1a667a84653a4c546f1a1 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

public func Int_SetValue(result : UnsafeMutablePointer<Int?>, _ value : CLong) -> Void {
    result.pointee = value
}

public func Bool_SetValue(result : UnsafeMutablePointer<Bool?>, _ value : CInt) -> Void {
    result.pointee = value == 1
}
