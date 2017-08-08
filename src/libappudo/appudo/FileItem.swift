/*
    FileItem.swift is part of Appudo

    Copyright (C) 2015-2016
        ae3453f1d271c32860dc06afd71f3918e396ff5139052cd38c33f6c4fafc98a4 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge
import Foundation

/**
The FileSeekFlag is used for the FileSeekable API.

- SeeAlso: FileSeekable
*/
public struct FileSeekFlag : OptionSet {
    public let rawValue: Int32
    public init(rawValue:Int32) {
        self.rawValue = rawValue
    }
    /**
    The default value is SEEK_SET.
    */
    public static let DEFAULT     = FileSeekFlag(rawValue: SEEK_SET.rawValue)
    /**
    Use this flag to set the current position.
    */
    public static let SEEK_SET    = FileSeekFlag(rawValue: 0)
    /**
    Use this flag to get the current position.
    */
    public static let SEEK_CUR    = FileSeekFlag(rawValue: 1)
    /**
    Use this flag to get the maximum position.
    */
    public static let SEEK_END    = FileSeekFlag(rawValue: 2)
    /**
    Use this flag to move the current position to the next data.
    */
    public static let SEEK_DATA   = FileSeekFlag(rawValue: 3)
    /**
    Use this flag to move the current position to the next hole.
    */
    public static let SEEK_HOLE   = FileSeekFlag(rawValue: 4)
}

/**
FileLockable represents a lockable file to serialize reads and writes.
*/
public protocol FileLockable {
    var fileFd : CInt { get }
    /**
    Check if there is a lock in range.

    - parameter offset: The start offset for the range to check.
    - parameter size: The size of the range to check.
    */
    func isLocked(_ offset : Int, _ size : Int) -> AsyncBool
    /**
    Lock a range for exclusive write.

    - parameter offset: The start offset for the lock range.
    - parameter size: The size of the range to lock.
    */
    func lockWrite(_ offset : Int, _ size : Int) -> AsyncBool
    /**
    Lock a range for read only.

    - parameter offset: The start offset for the lock range.
    - parameter size: The size of the range to lock.
    */
    func lockRead(_ offset : Int, _ size : Int) -> AsyncBool
    /**
    Unlock a range.

    - parameter offset: The start offset for the lock range.
    - parameter size: The size of the range to unlock.
    */
    func unlock(_ offset : Int, _ size : Int) -> AsyncBool
    /**
    Unlock the whole file.
    */
    func unlock() -> AsyncBool
}

/**
FileSeekable represents a file that is seekable.
*/
public protocol FileSeekable {
    var fileFd : CInt { get }
    /**
    Modify the current file position.

    - parameter pos: The position to work with.
    - parameter flag: The kind for the modification.

    - SeeAlso: FileSeekFlag
    */
    mutating func seek(_ pos : Int, _ flag : FileSeekFlag) -> AsyncInt
}

/**
DataWriteSource represents a data item that can be used with the file write APIs.
*/
public protocol DataWriteSource {
    func getData(_ offset : Int, _ maxSize : Int, _ info : inout DataView) -> UnsafePointer<Int8>?
}

/**
FileSendSource represents a file that supports zero copy.
*/
public protocol FileSendSource {
    var fileFd : CInt { get }
    /**
    Zero copy data to a FileSeekable target.

    - parameter target: The FileSeekable to send the data to.
    - parameter in_size: The size of the data to send.
    - parameter in_offset: The offset into the source to start with.
    */
    mutating func send(_ target : FileSeekable, _ in_size : Int, _ in_offset : Int) -> AsyncInt
}

struct FileItemInfo {
    var size : CLong = 0
    var userId : CInt = 0
    var groupId : CInt = 0
    var time_access : CLong = 0
    var time_mod : CLong = 0
    var time_state : CLong = 0
    var mode : CInt = 0
    var is_dir : CChar = 0
}

struct PathHolder {
    var _path : _FilePath
    init(_ path : _FilePath) {
        _path = path
    }
}

struct FilePathInfo {
    var type : CInt;
    var data : CLong;
}

/**
FileItemList is a chunked list representation for directory listings.
*/
open class FileItemList : Sequence, IteratorProtocol, Collection {
    open var startIndex: Int { get { return 0 } }
    open var endIndex: Int { get { return 0 } }

