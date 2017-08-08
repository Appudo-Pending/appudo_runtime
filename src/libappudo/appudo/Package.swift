/*
    Package.swift is part of Appudo

    Copyright (C) 2015-2017
        529fa9a39aa978e22b253d7636409ca95bd62a7a69442932bad54b470f47cd5a source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/
import libappudo_bridge

public struct Package {

    /**
    Create a deployable package for an entire account.

    - parameter account: The account id to create the package for.
    - parameter result: The result package file.
    - parameter keepPasswords: Keep salted user password hashs for the package file.
    */
    public static func fromAccount(_ account : AccountID, _ result : FileItem, keepPasswords : Bool = false) -> AsyncBool {
        var ret = AsyncBool(false)
        Account_PackageAccount(&ret, account.rawValue, keepPasswords ? 1 :0, result.fileFd)
        return ret
    }

    /**
    Deploy a package to an account.

    - parameter account: The account id to deploy the package to.
    - parameter package: The package file.
    - parameter prefix: A String prepended to all resource names created from the package.
    */
    public static func deploy(_ account : AccountID, _ package : FileItem, _ prefix : String = "") -> AsyncBool {
        var ret = AsyncBool(false)
        struct ArgPad {
            var prefix : AnyObject? = nil
        }
        var pad : ArgPad = ArgPad()
        let cprefix = ret.arg(prefix, &pad.prefix)
        ret.store(&pad)
        Account_PackageDeploy(&ret, account.rawValue, package.fileFd, cprefix)
        return ret
    }
}
