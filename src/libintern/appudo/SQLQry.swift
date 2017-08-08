/*
    SQLQry.swift is part of Appudo

    Copyright (C) 2015-2016
        529fa9a39aa978e22b253d7636409ca95bd62a7a69442932bad54b470f47cd5a source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo

public func SQLQry_GetKeyPtr(_ qry : UnsafeRawPointer) -> UnsafePointer<CInt> {
    let v = Unmanaged<SQLQry>.fromOpaque(qry)
    let q = v.takeUnretainedValue()
    return PrivateInterface.getSQLQryPtr(q)
}

public func SQLQry_GetValues(_ async : UnsafeMutablePointer<AsyncBool>, _ qry : UnsafeRawPointer, _ res : UnsafeMutablePointer<UnsafePointer<Int8>>, _ numValues : CInt) -> UnsafeMutablePointer<Int8>? {
    let v = Unmanaged<SQLQry>.fromOpaque(qry)
    let q = v.takeUnretainedValue()
    let vl = q.values

    if(vl.count != Int(numValues)) {
        return nil
    }
    var pad = ContiguousArray<AnyObject?>(repeating: nil, count: Int(numValues))

    pad.withUnsafeMutableBufferPointer {
        var p = $0.baseAddress!
        var r = res
        for item in vl {
            r.pointee = async.pointee.arg(String(describing:item), &p.pointee)
            r = r.advanced(by:1)
            p = p.advanced(by:1)
        }
    }
    async.pointee.store(&pad)

    let a = async.pointee.toAsync()
    return a?.data
}

public func SQLQry_setResult(_ qry : UnsafeRawPointer, _ qryKey : CInt, _ numRows : CLong, _ numCols : CLong) -> Void {
    let v = Unmanaged<SQLQry>.fromOpaque(qry)
    let q = v.takeUnretainedValue()
    PrivateInterface.setSQLQryResult(q, qryKey, numRows, numCols)
}

public func SQLQry_setErrorText(_ qry : UnsafeRawPointer, _ str : UnsafePointer<Int8>, _ len : CLong) -> Void {
    let v = Unmanaged<SQLQry>.fromOpaque(qry)
    let q = v.takeUnretainedValue()
    PrivateInterface.setSQLQryError(q, str, len)
}
