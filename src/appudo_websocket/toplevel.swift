/*
    toplevel.swift is part of Appudo

    Copyright (C) 2015-2016
        4bea15c834854bf9670dc6a1cbc9a9dda7cf418ef53b8edbb11b3df946a0c45e source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo
import libappudo_bridge

/**
Send data as text.
Send functions do not signal the completion or the success of the send.
They only verify the input data and signal if the send process
was started.
Errors will trigger a notification event to handle in the websocket run.
Notification about successful sends can optionally be enabled with
the notifyComplete option for each socket.

For example an error is signaled when the rate of outgoing messages
to a client is high and the transfer rate is too low to make room in
the clients send buffer.

- parameter data: The data to send.
- parameter targets: The socket(s) to send the data to.

- SeeAlso: Socket.notifyComplete
*/
public func sendText(_ data : Any?, _ targets : ContiguousArray<Socket>) -> Bool {
    return sendTo(data, targets)
}

/**
Send data as text.

- parameter data: The data to send.
- parameter targets: The socket(s) to send the data to.
*/
public func sendText(_  data : Any?, _ targets : Socket...) -> Bool {
    return sendText(data, ContiguousArray<Socket>(targets))
}

/**
Broadcast data as text.

- parameter data: The data to broadcast.
- parameter exclude: The socket(s) NOT to broadcast the data to.
*/
public func bcText(_ data : Any?, _ exclude : ContiguousArray<Socket>) -> Bool {
    return sendTo(data, exclude, true)
}

/**
Broadcast data as text.

- parameter data: The data to broadcast.
- parameter exclude: The socket(s) NOT to broadcast the data to.
*/
public func bcText(_ data : Any?, _ exclude : Socket...) -> Bool {
    return bcText(data, ContiguousArray<Socket>(exclude))
}

/**
Send data as bytes.

- parameter data: The data to send.
- parameter targets: The socket(s) to send the data to.
*/
public func sendBytes(_ data : Any?, _ targets : ContiguousArray<Socket>) -> Bool {
    return sendTo(data, targets, false, false)
}

/**
Send data as bytes.

- parameter data: The data to send.
- parameter targets: The socket(s) to send the data to.
*/
public func sendBytes(_  data : Any?, _ targets : Socket...) -> Bool {
    return sendBytes(data, ContiguousArray<Socket>(targets))
}

/**
Broadcast data as bytes.

- parameter data: The data to broadcast.
- parameter exclude: The socket(s) NOT to broadcast the data to.
*/
public func bcBytes(_ data : Any?, _ exclude : ContiguousArray<Socket>) -> Bool {
    return sendTo(data, exclude, true, false)
}

/**
Broadcast data as bytes.
- parameter data: The data to broadcast.
- parameter exclude: The socket(s) NOT to broadcast the data to.
*/
public func bcBytes(_ data : Any?, _ exclude : Socket...) -> Bool {
    return bcBytes(data, ContiguousArray<Socket>(exclude))
}

private func sendTo(_ data : Any?, _ target : Any, _ broadcast : Bool = false, _ text : Bool = true) -> Bool  {
    var res = false
    var n = 0
    var num_targets : UInt32 = 1
    var buffer : ContiguousArray<Socket>

    switch(target)
    {
    case is Socket:
        let t = target as! Socket
        buffer = ContiguousArray<Socket>(repeating: t, count: 1)
    case is ContiguousArray<Socket>:
        buffer = target as! ContiguousArray<Socket>
        num_targets = UInt32(buffer.count)
    default:
        return false
    }
    if(data != nil && (num_targets != 0 || broadcast)) {
        buffer.withUnsafeBufferPointer {
            (memPtr: UnsafeBufferPointer<Socket>) -> Void in
            let targets = UnsafeRawPointer(memPtr.baseAddress!).assumingMemoryBound(to:UInt32.self)
            var _data : Any? = data
            switch(data) {
                case is FileView:
                    _data = FileViewInfo(data as! FileView)
                case is FileSendSource:
                    _data = FileViewInfo(data as! FileSendSource)
                case is FileViewInfo:
                    break
                case is DataWriteSource:
                    n = 2
                    _data = DataView(data as! DataWriteSource)
                case is DataView:
                    n = 2
                default:
                    return
            }

            switch(n + (text ? 1 : 0))
            {
                case 0:
                    var info = _data as! FileViewInfo
                    res = WebSocket_WriteFileAsBytes(&info, targets, num_targets, CInt(broadcast ? 1 : 0)) == 1
                case 1:
                    var info = _data as! FileViewInfo
                    res = WebSocket_WriteFileAsText(&info, targets, num_targets, CInt(broadcast ? 1 : 0)) == 1
                case 2:
                    var info = _data as! DataView
                    res = WebSocket_WriteBytes(&info, targets, num_targets, CInt(broadcast ? 1 : 0)) == 1
                case 3:
                    var info = _data as! DataView
                    res = WebSocket_WriteText(&info, targets, num_targets, CInt(broadcast ? 1 : 0)) == 1
                default:
                    break
            }
        }
    }

    return res
}
