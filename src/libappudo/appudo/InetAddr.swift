/*
    InetAddr.swift is part of Appudo

    Copyright (C) 2015-2016
        bc00940f92e19b5d84931da5bbb6bce10b8e341bdd9d98d016513a164e790c05 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge

public enum InetAddrType : CInt {
    case Invalid = 0
    case INET    = 2
    case INET6   = 10
}

public enum InetAddr {
    case Invalid
    case V4(addr: sockaddr_in)
    case V6(addr: sockaddr_in6)

    public func toString() -> AsyncStruct<String> {
        var ret = AsyncStruct<String>(nil)
        switch(self) {
            case .V4(var addr):
                withUnsafePointer(to:&addr) {
                    let ptr = UnsafeMutableRawPointer(mutating:$0).assumingMemoryBound(to:sockaddr.self)
                    InetAddr_ToString(&ret, ptr);
                }
            case .V6(var addr):
                withUnsafePointer(to:&addr) {
                    let ptr = UnsafeMutableRawPointer(mutating:$0).assumingMemoryBound(to:sockaddr.self)
                    InetAddr_ToString(&ret, ptr);
                }
            case .Invalid:
                fallthrough
            default:
                ret.errorValue = AppudoError.INVAL
        }
        return ret
    }
}
