/*
    SQLQry_Private.swift is part of Appudo

    Copyright (C) 2015-2016
        529fa9a39aa978e22b253d7636409ca95bd62a7a69442932bad54b470f47cd5a source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

public extension PrivateInterface {
    public static func getSQLQryPtr(_ qry : SQLQry) -> UnsafePointer<CInt> {
        return withUnsafePointer(to:&qry._data) {
            return $0
        }
    }

    public static func setSQLQryError(_ qry : SQLQry, _ ptr : UnsafePointer<Int8>, _ len : CLong) -> Void {
        qry._error = .EXT_MSG(fromUTF8_nocheck(ptr, len))
    }

    public static func setSQLQryResult(_ qry : SQLQry, _ data : CInt, _ numRows : CLong, _ numCols : CLong) -> Void {
        qry._data = data
        qry._numRows = numRows
        qry._numCols = numCols
    }
}
