/*
    Date.swift is part of Appudo

    Copyright (C) 2015-2016
        8c363e70b3d1ed86d1c8bf704f4c7f423ce1d6c1d0bb40f933cbd46dd4cf1304 source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import Foundation
import libappudo_bridge

extension Date {
    /**
    A basic format to parse and print Date.
    */
    public static let format0 : StaticString = "yyyy-MM-dd'T'HH:mm:ss+00:00"
    /**
    A basic format to parse and print Date.
    */
    public static let format1 : StaticString = "yyyy-MM-dd"

    static public var timeSince1970 : TimeInterval {
        return TimeInterval(Time_Since1970())
    }

    static public var since1970 : Date {
        do {
            return try fromIntervalSince1970(TimeInterval(Time_Since1970()))
        } catch {
            return Date();
        }
    }

    /**
    Get a Data from a time interval sine 00:00:00 UTC on 1 January 1970.

    - parameter interval: The interval for the date.
    */
    static public func fromIntervalSince1970(_ interval : TimeInterval) throws -> Date {
        return Date(timeIntervalSince1970:interval)
    }

    /**
    Parse a string to Data.

    - parameter str: The string containig the date.
    - parameter format: The format used to parse the string.
    - parameter zone: The zone used to parse the string.
    */
    static public func fromString(_ str:String, format : String = String(describing:format1), zone : String = "UTC") throws -> Date {
        let fmt = DateFormatter()
        fmt.dateFormat = format
        fmt.timeZone = TimeZone(abbreviation: zone)
        let date : Date! = fmt.date(from:str)
        if(date !=  nil) {
            return date!
        }
        throw AppudoError.INVAL
    }

    public var toLocal : Date {
        do {
            return try Date.fromIntervalSince1970(TimeInterval(Time_ToLocal(timeIntervalSince1970)))
        } catch {
            return Date();
        }
    }

    public var to1970 : Int {
        return Int(timeIntervalSince1970)
    }

    /**
    Create a string from Data.

    - parameter format: The format used to create the string.
    - parameter zone: The zone used to create the string.
    */
    public func toString(format : String = String(describing:format1), zone : String = "UTC") -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = format
        fmt.timeZone = TimeZone(abbreviation: zone)
        return fmt.string(from:self)
    }
}
