/*
    appudo_page_env.swift is part of Appudo

    Copyright (C) 2015-2016
        bc00940f92e19b5d84931da5bbb6bce10b8e341bdd9d98d016513a164e790c05 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

/**
For each registered cookie there is a property with the cookies name in the Cookie struct.

- SeeAlso: CookieVar
*/
public struct Cookie {
    /**
    Access a cookie by its name XXX.
    */
    public static var XXX : CookieVar {
        fatalError("do not use")
    }
}

/**
For each registered post variable there is a property with the variables name in the Post struct.

- SeeAlso: PostVar
*/
public struct Post {
    /**
    Access a post variable by its name XXX.
    */
    public static var XXX : PostVar {
        fatalError("do not use")
    }
}

/**
For each registered get variable there is a property with the variables name in the Get struct.

- SeeAlso: GetVar
*/
public struct Get {
    /**
    Access a get variable by its name XXX.
    */
    public static var XXX : GetVar {
        fatalError("do not use")
    }
}
