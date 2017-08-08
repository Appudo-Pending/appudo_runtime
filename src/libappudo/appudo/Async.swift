/*
    Async.swift is part of Appudo

    Copyright (C) 2015-2016
        89a46e2bb720c7ec116d9e3c4c4f722938c13856d1277fd8c551db4c0c8f087e source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge

/**
Most of the APIs of Appudo are async. There are multiple data structures for the async handling.
AsyncValue is the common struct value stored on the heap.
The function returning the AsyncValue can return this value as pseudo async or append a heap based real async instance.

- seeAlso: <!(_:)
- seeAlso: <?(_:)
- seeAlso: <?(_:_:)
*/
public class Async : AsyncBase {
    var _data : AsyncInternal = AsyncInternal()
    var _args : AsyncArgPad? = nil
    public var _error : AsyncRaw = .Error(AppudoError.None)

    deinit {
        releaseArgs()
    }

    /**
    Block until any or all asyncs have finished and return one if any.
    */
    public static func any() -> Async? {
        let async = Async_WaitAny()
        if(async == nil) {
            return nil
        }
        let v = Unmanaged<Async>.fromOpaque(async!)
        return v.takeUnretainedValue()
    }

    /**
    Block until all asyncs have finished.
    */
    public static func all() -> Void {
        Async_WaitAll()
    }

    /**
    Run all functions to call later that do not depend on an async.
    */
    public static func later() -> Void {
        Async_DoLater()
    }

    public var errorMsg : String {
        get {
            return errorValue.text
        }
    }

    public var isReady : Bool {
        get {
            return Async_isReady(data) != 0
        }
    }

    public var hasError : Bool {
        get {
            return errorValue != AppudoError.None
        }
    }

    public func cancel() -> Bool {
        return Async_Cancel(data) == 1
    }

    public func waitFor() -> Void {
        Async_getAsPtr(data)
    }

    public var errorValue : AppudoError {
        get {
            return _error.errorValue
        }
        set {
            _error = .Error(newValue)
        }
    }
}

/**
UserAsync can be used to create custom async functions.
This is needed to make the async handling of Appudo work with GCD.
We do not recommend the use of GCD.

- seeAlso: Async
*/
public class UserAsync : Async {
    override public init() {
        super.init()
        Async_Init(data, 1)
    }

    /**
    Set the async to ready state.
    */
    public func resolve() -> Bool {
        if(!isReady) {
            Async_PushReady(data)
            return true
        }
        return false
    }
}

/**
AsyncValue is the common return type for async APIs.

- seeAlso: Async
*/
public struct AsyncValue<B : AsyncReverse> : AsyncData {
    var _factory : AsyncFactory = AsyncFactory(AsyncEmptyFactory<B>.create)
    var _error : AsyncRaw = .Error(AppudoError.Unknown)
    var _store : AsyncStore<B.WType>

    public init(_ v : B.WType) {
        _store = .rawValue(v)
    }

    // Block until the async has finished and return it's value.
    public var value : B.WType {
        switch _store {
        case let .rawValue(v):
            return v
        case let .asyncValue(v):
            return v.value
        }
    }

    /**
    Returns the error message for a failed async.
    */
    public var errorMsg : String {
        if  case .asyncValue(let v) = _store {
            return v.errorMsg
        }
        return errorValue.text
    }

    /**
    Returns true if the async has finished.
    */
    public var isReady : Bool {
        if  case .asyncValue(let v) = _store {
            return v.isReady
        }
        return true
    }

    /**
    Returns true if the async has an error.
    */
    public var hasError : Bool {
        return errorValue != AppudoError.None
    }

    /**
    Force the async to finish.
    */
    public func cancel() -> Bool {
        if case .asyncValue(let v) = _store {
            return v.cancel()
        }
        return true
    }

    /**
    Block until the async  has finished and return the error state.
    */
    public func waitFor() -> Void {
        if case .asyncValue(let v) = _store {
             v.waitFor()
        }
    }

    /**
    Returns the error value of the async.
    */
    public var errorValue : AppudoError {
        get {
            if  case .asyncValue(let v) = _store {
                return v.errorValue
            }
            return _error.errorValue
        }
        mutating set {
            switch _store {
            case .rawValue:
                _error = .Error(newValue)
            case let .asyncValue(v):
                v.errorValue = newValue
            }
        }
    }
}

prefix operator <!
prefix operator <?
infix operator <?

/**
Wait until the async has finished. Aka await.
*/
public prefix func <! <T>(_ async : AsyncValue<T?>) -> T? {
    return async.to()
}

public prefix func <! (_ async : AsyncValue<Int>) -> Int? {
    return async.to()
}

public prefix func <! (_ async : AsyncBool) -> Bool {
    return async.value
}


// TODO assert closure size to 2 pointers
struct ClosureSize {
    let _d1 : CLong = 0
    let _d2 : CLong = 0
}

