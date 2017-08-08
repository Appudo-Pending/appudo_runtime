/*
    HTTPRequestStatus.swift is part of Appudo

    Copyright (C) 2015-2016
        4bea15c834854bf9670dc6a1cbc9a9dda7cf418ef53b8edbb11b3df946a0c45e source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

/**
HTTPRequestStatus contains the http status codes.

- SeeAlso: HTTPClient
*/
public enum HTTPRequestStatus : Int {
    case S_None = 0
    case S_404  = 1
    case S_500  = 2
    case S_200  = 3
    case S_303  = 4
    case S_304  = 5
}