    public func index(after: Int) -> Int {
            return after + 1
    }

    open func next() -> FileItem? {
        fatalError("must implement")
    }

    open subscript(i:Int) -> FileItem {
        fatalError("must implement")
    }

    open func nextList(_ order:(FileItem.Sorter?) = nil, _ chunkLimit:Int32 = 64) -> AsyncClass<FileItemList> {
        fatalError("must implement")
    }
}

/**
AlphasortASC is a comparison function for directory listings with ascending alphabetical order.

- SeeAlso: FileItemList
*/
public func AlphasortASC(a:FileItem, b:FileItem) -> Int32 {
    return String_strcoll(a.name_data, b.name_data)
}

/**
AlphasortASC is a comparison function for directory listings with descending alphabetical order.

- SeeAlso: FileItemList
*/
public func AlphasortDSC(a:FileItem, b:FileItem) -> Int32 {
    return String_strcoll(b.name_data, a.name_data)
}

/**
Information about a file like the size or ownership is accessed with a FileStat.

- SeeAlso: FileItem
*/
public struct FileStat {
    init(_ info : FileItemInfo) {
        _info = info
    }

    /**
    Returns true if the FileItem is a file and not a directory.
    */
    public var isFileNotDir : Bool {
        return _info.is_dir == 0
    }

    /**
    Returns the size of a file.
    */
    public var size : Int {
        return _info.size
    }

    /**
    Returns the latest of change and modification time.
    */
    public var time_latest : Date {
        if(_info.time_mod > _info.time_state) {
            return time_mod
        }
        return time_state
    }

    /**
    Returns the time the file was last read (access time).
    */
    public var time_access : Date {
        return Date(timeIntervalSince1970:Double(_info.time_access))
    }

    /**
    Returns the time of file's last content modification. (modification time).
    */
    public var time_mod : Date {
        return Date(timeIntervalSince1970:Double(_info.time_mod))
    }

    /**
    Returns the time of file's last meta data change. (change time).
    */
    public var time_state : Date {
        return Date(timeIntervalSince1970:Double(_info.time_state))
    }

    /**
    Returns the UserID for the current user owning the file or directory.
    */
    public var uid : UserID {
        return UserID(_info.userId)
    }

    /**
    Returns the GroupID for the current group owning the file or directory.
    */
    public var gid : GroupID {
        return GroupID(_info.groupId)
    }

    /**
    Return the access mode for the current user and group owner.
    */
    public var mode : FileItem.Mode {
        return FileItem.Mode(rawValue: _info.mode & 0o7777)
    }
    let _info : FileItemInfo
}

/**
A single file or directory is modified with a FileItem.
*/
public struct FileItem : FileSeekable, FileSendSource {
    public typealias Sorter = (_ a:FileItem, _ b:FileItem) -> Int32

    /**
    Flag contains the mode used to open a file or directory.

    - SeeAlso: open
    */
    public struct Flag : OptionSet {
        public let rawValue: Int32
        public init(rawValue:Int32) {
            self.rawValue = rawValue
        }
        /** Default is closed path. */
        public static let NONE        = Flag(rawValue: -1)
        /** Read only file. */
        public static let O_RDONLY    = Flag(rawValue: 0o0)
        /** Write only file. */
        public static let O_WRONLY    = Flag(rawValue: 0o01)
        /** Read and write file. */
        public static let O_RDWR      = Flag(rawValue: 0o02)
        /** Create file or directory. */
        public static let O_CREAT     = Flag(rawValue: 0o0100)
        /** Lock the file for exclusive access. */
        public static let O_EXCL      = Flag(rawValue: 0o0200)
        /** Truncate the file */
        public static let O_TRUNC     = Flag(rawValue: 0o01000)
        /** Append to the file */
        public static let O_APPEND    = Flag(rawValue: 0o02000)
        /** Open with appudo device mode. */
        public static let O_APPUDO    = Flag(rawValue: 0o0100000)
        /** Open directory. */
        public static let O_DIRECTORY = Flag(rawValue: 0o0200000)
        /** Create unlinked temp file. */
        public static let O_TMPFILE   = Flag(rawValue: 0o020000000 | O_DIRECTORY.rawValue)

        public func has(_ f : Flag) -> Bool {
            return rawValue & f.rawValue == f.rawValue
        }
    }

