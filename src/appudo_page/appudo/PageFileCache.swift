/*
    PageFileCache.swift is part of Appudo

    Copyright (C) 2015-2016
        bc00940f92e19b5d84931da5bbb6bce10b8e341bdd9d98d016513a164e790c05 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge
import libappudo
import Foundation

public struct _PageFileCacheHolder {
    public var fileFd : CInt = -1
    public var sizeLimit : CLong = 0
    public var offset : CLong = 0
    public var memCache : CBool = false
    public var _data : Int8 = 0
}

public enum PageCache : Int {
    case NOTCACHED   = 0
    case CACHED      = 1
    case NOTMODIFED  = 2
}

/**
PageFileCache is used to cache the result of a page run with a file.
*/
public struct PageFileCache : StringData {
    let _cache : UnsafeMutablePointer<_PageFileCacheHolder>
    /**
    KeyFlags contains the parts used to generate a unique key for the cache entry.
    */
    public struct KeyFlags : OptionSet {
        public let rawValue: Int32
        public init(rawValue:Int32) {
            self.rawValue = rawValue
        }

        public static let PREQUEST_METHOD = KeyFlags(rawValue: 1 << 0)
        public static let SCHEMA          = KeyFlags(rawValue: 1 << 1)
        public static let HOST            = KeyFlags(rawValue: 1 << 2)
        public static let PORT            = KeyFlags(rawValue: 1 << 3)
        public static let PATH            = KeyFlags(rawValue: 1 << 4)
        public static let GET_VARS        = KeyFlags(rawValue: 1 << 5)
        public static let POST_VARS       = KeyFlags(rawValue: 1 << 6)
        public static let COOKIE_VARS     = KeyFlags(rawValue: 1 << 7)
        public static let LOGIN           = KeyFlags(rawValue: 1 << 8)
        public static let SKIN            = KeyFlags(rawValue: 1 << 9)
        public static let LANG            = KeyFlags(rawValue: 1 << 10)
        public static let ALL             = KeyFlags(rawValue: 0x1FFFFFFF)

        public func has(_ m : KeyFlags) -> Bool {
            return rawValue & m.rawValue == m.rawValue
        }

        public func without(_ m : KeyFlags) -> KeyFlags {
            return KeyFlags(rawValue:rawValue & ~m.rawValue)
        }
    }

    public var lastModified : Date {
        let time = Page_LastModified()
        do {
            return try Date.fromIntervalSince1970(TimeInterval(time))
        } catch {
            fatalError("wrong date")
        }
    }

    /**
    Set the file for reading or writing the cache data. The file must be open.

    - parameter file: The file to use.
    - parameter sizeLimit: The size limit to read from file.
    - parameter offset: The offset to start from.
    - parameter memCache: additionally try to use the memory cache for the file.
    */
    public func setFile(_ file : FileItem, _ sizeLimit : Int = 0, _ offset : Int = 0, memCache : Bool = false) -> Bool {
        let fileFd = file.fileFd
        if(Page_IsCache(_cache) != 0 && fileFd != -1) {
            _cache.pointee.fileFd = FileItem_DupFile(fileFd)
            _cache.pointee.sizeLimit = sizeLimit
            _cache.pointee.offset = offset
            _cache.pointee.memCache = memCache
            return true
        }
        return false
    }

    /**
    Get a unique key for the run that created the PageFileCache.

    - parameter maxLen: The maximum length allowed for the resulting String.
    - parameter flags: The parts used to generate the key.
    */
    public func getKey(_ maxLen : Int32, _ flags : KeyFlags = .ALL) -> StringData? {
        Page_GetKey(_cache, flags.rawValue)
        return self
    }

    public var _info : (AnyObject?, UnsafePointer<Int8>) {
        if(Page_IsCache(_cache) != 0) {
            return withUnsafePointer(to:&_cache.pointee._data) {
                return (nil as AnyObject?, $0)
            }
        }

        return (nil, String_empty())
    }
}
