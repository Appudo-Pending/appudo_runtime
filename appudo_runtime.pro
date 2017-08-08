###########################################################################################
#    appudo_runtime.pro is part of Appudo
#
#    Copyright (C) 2015
#        bc00940f92e19b5d84931da5bbb6bce10b8e341bdd9d98d016513a164e790c05 source@appudo.com
#
#    Licensed under the Apache License, Version 2.0
#
#    See http://www.apache.org/licenses/LICENSE-2.0 for more information
###########################################################################################

TEMPLATE = aux

MACHINE = $$system(uname -m)
CONFIG(release, debug|release) : DESTDIR = $$_PRO_FILE_PWD_/Release.$$MACHINE-dst
CONFIG(debug, debug|release)   : DESTDIR = $$_PRO_FILE_PWD_/Debug.$$MACHINE-dst
CONFIG(force_debug_info)       : DESTDIR = $$_PRO_FILE_PWD_/Profile.$$MACHINE-dst

CONFIG(release, debug|release) : OUTF = Release.$$MACHINE
CONFIG(debug, debug|release)   : OUTF = Debug.$$MACHINE
CONFIG(force_debug_info)       : OUTF = Profile.$$MACHINE

QMAKE_MAKEFILE = $$DESTDIR/Makefile
OBJECTS_DIR = $$DESTDIR/.obj
MOC_DIR = $$DESTDIR/.moc
RCC_DIR = $$DESTDIR/.qrc
UI_DIR = $$DESTDIR/.ui

CONFIG(release, debug|release) : first.commands = cd $$_PRO_FILE_PWD_ && (./compile.sh 0 || exit 1)
CONFIG(debug, debug|release)   : first.commands = cd $$_PRO_FILE_PWD_ && (./compile.sh 1 || exit 1)
CONFIG(force_debug_info)       : first.commands = cd $$_PRO_FILE_PWD_ && (./compile.sh 1 || exit 1)

QMAKE_EXTRA_TARGETS += first

QMAKE_CLEAN += -r $$_PRO_FILE_PWD_/$$OUTF/

HEADERS += \
    src/libbridge/toplevel.h