    /**
    RenameFlags contains the mode used to rename a file or directory.

    - SeeAlso: rename
    */
    public struct RenameFlags : OptionSet {
        public let rawValue: Int32
        public init(rawValue:Int32) {
            self.rawValue = rawValue
        }

        /** Default is NOREPLACE. */
        public static let NONE        = NOREPLACE
        /** Don't overwrite existing file. */
        public static let NOREPLACE   = RenameFlags(rawValue: 1)
        /** Atomically exchange. */
        public static let EXCHANGE    = RenameFlags(rawValue: 2)

        public func has(_ f : RenameFlags) -> Bool {
            return rawValue & f.rawValue == f.rawValue
        }
    }

    /**
    MKPathFlags contains the mode used to create a directory path.

    - SeeAlso: mkpath
    */
    public struct MKPathFlags : OptionSet {
        public let rawValue: Int32
        public init(rawValue:Int32) {
            self.rawValue = rawValue
        }

        /** Default is to enter existing directories. */
        public static let NONE        = MKPathFlags(rawValue: 0)
        /** Do not enter existing directories. */
        public static let EXCLUSIVE   = MKPathFlags(rawValue: 1)

        public func has(_ f : MKPathFlags) -> Bool {
            return rawValue & f.rawValue == f.rawValue
        }
    }

    /**
    Mode contains the access rights of a file or directory for its user or group owner.
    */
    public struct Mode : OptionSet {
        public let rawValue: Int32
        public init(rawValue:Int32) {
            self.rawValue = rawValue
        }

        /** No access. */
        public static let NONE = Mode(rawValue: 0)
        public static let DEFAULT = Mode(rawValue: Mode([S_IRUSR, S_IWUSR, S_IRGRP]).rawValue)
        /** Save swapped text after use (sticky).  */
        public static let S_ISVTX = Mode(rawValue: 0o04000)
        public static let S4000 = S_ISUID
        /** Set user ID on execution.  */
        public static let S_ISUID = Mode(rawValue: 0o02000)
        public static let S2000 = S_ISUID
        /** Set group ID on execution.  */
        public static let S_ISGID = Mode(rawValue: 0o01000)
        public static let U1000 = S_ISGID
        /** Read by owner. */
        public static let S_IRUSR = Mode(rawValue: 0o0400)
        public static let U0400 = S_IRUSR
        /** Write by owner. */
        public static let S_IWUSR = Mode(rawValue: 0o0200)
        public static let U0200 = S_IWUSR
        /** Execute by owner. */
        public static let S_IXUSR = Mode(rawValue: 0o0100)
        public static let U0100 = S_IXUSR
        /** Read, write, and execute by owner. */
        public static let S_IRWXU = Mode(rawValue: Mode([S_IRUSR, S_IWUSR, S_IXUSR]).rawValue)
        public static let U0700 = S_IRWXU
        /** Read by group. */
        public static let S_IRGRP = Mode(rawValue: S_IRUSR.rawValue >> 3)
        public static let G0040 = S_IRGRP
        /** Write by group. */
        public static let S_IWGRP = Mode(rawValue: S_IWUSR.rawValue >> 3)
        public static let G0020 = S_IWGRP
        /** Execute by group. */
        public static let S_IXGRP = Mode(rawValue: S_IXUSR.rawValue >> 3)
        public static let G0010 = S_IXGRP
        /** Read, write, and execute by group. */
        public static let S_IRWXG = Mode(rawValue: S_IRWXU.rawValue >> 3)
        public static let G0070 = S_IRWXG
        /** Read by others. */
        public static let S_IROTH = Mode(rawValue: S_IRGRP.rawValue >> 3)
        public static let O0004 = S_IROTH
        /** Write by others. */
        public static let S_IWOTH = Mode(rawValue: S_IWGRP.rawValue >> 3)
        public static let O0002 = S_IWOTH
        /** Execute by others. */
        public static let S_IXOTH = Mode(rawValue: S_IXGRP.rawValue >> 3)
        public static let O0001 = S_IXOTH
        /** Read, write, and execute by others. */
        public static let S_IRWXO = Mode(rawValue: S_IRWXG.rawValue >> 3)
        public static let O0007 = S_IRWXO
        static let ALL = Mode(rawValue: 0o07777)
        public static let A0777 = ALL

