/*
    toplevel.swift is part of Appudo

    Copyright (C) 2015-2016
        4bea15c834854bf9670dc6a1cbc9a9dda7cf418ef53b8edbb11b3df946a0c45e source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge

public func fromUTF8_check(_ ptr : UnsafePointer<Int8>, _ len : CLong) -> String {
    let start : UnsafeMutablePointer<UTF8.CodeUnit> = UnsafeMutableRawPointer(mutating:ptr).assumingMemoryBound(to:UTF8.CodeUnit.self)
    return String._fromCodeUnitSequence(UTF8.self,
                                      input: UnsafeBufferPointer(
                                      start: start,
                                      count: Int(len))) ?? ""

}

public func fromUTF8_nocheck(_ ptr : UnsafePointer<Int8>, _ len : CLong) -> String {
    let start : UnsafeMutablePointer<UTF8.CodeUnit> = UnsafeMutableRawPointer(mutating:ptr).assumingMemoryBound(to:UTF8.CodeUnit.self)
    return String._fromWellFormedCodeUnitSequence(UTF8.self,
                                      input: UnsafeBufferPointer(
                                      start: start,
                                      count: Int(len)))
}

public func dump(_ data : Any) {
	
}

func toRetainedVoid<T : AnyObject>(_ ptr : T) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(Unmanaged.passRetained(ptr).toOpaque())
}

func toUnretainedVoid<T : AnyObject>(_ ptr : T) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(Unmanaged.passUnretained(ptr).toOpaque())
}

func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    var prefix = ""
    for item in items {
        print_str(prefix)
        print_str(String(describing:item))
        prefix = separator
    }
    //print_str(terminator)
}
