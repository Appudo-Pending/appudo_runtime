/*
    appudo_env.swift is part of Appudo

    Copyright (C) 2015-2016
        bc00940f92e19b5d84931da5bbb6bce10b8e341bdd9d98d016513a164e790c05 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

/**
For each registered domain there is a property with the domain name in the Domain struct.

- SeeAlso: StaticDomain
*/
public struct Domain {
    /**
    Access a domain by its name XXX.
    */
    public static var XXX : StaticDomain {
        fatalError("do not use")
    }
}

/**
For each registered setting there is a property with the setting name in the Setting struct.

- SeeAlso: SettingVar
*/
public struct Setting {
    /**
    Access a setting by its name XXX.
    */
    public static var XXX : SettingVar {
        fatalError("do not use")
    }
}

/**
For each registered directory there is a property with the directory name in the Dir struct.

- SeeAlso: FileItem
*/
public struct Dir {
    /**
    Access a directory by its name XXX.
    */
    public static var XXX : FileItem {
        fatalError("do not use")
    }
}

/**
For each registered role there is a property with the role name in the Role struct.
*/
public struct Role {
    /**
    Access a role by its name XXX.
    */
    public static var XXX : GroupID {
        fatalError("do not use")
    }
}
