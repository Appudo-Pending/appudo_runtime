/*
    Upload.swift is part of Appudo

    Copyright (C) 2015-2016
        bc00940f92e19b5d84931da5bbb6bce10b8e341bdd9d98d016513a164e790c05 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/
import libappudo
import libappudo_bridge

public enum UploadType : Int32 {
    case FILE       = 1
    case DIR        = 2
}

public struct UploadData {
    let _info : UnsafeMutablePointer<_UploadHolder>
    public let parent : String?
    public let subDir: String?
    public let name : String
    public let type : UploadType

    init(info : UnsafeMutablePointer<_UploadHolder>, name : String, parent : String?, subDir: String?, type : UploadType) {
        _info = info
        self.parent = parent
        self.subDir = subDir
        self.name = name
        self.type = type
    }

    public func abort() -> Void {
        if(FileItem_IsUpload(_info) != 0) {
            _info.pointee.abort = true
        }
    }
}
