/*
    Error.swift is part of Appudo

    Copyright (C) 2015-2016
        4bea15c834854bf9670dc6a1cbc9a9dda7cf418ef53b8edbb11b3df946a0c45e source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

/**
AppudoError holds the numeric error values and their string representations.
Most of the error values are mirroring common linux error codes.
*/
public enum AppudoError : Int32, Error {
    case None = 0
    case Unknown = -1
    case PERM   = 1
    case NOENT  = 2
    case SRCH   = 3
    case INTR   = 4
    case IO	 = 5
    case NXIO	 = 6
    case TOOBIG	 = 7
    case NOEXEC = 8
    case BADF	 = 9
    case CHILD	 = 10
    case AGAIN	 = 11
    case NOMEM  = 12
    case ACCES  = 13
    case FAULT  = 14
    case NOTBLK = 15
    case BUSY   = 16
    case EXIST  = 17
    case XDEV   = 18
    case NODEV  = 19
    case NOTDIR = 20
    case ISDIR  = 21
    case INVAL  = 22
    case NFILE  = 23
    case MFILE  = 24
    case NOTTY  = 25
    case TXTBSY = 26
    case FBIG   = 27
    case NOSPC  = 28
    case SPIPE  = 29
    case ROFS   = 30
    case MLINK  = 31
    case PIPE   = 32
    case DOM    = 33
    case RANGE  = 34
    case DEADLK = 35
    case NAMETOOLONG = 36
    case NOLCK  = 37
    case NOSYS  = 38
    case NOTEMPTY = 39
    case LOOP     = 40
    case NOMSG    = 42
    case IDRM     = 43
    case CHRNG    = 44
    case L2NSYNC  = 45
    case L3HLT    = 46
    case L3RST    = 47
    case LNRNG    = 48
    case UNATCH   = 49
    case NOCSI    = 50
    case L2HLT    = 51
    case BADE     = 52
    case BADR     = 53
    case XFULL    = 54
    case NOANO    = 55
    case BADRQC   = 56
    case BADSLT   = 57
    case BFONT    = 59
    case NOSTR    = 60
    case NODATA   = 61
    case TIME     = 62
    case NOSR     = 63
    case NONET    = 64
    case NOPKG    = 65
    case REMOTE   = 66
    case NOLINK   = 67
    case ADV      = 68
    case SRMNT    = 69
    case COMM     = 70
    case PROTO    = 71
    case MULTIHOP = 72
    case DOTDOT   = 73
    case BADMSG   = 74
    case OVERFLOW = 75
    case NOTUNIQ  = 76
    case BADFD    = 77
    case REMCHG   = 78
    case LIBACC   = 79
    case LIBBAD   = 80
    case LIBSCN   = 81
    case LIBMAX   = 82
    case LIBEXEC  = 83
    case ILSEQ    = 84
    case RESTART  = 85
    case STRPIPE  = 86
    case USERS    = 87
    case NOTSOCK  = 88
    case DESTADDRREQ = 89
    case MSGSIZE     = 90
    case PROTOTYPE   = 91
    case NOPROTOOPT  = 92
    case PROTONOSUPPORT = 93
    case SOCKTNOSUPPORT = 94
    case OPNOTSUPP      = 95
    case PFNOSUPPORT    = 96
    case AFNOSUPPORT    = 97
    case ADDRINUSE      = 98
    case ADDRNOTAVAIL   = 99
    case NETDOWN        = 100
    case NETUNREACH     = 101
    case NETRESET       = 102
    case CONNABORTED    = 103
    case CONNRESET      = 104
    case NOBUFS         = 105
    case ISCONN         = 106
    case NOTCONN        = 107
    case SHUTDOWN       = 108
    case TOOMANYREFS    = 109
    case TIMEDOUT       = 110
    case CONNREFUSED    = 111
    case HOSTDOWN       = 112
    case HOSTUNREACH    = 113
    case ALREADY        = 114
    case INPROGRESS     = 115
    case STALE          = 116
    case UCLEAN         = 117
    case NOTNAM         = 118
    case NAVAIL         = 119
    case ISNAM          = 120
    case REMOTEIO       = 121
    case DQUOT          = 122
    case NOMEDIUM       = 123
    case MEDIUMTYPE     = 124
    case CANCELED       = 125
    case NOKEY          = 126
    case KEYEXPIRED	 = 127
    case KEYREVOKED	 = 128
    case KEYREJECTED	 = 129
    case OWNERDEAD      = 130
    case NOTRECOVERABLE = 131
    case RFKILL         = 132
    case HWPOISON       = 133

    /**
    Returns the string message for the error.
    */
    public var text : String {
        switch(self) {
            case .None:
                return "no error"
            case .Unknown:
                return "unknown error"
            default:
                return "internal error"
        }
    }
}
