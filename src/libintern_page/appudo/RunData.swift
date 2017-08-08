/*
    RunData.swift is part of Appudo

    Copyright (C) 2015-2016
        bc00940f92e19b5d84931da5bbb6bce10b8e341bdd9d98d016513a164e790c05 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge
import libappudo
import libappudo_special

public func Variable_setGetVar(_ addr : UnsafeMutablePointer<Int32>, _ ptr : UnsafeMutablePointer<Int8>, _ len : CLong) -> CBool {
    let str = fromUTF8_check(ptr, len)
    let v = PrivateInterface.getGetVar(addr, str)
    return v.isValid
}

public func Variable_setPostVar(_ addr : UnsafeMutablePointer<Int32>, _ ptr : UnsafeMutablePointer<Int8>, _ len : CLong) -> CBool {
    let str = fromUTF8_check(ptr, len)
    let v = PrivateInterface.getPostVar(addr, str)
    return v.isValid
}

public func Variable_setCookieVar(_ addr : UnsafeMutablePointer<Int32>, _ keySlot : UnsafeMutableRawPointer, _ ptr : UnsafeMutablePointer<Int8>, _ len : CLong) -> CBool {
    let str = fromUTF8_check(ptr, len)
    let v = PrivateInterface.getCookieVar(addr, keySlot, str)
    return v.isValid
}

public struct StrInfo {
    public let data : UnsafePointer<Int8>
    public let len : CInt
}

public func Upload_Begin(_ info : UnsafeMutablePointer<_UploadHolder>, _ data : UnsafeMutablePointer<StrInfo>, _ type : CInt, _ fkt : @convention(swift) (PageEvent) -> FileItem?) -> CInt {
    let name = fromUTF8_nocheck(data[0].data, Int(data[0].len))
    let parent = data[1].len ==  0 ? nil : fromUTF8_nocheck(data[1].data, Int(data[1].len))
    let subDir = data[2].len ==  0 ? nil : fromUTF8_nocheck(data[2].data, Int(data[2].len))
    let upload = PrivateInterface.getUploadData(info, name, parent, subDir, type == 0 ? .FILE : .DIR)
    let ev = PageEvent(id:.UPLOAD, data:upload)
    let file = fkt(ev)
    var ret : CInt = -1
    if var f = file {
        if(f.isOpen) {
            ret = FileItem_DupFile(f.fileFd)
        }
    }
    if(file == nil) {
        return -1;
    }
    return ret
}

public func Page_OnGetCache(id : PageEventType, _ info : UnsafeMutablePointer<_PageFileCacheHolder>,  _ fkt : @convention(swift) (PageEvent) -> PageCache) -> CInt {
    let ev = PageEvent(id:id, data:PrivateInterface.getPageCache(info))
    return CInt(fkt(ev).rawValue)
}

public func Page_OnSetCache(id : PageEventType, _ fkt : @convention(swift) (PageEvent) -> FileItem?) -> CInt {
    let ev = PageEvent(id:id, data:nil)
    let file = fkt(ev)
    var ret : CInt = -1
    if var f = file {
        if(f.isOpen) {
            ret = FileItem_DupFile(f.fileFd)
        }
    }
    if(file == nil) {
        return -1;
    }
    return ret
}

public func Page_Control(id : PageEventType, _ fileFd : CInt, _ len : Int,  _ fkt : @convention(swift) (PageEvent) -> Bool) -> CInt {
    let reader = _UTF8SerialFileReader(fileFd, 0, len)
    let str = String._fromCodeUnitSequence(UTF8.self, input:reader)
    let ev = PageEvent(id:id, data:str)
    return CInt(fkt(ev) ? 1 : 0)
}