        public static let U0300 = Mode(rawValue: Mode([ U0200, U0100 ]).rawValue)
        public static let U0500 = Mode(rawValue: Mode([ U0400, U0100 ]).rawValue)
        public static let U0600 = Mode(rawValue: Mode([ U0400, U0200 ]).rawValue)

        public static let G0030 = Mode(rawValue: Mode([ G0020, G0010 ]).rawValue)
        public static let G0050 = Mode(rawValue: Mode([ G0040, G0010 ]).rawValue)
        public static let G0060 = Mode(rawValue: Mode([ G0040, G0020 ]).rawValue)

        public static let O0003 = Mode(rawValue: Mode([ O0002, O0001 ]).rawValue)
        public static let O0005 = Mode(rawValue: Mode([ O0004, O0001 ]).rawValue)
        public static let O0006 = Mode(rawValue: Mode([ O0004, O0002 ]).rawValue)

        public func has(_ m : Mode) -> Bool {
            return rawValue & m.rawValue == m.rawValue
        }
    }

    /**
    Create a run device file.

    - parameter treeId: The tree id of the run.
    - parameter name: The name for the device file name.
    - parameter mode: The mode for the device file.
    */
    public static func create_dev(_ treeId : Int, _ name : String, _ mode : Mode = Mode.DEFAULT) -> AsyncStruct<FileItem>
    {
        var ret = AsyncStruct<FileItem>(nil)
        struct ArgPad {
            var name : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cname = ret.arg(name, &pad.name)
        ret.store(&pad)
        FileItem_CreateDev(&ret, treeId, cname, mode.rawValue)
        if(!ret.hasError) {
            ret.rawValue!._async = AsyncOnSuccess(&ret.rawValue!, ret)
        }
        return ret
    }

    var _path : _FilePath
    private var _async : AsyncOnSuccess<FileItem> = AsyncOnSuccess()
    init(_ path : _FilePath) {
        _path = path
    }

    public var fileFd : CInt {
        return _path.fileFd
    }

    /**
    Returns true if the FileItem is a root directory.
    */
    public var isRoot : Bool {
        return _path.parent == nil
    }

    /**
    Returns true if the FileItem is an open file or directory.
    */
    public var isOpen : Bool {
        mutating get {
            var a = _async;
            _ = a.isPending(&self)
            return _path.isOpen
        }
    }

    private var isNonPendingOpen : Bool {
        mutating get {
            var a = _async;
            return !a.isPending(&self) && isOpen
        }
    }

    private var isNonPendingClosed : Bool {
        mutating get {
            var a = _async;
            return !a.isPending(&self) && !isOpen
        }
    }

    /**
    Returns the name of the file or directory.
    */
    public var name : String {
        return _path.name
    }

    public var name_data : UnsafePointer<Int8>  {
        return _path.name_data
    }

    /**
    Returns the full path of the file or directory.
    */
    public var path : String {
        return _path.full
    }

    var parent_path : String {
        let parent = _path.parent
        return parent != nil ? parent!.full : ""
    }

    /**
    Returns the FileStat holding information about the file or directory.

    - SeeAlso: FileStat
    */
    public var stat : AsyncStruct<FileStat> {
        var ret = AsyncStruct<FileStat>(nil)
        struct ArgPad {
            var base : AnyObject? = nil
        }
        var pad = ArgPad()
        let cbase = ret.arg(self.path, &pad.base)
        ret.store(&pad)
        FileItem_GetInfo(&ret, cbase)
        return ret
    }

    /**
    Returns the FileStat holding information about the open file or directory.

    - SeeAlso: FileStat
    */
    public var stat_open : AsyncStruct<FileStat> {
        mutating get {
            var ret = AsyncStruct<FileStat>(nil)
            if(isNonPendingOpen) {
                FileItem_GetInfoOpen(&ret, fileFd)
                _async = AsyncOnSuccess(&self, ret)
            } else {
                ret.errorValue = AppudoError.INVAL
            }
            return ret
        }
    }

    /**
    Returns the data of the file as FileBob.

    - SeeAlso: FileBob
    */
    public var data : AsyncClass<Blob> {
    // TODO
        get {
            return AsyncClass<Blob>(nil)
        }
    }

    /**
    Returns a view of the file.

    - SeeAlso: FileView
    */
    public func getView(_ offset : Int, _ size : Int) -> FileView {
        return FileView(self, offset:offset, size:size)
    }

    /**
    Set the current access mode for the file or directory.

    - parameter mode: The new mode.
    - parameter nofollow: True to not follow symlinks.
    */
    public func setMode(_ mode : Mode, _ nofollow : Bool = false) -> AsyncBool {
        var ret = AsyncBool(false)
        struct ArgPad {
            var base : AnyObject? = nil
        }
        var pad = ArgPad()
        let cbase = ret.arg(self.path, &pad.base)
        ret.store(&pad)
        FileItem_CHMOD(&ret, cbase, mode.rawValue, nofollow ? 0x100 : 0)
        return ret
    }

    public func setMode(rawValue : Int32) -> AsyncBool {
        return setMode(Mode(rawValue:rawValue))
    }

    /**
    Set the owning user and group for the file or directory.
    To change the owning user the current user must be either
    the owner of that user or a member of the master group.
    To change the owning group the current user must be a member of that group.

    - parameter user: The user's id to set as the new owner.
    - parameter group: The group's id to set as the new owner.
    - parameter nofollow: True to not follow symlinks.
    */
    public func setOwner(_ user : UserID, _ group : GroupID, _ nofollow : Bool = false) -> AsyncBool {
        var ret = AsyncBool(false)
        struct ArgPad {
            var base : AnyObject? = nil
        }
        var pad = ArgPad()
        let cbase = ret.arg(self.path, &pad.base)
        ret.store(&pad)
        FileItem_CHOWN(&ret, cbase, user.rawValue, group.rawValue, nofollow ? 0x100 : 0)
        return ret
    }

    /**
    Set the owning user for the file or directory.

    - parameter user: The user's id to set as the new owner.
    */
    public func setOwner(_ user : UserID) -> AsyncBool {
        return setOwner(user, GroupID(-1))
    }

    /**
    Set the owning group for the file or directory.

    - parameter group: The group's id to set as the new owner.
    */
    public func setOwner(_ group : GroupID) -> AsyncBool {
        return setOwner(UserID(-1), group)
    }

    /**
    Get a list for the contents of a directory.

    - parameter order: The sort function to order the list.
    - parameter chunkLimit: The chunk limit for the list.
    The list is created in chunks. Only the current chunk is held in memory and sorted.
    */
    public func listDir(_ order:(Sorter?) = nil, _ chunkLimit:Int32 = 0) -> AsyncClass<FileItemList> {
        return _path.listDir(order, chunkLimit)
    }

    public func back() -> FileItem?  {
        if(!isRoot) {
            return FileItem(_path.parent!)
        }
        return nil
    }

    /**
    Close the file or directory.
    */
    mutating public func close() -> Void {
        if(isOpen) {
            var a = _async;
            a.waitFor(&self)
            _path._close()
        }
    }

    /**
    AccessMode contains the access modes of a file or directory to use with access.
    */
    public struct AccessMode : OptionSet {
        public let rawValue: Int32
        public init(rawValue:Int32) {
            self.rawValue = rawValue
        }
        /** Test for read permission.  */
        public static let R_OK = AccessMode(rawValue: 4)
        /** Test for write permission.  */
        public static let W_OK = AccessMode(rawValue: 2)
        /** Test for execute permission.  */
        public static let X_OK = AccessMode(rawValue: 1)
        /** Test for existence.  */
        public static let F_OK = AccessMode(rawValue: 0)
    }

    /**
    Returns true if the file or directory exists and the current login user has ownership and rights for access.

    - parameter mode: The access mode for the file or directory.
    - parameter path: The path of the file or directory to access.
    */
    public func access(_ path : String = "", mode : AccessMode = .F_OK) -> AsyncBool {
        var ret = AsyncBool(false)
        struct ArgPad {
            var base : AnyObject? = nil
            var path : AnyObject? = nil
        }
        var pad = ArgPad()
        let cbase = ret.arg(self.path, &pad.base)
        let cpath = ret.arg(path, &pad.path)
        ret.store(&pad)
        FileItem_Access(&ret, cbase, cpath, mode.rawValue)
        return ret
    }

    /**
    Set or get the current file position.

    - parameter pos: The new file position.
    - parameter flag: The mode to access the file position.

    - SeeAlso: FileSeekable
    */
    mutating public func seek(_ pos : Int, _ flag : FileSeekFlag) -> AsyncInt {
        var ret = AsyncInt(0)
        if(isNonPendingOpen) {
            FileItem_Seek(&ret, fileFd, pos, flag.rawValue)
            _async = AsyncOnSuccess(&self, ret)
        } else {
            ret.errorValue = AppudoError.INVAL
        }
        return ret
    }

    /**
    Open the file or directory.

    - parameter flags: The flags used to open the file or directory.
    - parameter mode: The access mode to create a file or directory with.
    */
    mutating public func open(_ flags : Flag, _ mode : Mode = Mode.DEFAULT) -> AsyncBool {
        var ret = AsyncBool(false)
        if(isNonPendingClosed && !isRoot) {
            struct ArgPad {
                var base : AnyObject? = nil
            }
            var pad : ArgPad = ArgPad()
            let cbase = ret.arg(self.path, &pad.base)
            var holder = PathHolder(_path)
            ret.store(&pad)
            FileItem_Open(&ret, &holder, cbase, flags.rawValue, mode.rawValue)
            _async = AsyncOnSuccess(&self, ret)
        }
        return ret
    }

    /**
    Open a path relative to the directory.

    - parameter path: The path to open. The path must not escape the root directory.
    - parameter flags: The flags used to open the file or directory.
    - parameter mode: The access mode to create a file or directory with.
    - parameter emptyPath: If for performance reasons set to true, the resulting FileItem has an empty path and can not be used as a base to other APIs.
    */
    public func open(_ path : StringData, _ flags : Flag = Flag.NONE, _ mode : Mode = Mode.DEFAULT, emptyPath : Bool = false) -> AsyncStruct<FileItem>  {
        var ret = AsyncStruct<FileItem>(nil)
        struct ArgPad {
            var base : AnyObject? = nil
            var path : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cbase = ret.arg(self.path, &pad.base)
        let cpath = ret.arg(path, &pad.path)
        var holder = PathHolder(_path)
        ret.store(&pad)
        FileItem_OpenAt(&ret, cbase, cpath, &holder, flags.rawValue, mode.rawValue)
        if(!ret.hasError) {
            ret.rawValue!._async = AsyncOnSuccess(&ret.rawValue!, ret)
        }
        return ret
    }



    /**
    Create directories relative to the directory.

    - parameter path: The path for the new directories to create.
    - parameter mode: The access mode to create the directoies with.
    - parameter emptyPath: If for performance reasons set to true, the resulting FileItem has an empty path and can not be used as a base to other APIs.
    */
    public func mkpath(_ path : StringData, _ mode : Mode = Mode(rawValue:Mode.DEFAULT.rawValue | Mode.S_IXUSR.rawValue), flags : MKPathFlags = .NONE, emptyPath : Bool = false) -> AsyncStruct<FileItem>  {
        var ret = AsyncStruct<FileItem>(nil)
        struct ArgPad {
            var base : AnyObject? = nil
            var path : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cbase = ret.arg(self.path, &pad.base)
        let cpath = ret.arg(path, &pad.path)
        var holder = PathHolder(_path)
        ret.store(&pad)
        FileItem_CreateDir(&ret, cbase, cpath, &holder, flags.rawValue, mode.rawValue)
        return ret
    }

    /**
    Rename the file or directory. The FileItem is updated with an empty path.

    - parameter path: The path to rename to. The path must not escape the root or base directory.
    - parameter base: The optional new base for the path to rename.
    */
    mutating public func rename(_ path : StringData, _ base:FileItem? = nil, flags : RenameFlags = .NONE) -> AsyncBool {
        var ret = AsyncBool(false)
        struct ArgPad {
            var base : AnyObject? = nil
            var path : AnyObject? = nil
            var newbase : AnyObject? = nil
        }
        if(!isRoot) {
            close()
            var pad : ArgPad = ArgPad()
            let cbase = ret.arg(self.path, &pad.base)
            let cpath = ret.arg(path, &pad.path)
            let cnewbase = ret.arg(base == nil ? parent_path : base!.path, &pad.newbase)
            ret.store(&pad)
            FileItem_Rename(&ret, cbase, cpath, cnewbase, flags.rawValue)
        }
        return ret
    }

    /**
    Link the file or directory to a new path.

    - parameter path: The path to link to. The path must not escape the root or base directory.
    - parameter base: The optional new base for the path to link.
    - parameter hard: The link type hard or sym link.
    */
    public func link(_ path : StringData, _ base:FileItem? = nil, hard : Bool = false) -> AsyncBool {
        var ret = AsyncBool(false)
        struct ArgPad {
            var base : AnyObject? = nil
            var path : AnyObject? = nil
            var newbase : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cbase = ret.arg(self.path, &pad.base)
        let cpath = ret.arg(path, &pad.path)
        let cnewbase = ret.arg(base == nil ? parent_path : base!.path, &pad.newbase)
        ret.store(&pad)
        FileItem_Link(&ret, cbase, cpath, cnewbase, hard ? 1 : 0)
        return ret
    }

    /**
    Link the file or directory to a new path.

    - parameter path: The path to link to. The path must not escape the root or base directory.
    - parameter base: The optional new base for the path to link.
    - parameter hard: The link type hard or sym link.
    */
    mutating public func link_open(_ path : StringData, _ base:FileItem? = nil, hard : Bool = false) -> AsyncBool {
        var ret = AsyncBool(false)
        struct ArgPad {
            var path : AnyObject? = nil
            var newbase : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cpath = ret.arg(path, &pad.path)
        let cnewbase = ret.arg(base == nil ? parent_path : base!.path, &pad.newbase)
        if(isNonPendingOpen) {
            ret.store(&pad)
            FileItem_LinkOpen(&ret, fileFd, cpath, cnewbase, hard ? 1 : 0)
            _async = AsyncOnSuccess(&self, ret)
        }
        return ret
    }

    /**
    Copy the file to a new path.

    - parameter path: The path to copy to. The path must not escape the root or base directory.
    - parameter base: The optional new base for the path to copy.
    */
    public func copy(_ path : StringData, _ base:FileItem? = nil) -> AsyncBool {
        var ret = AsyncBool(false)
        struct ArgPad {
            var base : AnyObject? = nil
            var path : AnyObject? = nil
            var newbase : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cbase = ret.arg(self.path, &pad.base)
        let cpath = ret.arg(path, &pad.path)
        let cnewbase = ret.arg(base == nil ? parent_path : base!.path, &pad.newbase)
        ret.store(&pad)
        FileItem_Copy(&ret, cbase, cpath, cnewbase)
        return ret
    }

    /**
    Remove the file or directory.

    - parameter path: The optional sub path of a directory. The path must not escape the root.
    - parameter outer: Set false to only remove the inner content of a directory.
    */
    public func remove(_ path : StringData? = nil, outer:Bool = true)  -> AsyncBool {
        var ret = AsyncBool(false)
        let root = isRoot
        struct ArgPad {
            var base : AnyObject? = nil
            var path : AnyObject? = nil
        }
        if(path != nil || !root) {
            var pad : ArgPad = ArgPad()
            let cbase = ret.arg(self.path, &pad.base)
            var cpath : UnsafePointer<Int8>? = nil
            if(path != nil) {
                cpath = ret.arg(path!, &pad.path)
            }
            ret.store(&pad)
            FileItem_Remove(&ret, cbase, cpath, (outer ? 1 : 0) + (root ? 2 : 0))
        }
        return ret
    }

    /**
    Write data to the file.

    - parameter source: The data source for the data to write.
    - parameter outLimit: The size limit of the data to write.
    - parameter outOffset: The offset in the file to write to.

    - SeeAlso: DataWriteSource
    */
    mutating public func write(_ source : DataWriteSource, _ outLimit : Int = 0, _ outOffset : Int = 0) -> AsyncInt  {
        var ret = AsyncInt(0)
        if(isNonPendingOpen) {
            struct ArgPad {
                var base : _FilePath? = nil
                var info : DataView
            }
            var pad : ArgPad = ArgPad(base:nil, info:DataView(source))
            pad.base = _path
            ret.store(&pad)
            var pinfo : FilePathInfo = FilePathInfo(type:_path.type, data:_path.data)
            FileItem_Write(&ret, &pinfo, &pad.info, outLimit, outOffset)
            _async = AsyncOnSuccess(&self, ret)
        } else {
            ret.errorValue = AppudoError.INVAL
        }
        return ret
    }

    /**
    Append data to the file.

    - parameter source: The data source for the data to append.
    - parameter outLimit: The size limit of the data to append.
    */
    mutating public func append(_ source : DataWriteSource, _ outLimit : Int = 0) -> AsyncBool {
        var ret = AsyncBool(false)
        if(isNonPendingOpen) {
            struct ArgPad {
                var base : _FilePath? = nil
                var info : DataView
            }
            var pad : ArgPad = ArgPad(base:nil, info:DataView(source))
            pad.base = _path
            ret.store(&pad)
            var pinfo : FilePathInfo = FilePathInfo(type:_path.type, data:_path.data)
             FileItem_Append(&ret, &pinfo, &pad.info, outLimit)
            _async = AsyncOnSuccess(&self, ret)
        }
        return ret
    }

    /**
    Zero copy data to a FileSeekable target.

    - parameter target: The FileSeekable to send the data to.
    - parameter in_limit: The size limit of the data to send.
    - parameter in_offset: The offset into the source to start with.

    - SeeAlso: FileSeekable
    */
    mutating public func send(_ target : FileSeekable, _ in_limit : Int = 0, _ in_offset : Int = 0) -> AsyncInt {
        var ret = AsyncInt(0)
        if(isNonPendingOpen) {
            struct ArgPad {
                var base : _FilePath? = nil
                var target : FileSeekable? = nil
            }
            var pad : ArgPad = ArgPad()
            pad.base = _path
            pad.target = target
            ret.store(&pad)
            var pinfo : FilePathInfo = FilePathInfo(type:_path.type, data:_path.data)
            FileItem_Send(&ret, &pinfo, target.fileFd, in_offset, in_limit)
            _async = AsyncOnSuccess(&self, ret)
        } else {
            ret.errorValue = AppudoError.INVAL
        }
        return ret
    }

    /**
    Truncate the open file.

    - parameter size: The new size for the file.
    */
    mutating public func truncate_open(_ size : Int) -> AsyncBool  {
        var ret = AsyncBool(false)
        if(isNonPendingOpen) {
            FileItem_TruncateOpen(&ret, fileFd, size)
            _async = AsyncOnSuccess(&self, ret)
        }
        return ret
    }

    /**
    Truncate the file.

    - parameter size: The new size for the file.
    */
    public func truncate(_ size : Int) -> AsyncBool  {
        var ret = AsyncBool(false)
        struct ArgPad {
            var base : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cbase = ret.arg(self.path, &pad.base)
        ret.store(&pad)
        FileItem_Truncate(&ret, cbase, size)
        return ret
    }

    /**
    Read the file as String.

    - parameter sizeLimit: The size limit to read from file.
    - parameter offset: The offset to start from.
    */
    mutating public func readAsText( _ sizeLimit : Int = 0, _ offset : Int = 0) -> AsyncStruct<String>
    {
        var ret = AsyncStruct<String>(nil)
        if(isNonPendingOpen) {
            struct ArgPad {
                var base : _FilePath? = nil
            }
            var pad : ArgPad = ArgPad()
            pad.base = _path
            ret.store(&pad)
            var pinfo : FilePathInfo = FilePathInfo(type:_path.type, data:_path.data)
            FileItem_ReadAsText(&ret, &pinfo, sizeLimit, offset)
            _async = AsyncOnSuccess(&self, ret)
        }
        return ret
    }

    /**
    Read the file as ContiguousArray.

    - parameter sizeLimit: The size limit to read from file.
    - parameter offset: The offset to start from.
    */
    mutating public func readAsArray(_ sizeLimit : Int = 0, _ offset : Int = 0) -> AsyncStruct<ContiguousArray<UInt8>>
    {
        var ret = AsyncStruct<ContiguousArray<UInt8>>(nil)
        if(isNonPendingOpen) {
            struct ArgPad {
                var base : _FilePath? = nil
            }
            var pad : ArgPad = ArgPad()
            pad.base = _path
            ret.store(&pad)
            var pinfo : FilePathInfo = FilePathInfo(type:_path.type, data:_path.data)
            FileItem_ReadAsArray(&ret, &pinfo, sizeLimit, offset)
            _async = AsyncOnSuccess(&self, ret)
        }
        return ret
    }
}
