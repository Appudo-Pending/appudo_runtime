/*
    Assert.swift is part of Appudo

    Copyright (C) 2015-2016
        0f751a1d3444d63f571768174ba74ddb110c7375c07f4c78efe0673d530054ee source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo
import libappudo_bridge

/**
Assert function for debug purposes.

- parameter value: The value that must be evaluated to true.
- parameter result: The output string used when the value evaluates to false.
- parameter file: The file used for the output.
- parameter line: The line used for the output.
*/
public func appudo_assert(_ value: @autoclosure () -> Bool, _ result: @autoclosure () -> String, _ file: StaticString = #file, _ line: UInt = #line) -> Void {
    if(value() == false) {
        let msg = "ERROR in \(file) at \(line): \(result())<br>\n";
        Error_Assert(msg);
        print(msg)
    }
}

public func appudo_initPrint() -> Void {
    Error_InitPrint()
}

public func appudo_getPrint() -> FileItem {
    var f : FileItem? = nil
    Error_GetPrint(&f);
    return f!;
}

public func _strcmp(_ a : String, _ b : String) -> Int {
    return Int(String_strcoll(a, b))
}

public func _strcmp1(_ a : ContiguousArray<UInt8>, _ b : String) -> Int {
    let t : (AnyObject?, UnsafePointer<Int8>)  =  _convertConstStringToUTF8PointerArgument(b)
    let lenB = Int(String_len(t.1))
    if(lenB != a.count) {
        return 1
    }
    return a.withUnsafeBufferPointer {
        let base = UnsafeRawPointer($0.baseAddress!).assumingMemoryBound(to:Int8.self)

        for i in 0...lenB-1 {
            if(base.advanced(by:i).pointee != t.1.advanced(by:i).pointee) {
                return 1
            }
        }
        return 0
    }
}

public func _strlen(_ a : String) -> Int {
    return Int(String_len(a))
}
