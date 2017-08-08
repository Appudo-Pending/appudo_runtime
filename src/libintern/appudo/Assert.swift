/*
    Assert.swift is part of Appudo

    Copyright (C) 2015-2016
        0f751a1d3444d63f571768174ba74ddb110c7375c07f4c78efe0673d530054ee source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo

public func Assert_GetPrint(_ item : UnsafeMutablePointer<FileItem?>, _ fileFd : CInt) -> Void {
     item.pointee = PrivateInterface.getFileItem(UnlinkedFilePath(fileFd))
}