/**
Schedule a function or closure to call it later.
*/
public prefix func <? (_ value : @escaping () -> Void) -> Bool {
    var closure = ClosureSize()
    let ret : CInt = withUnsafePointer(to:&closure) {
        let ptr = UnsafeMutableRawPointer(mutating:$0).assumingMemoryBound(to:(() -> Void).self)
        ptr.initialize(to:value)
        return Async_CallLater(ptr)
    }
    return ret != 0
}

/**
Schedule a function or closure to call it later when the async has finished.
*/
public func <? <T>(_ async : inout AsyncValue<T>, _ value : @escaping (_ async : Async) -> Void) -> Bool {
    var closure = ClosureSize()
    let ret : CInt = withUnsafePointer(to:&closure) {
        let ptr = UnsafeMutableRawPointer(mutating:$0).assumingMemoryBound(to:((_ : Async) -> Void).self)
        ptr.initialize(to:value)
        if let a = async.asAsync() {
            return AsyncObj_CallLaterAsync(a.data, ptr)
        }
        return 0
    }
    return ret != 0
}

/**
Schedule a function or closure to call it later when the async has finished.
*/
public func <? <T>(_ async : inout AsyncValue<T>, _ value : @escaping () -> Void) -> Bool {
    var closure = ClosureSize()
    let ret : CInt = withUnsafePointer(to:&closure) {
        let ptr = UnsafeMutableRawPointer(mutating:$0).assumingMemoryBound(to:(() -> Void).self)
        ptr.initialize(to:value)
        if let a = async.asAsync() {
            return AsyncObj_CallLaterAsync(a.data, ptr)
        }
        return 0
    }
    return ret != 0
}

public func <? <T:Async>(_ async : inout T, _ value : @escaping (_ async : Async) -> Void) -> Bool {
    var closure = ClosureSize()
    let ret : CInt = withUnsafePointer(to:&closure) {
        let ptr = UnsafeMutableRawPointer(mutating:$0).assumingMemoryBound(to:((_ : Async) -> Void).self)
        ptr.initialize(to:value)
        return AsyncObj_CallLaterAsync(async.data, ptr)
    }
    return ret != 0
}

public func <? <T:Async>(_ async : inout T, _ value : @escaping () -> Void) -> Bool {
    var closure = ClosureSize()
    let ret : CInt = withUnsafePointer(to:&closure) {
        let ptr = UnsafeMutableRawPointer(mutating:$0).assumingMemoryBound(to:(() -> Void).self)
        ptr.initialize(to:value)
        return AsyncObj_CallLaterAsync(async.data, ptr)
    }
    return ret != 0
}

public protocol OptionalType {
  associatedtype TheType
  func getValue() -> TheType?
}

extension Optional : OptionalType {
  public typealias TheType = Wrapped

  public func getValue() -> TheType? {
    return self
  }
}

extension UserAsync {
    public func then(_ value : @escaping () -> Void) -> UserAsync {
        let ret = UserAsync()
        var _this = self
        if(!(_this <? {  (async) in
            value()
            _ = ret.resolve()
        })) {
            _ = ret.resolve()
        }
        return ret
    }
}

extension AsyncValue {
    public func then(_ value : @escaping () -> Void) -> UserAsync {
        let ret = UserAsync()
        var _this = self
        if(!(_this <? {  (async) in
            value()
            _ = ret.resolve()
        })) {
            _ = ret.resolve()
        }
        return ret
    }
}

extension AsyncValue where B.WType == Bool {
    public func then(_ value : @escaping (_ a : B.WType) -> Void) -> UserAsync {
        let ret = UserAsync()
        var _this = self
        if(!(_this <? {  (async) in
            value((async as! _AsyncBool).value)
            _ = ret.resolve()
        })) {
            _ = ret.resolve()
        }
        return ret
    }
}

extension AsyncValue where B.WType == Int {
    public func then(_ value : @escaping (_ a : B.WType) -> Void) -> UserAsync {
        let ret = UserAsync()
        var _this = self
        if(!(_this <? {  (async) in
            value((async as! _AsyncInt).value)
            _ = ret.resolve()
        })) {
            _ = ret.resolve()
        }
        return ret
    }
}

extension AsyncValue where B.WType : OptionalType, B.WType.TheType : AnyObject {
    public func then(_ value : @escaping (_ a : B.WType.TheType?) -> Void) -> UserAsync {
        let ret = UserAsync()
        var _this = self
        if(!(_this <? {  (async) in
            value((async as! _AsyncClass<B.WType.TheType>).value)
            _ = ret.resolve()
        })) {
            _ = ret.resolve()
        }
        return ret
    }
}

extension AsyncValue where B.WType : OptionalType {
    public func then(_ value : @escaping (_ a : B.WType.TheType?) -> Void) -> UserAsync {
        let ret = UserAsync()
        var _this = self
        if(!(_this <? {  (async) in
            value((async as! _AsyncStruct<B.WType.TheType>).value)
            _ = ret.resolve()
        })) {
            _ = ret.resolve()
        }
        return ret
    }
}
