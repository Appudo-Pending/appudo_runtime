/*
    SQLQry.swift is part of Appudo

    Copyright (C) 2015-2016
        529fa9a39aa978e22b253d7636409ca95bd62a7a69442932bad54b470f47cd5a source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge

/**
SQLQryError contains the error for an SQLQry.
*/
public enum SQLQryError {
        case NONE
        case PENDING
        case EXT_MSG(String)
        case UNKNOWN

        /**
        Returns the String message for the error.
        */
        public var errMsg : String {
            switch(self) {
                case .NONE:
                    fallthrough
                case .PENDING:
                    return "no error"
                case .EXT_MSG(let v):
                    return v
                case .UNKNOWN:
                    return "unknown error"
            }
        }
}

/**
SQLQryValue holds a single SQLQry result value.

*/
public struct SQLQryValue {
    let _data : CInt
    let _row : Int
    let _col : Int

    init(data : CInt, row : Int, col : Int) {
        _data = data
        _row = row
        _col = col
    }

    /**
    Return the query result value as String.

    */
    public var string : String? {
        var res : String? = nil
        SQLQry_GetAsText(&res, _data, _row, _col)
        return res
    }

    /**
    Return a query result value as Int.

    */
    public var int : Int? {
        var res : Int? = nil
        SQLQry_GetAsInt(&res, _data, _row, _col)
        return res
    }

    /**
    Return a query result value as Bool.

    */
    public var bool : Bool? {
        var res : Bool? = nil
        SQLQry_GetAsBool(&res, _data, _row, _col)
        return res
    }
}

/**
SQLQry is used to access database tables registered with the run.
The number of concurrent open query results of a run can be restricted.
It is also possible for a run to close all open results when it leaves the current execution stack.
It is best practice to close a query as soon as possible and store needed values in other structures.
*/
public final class SQLQry {
    var _data : CInt = 0
    var _numRows : Int = 0
    var _numCols : Int = 0
    var _modeNative : Bool = true
    var _error : SQLQryError = .NONE
    var _qry : StaticString
    var _values : [Any] = []

    /**
    Create an SQLQry instance. For security reasons the query string must be statically known at compile time.

    - parameter qry: The query string used to access the database.
    */
    @inline(never)
    public init(_ qry : StaticString) {
        _qry = qry
    }

    deinit {
        close()
    }

    /**
    Returns true if there is an open transaction.

    - SeeAlso: begin
    */
    public static var inTransaction : Bool {
        return SQLQry_InTransaction() != 0
    }

    /**
    Start a new transaction. There must not be an active transaction.
    */
    public static func begin() -> AsyncBool {
        var res = AsyncBool(false)
        let rd = PrivateInterface.getRunData()
        if(rd.qryStore == nil) {
            rd.InitQryStore()
        }
        SQLQry_Begin(&res, rd.qryStore!.firstElementAddress)
        return res
    }

    /**
    End the current transaction. There must be an active transaction.
    */
    public static func end() -> AsyncBool {
        var res = AsyncBool(false)
        SQLQry_End(&res)
        return res
    }

    /**
    Rollback the current transaction. There must be an active transaction.
    */
    public static func rollback() -> AsyncBool {
        var res = AsyncBool(false)
        SQLQry_Rollback(&res)
        return res
    }

    /**
    Close all open query results.
    */
    public static func closeAll() -> Bool {
        return SQLQry_CloseAll() != 0
    }

    /**
    Returns true if the current query has not finished.
    */
    public var isPending : Bool {
        switch(_error) {
            case .PENDING:
                return true
            default:
                return false
        }
    }

    /**
    Get and set the values used for the query.
    */
    public var values : [Any] {
        get {
            return _values
        }
        set {
            _values = newValue
        }
    }

    /**
    Execute the query and receive the results.
    */
    public func exec() -> AsyncBool {
        var res = AsyncBool(false)
        if(!isPending) {
            _error = .PENDING
            close()
            SQLQry_Exec(&res, toUnretainedVoid(self), _qry.utf8Start, _modeNative ? 1 : 0, _values.count)
        }
        return res
    }

    /**
    Return a query result value as SQLQryValue.

    - parameter row: The row of the result value.
    - parameter col: The column of the result value.
    */
    public func get(_ row : Int, _ col : Int) -> SQLQryValue {
        return SQLQryValue(data:_data, row:row, col:col)
    }

    /**
    Return a query result value as String.

    - parameter row: The row of the result value.
    - parameter col: The column of the result value.
    */
    public func getAsText(_ row : Int, _ col : Int) -> String? {
        var res : String? = nil
        SQLQry_GetAsText(&res, _data, row, col)
        return res
    }

    /**
    Return a query result value as Int.

    - parameter row: The row of the result value.
    - parameter col: The column of the result value.
    */
    public func getAsInt(_ row : Int, _ col : Int) -> Int? {
        var res : Int? = nil
        SQLQry_GetAsInt(&res, _data, row, col)
        return res
    }

    /**
    Return a query result value as Bool.

    - parameter row: The row of the result value.
    - parameter col: The column of the result value.
    */
    public func getAsBool(_ row : Int, _ col : Int) -> Bool? {
        var res : Bool? = nil
        SQLQry_GetAsBool(&res, _data, row, col)
        return res
    }

    /**
    Return a column name of the query result.

    - parameter col: The column to return the name for.
    */
    public func colName(_ col : Int) -> String? {
        var res : String? = nil
        SQLQry_GetColName(&res, _data, col)
        return res
    }

    /**
    Close the curret query result.
    */
    public func close() -> Void {
        SQLQry_Close(_data)
        _numRows = 0
        _numCols = 0
        _error = .NONE
    }

    /**
    Set to true to use the native mode for the query. In non native mode it is only possible to get result values as String.
    */
    public var nativeMode : Bool {
        get {
            return _modeNative
        }
        set {
            _modeNative = newValue
        }
    }

    /**
    Returns the number of rows for the current query result.
    */
    public var numRows : Int {
        return _numRows
    }

    /**
    Returns the number of columns for the current query result.
    */
    public var numCols : Int {
        return _numCols
    }

    /**
    Returns the error for the current query.
    */
    public var errCode : SQLQryError {
        return _error
    }

    /**
    Returns true if the query has failed.
    */
    public var hasError : Bool {
        switch(_error) {
            case .PENDING:
                fallthrough
            case .NONE:
                return false
            default:
                return true
        }
    }

    /**
    Returns the error message for the current query.
    */
    public var errMsg : String {
        return _error.errMsg
    }
} 
