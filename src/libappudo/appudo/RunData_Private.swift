/*
    RunData_Private.swift is part of Appudo

    Copyright (C) 2015-2016
        bc00940f92e19b5d84931da5bbb6bce10b8e341bdd9d98d016513a164e790c05 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge

public struct _UploadHolder
{
    public init() {
    }
    public var abort : CBool = false
}

public class RunData {
    init() {}
    deinit {
        var n = Int8(0)
        _ = _async.isPending(&n)

        if(_qryStore != nil) {
            var res = AsyncBool(false)
            SQLQry_End(&res)
            _ = <!res != false
        }
    }
    public var stringStore : [String] = []
    private var _qryStore : ManagedCharBuffer? = nil
    private var _async : AsyncOnSuccess<Int8> = AsyncOnSuccess()
    private var _redirect : Link? = nil

    public func InitQryStore() {
        if(_qryStore == nil) {
            _qryStore = ManagedCharBuffer.create(96)
        }
    }

    public var qryStore : ManagedCharBuffer? {
        return _qryStore
    }
}

public extension PrivateInterface {
    public static func getRunData4Page(_ base : UnsafeMutablePointer<Int8>) -> RunData {
        let ptr = __getSwiftRunData(base).assumingMemoryBound(to:RunData.self)
        return ptr.pointee
    }

    public static func getRunData() -> RunData {
        let ptr = getSwiftRunData().assumingMemoryBound(to:RunData.self)
        return ptr.pointee
    }

    public static func newRunData() -> RunData {
        return RunData()
    }
}
