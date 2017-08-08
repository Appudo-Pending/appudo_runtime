/*
    HTTPClient_Private.swift is part of Appudo

    Copyright (C) 2015-2016
        4bea15c834854bf9670dc6a1cbc9a9dda7cf418ef53b8edbb11b3df946a0c45e source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

struct HTTPSendInfo
{
    var type : CInt = 0
    var version : CInt = 0
    var con : CInt = 0
    var cookies : CBool = false
    var headers : CBool = false
    var files : CBool = false
    var removeEncoding : CBool = false
    var updateHeaders : CBool = false
    var updateCookies : CBool = false
}

public extension PrivateInterface {
    public static func setHTTPClient(_ client : HTTPClient, _ result : _FilePath?) -> Void {
        client._result = result
    }
    public static func finishHTTPClient(_ client : HTTPClient, _ error : CInt) -> Void {
        if(error != 0) {
            client._result = nil
        }
        client._state = error == 0 ? .Ok : .Error
    }
    public static func getHTTPClientFd(_ client : HTTPClient) -> CInt {
        return client._result?.fileFd ?? -1
    }
}