DISTFILES += \
    src/libappudo/appudo/Account.swift \
    src/libappudo/appudo/Async.swift \
    src/libappudo/appudo/Blob.swift \
    src/libappudo/appudo/Cookie.swift \
    src/libappudo/appudo/Date.swift \
    src/libappudo/appudo/Event.swift \
    src/libappudo/appudo/FileItem.swift \
    src/libappudo/appudo/Group.swift \
    src/libappudo/appudo/Group_Private.swift \
    src/libappudo/appudo/Lang.swift \
    src/libappudo/appudo/Link.swift \
    src/libappudo/appudo/Mail.swift \
    src/libappudo/appudo/Memory.swift \
    src/libappudo/appudo/MenuItem.swift \
    src/libappudo/appudo/Page.swift \
    src/libappudo/appudo/Redirect.swift \
    src/libappudo/appudo/Server.swift \
    src/libappudo/appudo/Session.swift \
    src/libappudo/appudo/Setting.swift \
    src/libappudo/appudo/Socket.swift \
    src/libappudo/appudo/SQLQry.swift \
    src/libappudo/appudo/User.swift \
    src/libappudo/appudo/Variables.swift \
    src/libappudo/appudo/WebSocket.swift \
    src/libappudo/appudo/WebSocketEvent.swift \
    src/libappudo/toplevel.swift \
    src/libintern/appudo/FileItem.swift \
    src/libintern/appudo/MenuItem.swift \
    src/libintern/appudo/RunData.swift \
    src/libintern/appudo/WebSocketEvent.swift \
    src/libintern/appudo/Link.swift \
    src/libintern/appudo/Async.swift \
    compile.sh \
    pack.sh \
    symbols.txt \
    src/libintern/appudo/Error.swift \
    src/appudo_page/appudo/Cookie.swift \
    src/appudo_page/appudo/Page.swift \
    src/appudo_page/appudo/Redirect.swift \
    src/appudo_websocket/appudo/Socket.swift \
    src/appudo_websocket/appudo/toplevel.swift \
    src/appudo_websocket/toplevel.swift \
    src/appudo_page/toplevel.swift \
    src/appudo_page/appudo/Link.swift \
    src/appudo_page/appudo/Mail.swift \
    src/libappudo/appudo/Socket.swift \
    src/libappudo/appudo/Link.swift \
    src/appudo_websocket/appudo/WebSocketEvent.swift \
    src/appudo_page/appudo/Session.swift \
    src/appudo_page/appudo/Variables.swift \
    src/libintern/appudo/Account.swift \
    src/libintern/appudo/String.swift \
    src/libappudo/appudo/Error.swift \
    src/libappudo/appudo/Page.swift \
    src/libappudo/appudo/Account_Private.swift \
    src/libappudo/appudo/Async_Private.swift \
    src/libappudo/appudo/Blob_Private.swift \
    src/libappudo/appudo/FileItem_Private.swift \
    src/libappudo/appudo/HTTPClient.swift \
    src/libappudo/appudo/HTTPRequestType.swift \
    src/libappudo/appudo/Page_Private.swift \
    src/libappudo/appudo/RunData_Private.swift \
    src/libappudo/appudo/Setting_Private.swift \
    src/libappudo/appudo/SQLQry_Private.swift \
    src/libappudo/appudo/StaticDomain_Private.swift \
    src/libappudo/appudo/StaticDomain.swift \
    src/libappudo/appudo/User_Private.swift \
    src/libintern/appudo/Group.swift \
    src/libintern/appudo/HTTPClient.swift \
    src/libintern/appudo/Primitive.swift \
    src/libintern/appudo/SQLQry.swift \
    src/libintern/appudo/User.swift \
    src/libintern_page/appudo/MenuItem.swift \
    src/libintern_page/appudo/RunData.swift \
    src/libintern_websocket/appudo/WebSocketEvent.swift \
    src/appudo_page/appudo/Cookie_Private.swift \
    src/appudo_page/appudo/MenuItem_Private.swift \
    src/appudo_page/appudo/User.swift \
    src/appudo_page/appudo/Variables_Private.swift \
    clean.sh \
    export_doc.sh \
    src/libintern/appudo/HTTPClient.swift \
    src/libappudo/appudo/HTTPClient.swift \
    src/libappudo/appudo/HTTPRequestType.swift \
    src/appudo_page/appudo/User.swift \
    clean.sh \
    src/libintern/appudo/Primitive.swift \
    src/libintern/appudo/SQLQry.swift \
    src/libappudo/appudo/StaticDomain.swift \
    src/libintern/appudo/User.swift \
    src/libintern/appudo/Group.swift \
    src/libintern_websocket/appudo/WebSocketEvent.swift \
    src/libintern_page/appudo/RunData.swift \
    src/libintern_page/appudo/MenuItem.swift \
    src/libassert/appudo/Assert.swift \
    src/appudo_page/appudo/Cookie_Private.swift \
    src/appudo_page/appudo/MenuItem_Private.swift \
    src/appudo_page/appudo/Variables_Private.swift \
    src/libappudo/appudo/Account_Private.swift \
    src/libappudo/appudo/Async_Private.swift \
    src/libappudo/appudo/FileItem_Private.swift \
    src/libappudo/appudo/Blob_Private.swift \
    src/libappudo/appudo/Page_Private.swift \
    src/libappudo/appudo/RunData_Private.swift \
    src/libappudo/appudo/Setting_Private.swift \
    src/libappudo/appudo/SQLQry_Private.swift \
    src/libappudo/appudo/StaticDomain_Private.swift \
    src/libappudo/appudo/User_Private.swift \
    export_doc.sh \
    jazzy_run.sh \
    compile_doc.sh \
    setup_swift.sh \
    apply-fixit-edits.py \
    src/libappudo/Interface_Private.swift \
    src/libappudo/appudo/HTTPClient_Private.swift \
    src/libenv/appudo_env.swift \
    src/libenv/appudo_page_env.swift \
    src/libenv/appudo_websocket_env.swift \
    LICENSE \
    LICENSE.MIT \
    LICENSE.APACHE2 \
    src/libappudo/appudo/ManagedCharBuffer_Private.swift \
    src/appudo_backend/appudo/Backend.swift \
    src/libappudo/appudo/FrameBufferData_Private.swift \
    src/libappudo/appudo/MemVar.swift \
    src/libintern/appudo/Assert.swift \
    src/libappudo/appudo/AsyncDelay.swift \
    src/libappudo/appudo/FileView.swift \
    src/appudo_page/appudo/Print.swift \
    src/appudo_page/appudo/Upload.swift \
    src/libappudo/appudo/ErrorEvent.swift \
    src/appudo_page/appudo/Upload_Private.swift \
    src/appudo_page/appudo/PageFileCache.swift \
    src/appudo_page/appudo/PageFileCache_Private.swift \
    src/libappudo/appudo/Cache2Q.swift \
    src/libappudo/appudo/StringData_Private.swift \
    src/libappudo/appudo/HTTPRequestStatus.swift \
    src/appudo_page/appudo/PageResultError.swift \
    src/libappudo/appudo/Package.swift \
    src/libappudo/appudo/InetAddr.swift \
    rename.sh
