/*
    Async_Private.swift is part of Appudo

    Copyright (C) 2015-2016
        89a46e2bb720c7ec116d9e3c4c4f722938c13856d1277fd8c551db4c0c8f087e source@appudo.com

    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo_bridge

public struct AsyncInternal {
    var _d1 : CLong = 0
    var _d2 : CLong = 0
    var _d3 : CLong = 0
    var _d4 : CLong = 0
}

public func AsyncInternal_Used() -> AsyncInternal {
    return AsyncInternal()
}

public struct AsyncOnSuccess<P> {
    private let _fkt : (_ async : AsyncBase, _:inout P) -> Void
    private var _async : AsyncBase?

    public static func empty(async : AsyncBase, _:inout P) -> Void {
    }

    public init() {
        _fkt = AsyncOnSuccess<P>.empty
        _async = nil
    }

    public init(_ item:inout P, _ async : AsyncBase? = nil, _ fkt : @escaping (_ async : AsyncBase, _:inout P) -> Void = AsyncOnSuccess<P>.empty) {
        _fkt = fkt
        _async = nil
        if(async != nil) {
            let a = async!
            if(a.isReady) {
                if(!a.hasError){
                    _fkt(a, &item)
                }
            }
            else {
                _async = async
            }
        }
    }

    mutating public func waitFor(_ item:inout P) -> Void {
        if(_async != nil) {
            _ = isPending(&item)
        }
    }

    mutating public func isPending(_ item:inout P) -> Bool {
        if(_async != nil) {
            let a = _async!
            if(a.isReady) {
                _async = nil
                if(!a.hasError){
                    _fkt(a, &item)
                }
            }
        }
        return _async != nil
    }
}

struct AsyncArgPad {
    private var _ptr : UnsafeMutableRawPointer
    private let _destroy : (_:UnsafeMutableRawPointer) -> Void
    init<T>(_ p : UnsafeMutablePointer<T>, _ v : inout T) {
        _ptr = UnsafeMutableRawPointer(p)
        p.initialize(to:v)
        _destroy = { (ptr : UnsafeMutableRawPointer) in
            ptr.assumingMemoryBound(to:T.self).deinitialize()
            Async_DelStructPad(ptr.assumingMemoryBound(to:Int8.self))
        }
    }
    func destroy() {
        _destroy(_ptr)
    }

    var ptr : UnsafeMutableRawPointer {
        return _ptr
    }
}

typealias FactoryCreator = (_ : UnsafeMutableRawPointer, _ : UnsafeMutableRawPointer) -> Async?

struct AsyncArgFactory<B : AsyncReverse, T> {
    static func create(_ value: UnsafeMutableRawPointer, _ store: UnsafeMutableRawPointer) -> Async? {
        let a = value.assumingMemoryBound(to:AsyncValue<B>.self)
        let s = store.assumingMemoryBound(to:T.self)

        if case .asyncValue(let a) = a.pointee._store {
            return a
        }

        let async = B._toAsync()
        a.pointee.pack(async)

        let pad = Async_AddStructPad(async.data, MemoryLayout<T>.stride, MemoryLayout<T>.alignment)
        if(pad != nil)
        {
            let ptr = UnsafeMutableRawPointer(pad!).assumingMemoryBound(to:T.self)
            async._args = AsyncArgPad(ptr, &s.pointee)
            return async
        }
        return nil
    }
}

struct AsyncEmptyFactory_Marker<B : AsyncReverse> {
    static func create(_ value: UnsafeMutableRawPointer, _ store: UnsafeMutableRawPointer) -> Async? {
        return AsyncEmptyFactory<B>.create(value, store);
    }
}

struct AsyncEmptyFactory<B : AsyncReverse> {
    static func create(_ value: UnsafeMutableRawPointer, _ store: UnsafeMutableRawPointer) -> Async? {
        let a = value.assumingMemoryBound(to:AsyncValue<B>.self)
        if case .asyncValue(let a) = a.pointee._store {
            return a
        }
        let async = B._toAsync()
        a.pointee.pack(async)
        return async
    }
}

public struct AsyncFactory {
    let _args : UnsafeMutableRawPointer
    let _ctor : FactoryCreator
    init(_ ctor : @escaping FactoryCreator, _ args : UnsafeMutableRawPointer) {
        _args = args
        _ctor = ctor
    }

    init(_ ctor : @escaping FactoryCreator) {
        _args = UnsafeMutableRawPointer(OpaquePointer(bitPattern:1)!)
        _ctor = ctor
    }

    func create(_ value : UnsafeMutableRawPointer) -> Async? {
        return _ctor(value, _args)
    }
}

public protocol AsyncBase {
    var errorMsg : String { get }
    var isReady : Bool { get }
    var hasError : Bool { get }
    var unpack : AsyncBase { get }
    var errorValue : AppudoError { get set }
    var internalValue : AsyncRaw { get set }
    var internalInt : Int { get set }
    func cancel() -> Bool
    func waitFor() -> Void
    mutating func resetError() -> Void

    func to<W>() -> W?
}

extension Async {
    public func releaseArgs() {
        if(_args != nil) {
            _args!.destroy()
            _args = nil
        }
    }

    public var data : UnsafeMutablePointer<Int8> {
        return withUnsafePointer(to:&_data) { return UnsafeMutableRawPointer(mutating:$0).assumingMemoryBound(to:Int8.self) }
    }

    public var rawArgPad : UnsafeMutableRawPointer? {
        return _args?.ptr ?? nil
    }

    public func resetError() -> Void {
        errorValue = AppudoError.None
    }
    public var internalInt : Int {
        get {
            return _error.intValue
        }
        set {
            _error.intValue = newValue
        }
    }

    public var internalValue : AsyncRaw {
        get {
            return _error
        }
        set {
            _error = newValue
        }
    }

    public var unpack : AsyncBase {
       return self
    }

    public func to<W>() -> W? {
        fatalError("do not use")
    }
}

public protocol AsyncData : AsyncBase {
    associatedtype VT
    var value : VT { get }
    var rawValue : VT { get set }
}

public class AsyncInstance<IT> : Async
{

    public var value : IT {
        fatalError("must implement")
    }

    public var rawValue : IT {
        get {
            fatalError("do not use")
        }
        set {
            fatalError("do not use")
        }
    }
}

public class _AsyncClass<T:AnyObject> : AsyncInstance<T?> {

    override public init() {
    }

    deinit {
        let v = Async_getAsPtr(data)
        if(v != nil) {
            _ = Unmanaged<T>.fromOpaque(v!).takeRetainedValue()
        }
    }

    override public var rawValue : T? {
        get {
            fatalError("do not use")
        }
        set {
            if let v = newValue {
                Async_setPtr(data, toRetainedVoid(v))
            }
        }
    }

    override public var value : T? {
        let v = Async_getAsPtr(data)
        return v == nil ? nil : Unmanaged<T>.fromOpaque(v!).takeUnretainedValue()
    }
}

public class _AsyncStruct<T> : AsyncInstance<T?> {
    public var _value : T? = nil

    override public init() {
    }

    override public var value : T? {
        _ = Async_getAsPtr(data)
        return hasError ? nil : _value
    }

    override public var rawValue : T? {
        get {
            return _value
        }
        set {
            _value = newValue
        }
    }
}

public class _AsyncInt : AsyncInstance<Int> {
    public typealias Ret = AsyncInstance<Int>

    override public init() {
    }

    override public var value : Int {
        return Async_getAsInt(data)
    }

    override public var rawValue : Int {
        get {
            fatalError("do not use")
        }
        set {
            Async_setInt(data, newValue)
        }
    }
}

public class _AsyncBool : AsyncInstance<Bool> {
    public typealias Ret = AsyncInstance<Bool>

    override public init() {
    }

    override public var value : Bool {
        _ = Async_getAsInt(data)
        return errorValue == AppudoError.None
    }

    override public var rawValue : Bool {
        get {
            fatalError("do not use")
        }
        set {
            errorValue = newValue ? AppudoError.None : AppudoError.Unknown
        }
    }
}

public typealias AsyncClass<T:AnyObject> = AsyncValue<T?>
public typealias AsyncStruct<T> = AsyncValue<T?>
public typealias AsyncInt = AsyncValue<Int>
public typealias AsyncBool = AsyncValue<Bool>

enum AsyncStore<B> {
    case rawValue(B)
    case asyncValue(AsyncInstance<B>)
}

public enum AsyncRaw {
    case RawInt(Int)
    case Error(AppudoError)

    var errorValue : AppudoError {
        get {
            if case .Error(let v) = self {
                return v
            }
            return AppudoError.None
        }
        mutating set {
            self = .Error(newValue)
        }
    }

    var intValue : Int {
        get {
            if case .RawInt(let v) = self {
                return v
            }
            return 0
        }
        mutating set {
            self = .RawInt(newValue)
        }
    }
}

public protocol AsyncReverse {
    associatedtype WType
    static func _toAsync() -> AsyncInstance<WType>
}

extension Bool : AsyncReverse {
    public static func _toAsync() -> AsyncInstance<Bool> {
        return _AsyncBool()
    }
}

extension Int : AsyncReverse {
    public static func _toAsync() -> AsyncInstance<Int> {
        return _AsyncInt()
    }
}

public struct AsyncVoid : AsyncReverse {
    public static func _toAsync() -> AsyncInstance<Void> {
        return AsyncInstance<Void>()
    }
}

extension Optional : AsyncReverse {
}

extension Optional where Wrapped : AnyObject {
    public static func _toAsync() -> AsyncInstance<Wrapped?> {
        return _AsyncClass<Wrapped>()
    }
}

extension Optional {
    public static func _toAsync() -> AsyncInstance<Wrapped?> {
        return _AsyncStruct<Wrapped>()
    }
}

public struct AsyncArg {
    public static func save(_ str : String, _ holder : inout AnyObject?) -> UnsafePointer<Int8> {
        let a : (AnyObject?, UnsafePointer<Int8>)  =  _convertConstStringToUTF8PointerArgument(str)
        holder = a.0
        return a.1
    }
    public static func save(_ str : StringData, _ holder : inout AnyObject?) -> UnsafePointer<Int8> {
        let a : (AnyObject?, UnsafePointer<Int8>)  =  str._info
        holder = a.0
        return a.1
    }
}

extension AsyncValue where B.WType == Bool {
    public var value : B.WType {
        switch _store {
        case .rawValue:
            return !hasError
        case let .asyncValue(v):
            return v.value
        }
    }

    public func to() -> Bool? {
        return value ? true : nil as Bool?
    }
}

extension AsyncValue {

    mutating public func store<T>(_ argPad : inout T) -> Void {
        _factory = AsyncFactory(AsyncArgFactory<B, T>.create, &argPad)
    }

    public func arg(_ str : String, _ holder : inout AnyObject?) -> UnsafePointer<Int8> {
        return AsyncArg.save(str, &holder)
    }

    public func arg(_ str : StringData, _ holder : inout AnyObject?) -> UnsafePointer<Int8> {
        return AsyncArg.save(str, &holder)
    }

    mutating public func pack(_ inst : AsyncInstance<B.WType>) ->Void {
        let raw = rawValue
        _store = .asyncValue(inst)
        inst.rawValue = raw
    }

    public var unpack : AsyncBase {
        if case .asyncValue(let v) = _store {
            return v
        }
        return self
    }

    public mutating func toAsync() -> Async? {
        return _factory.create(&self)
    }

    public mutating func asAsync() -> Async? {
        if case .asyncValue(let v) = _store {
            return v
        }
        _factory = AsyncFactory(AsyncEmptyFactory_Marker<B>.create)
        let ret = toAsync()
        if(ret != nil) {
            Async_Init(ret!.data, 0);
            Async_Reset(ret!.data, 1);
            return ret
        }
        return nil
    }

    mutating public func resetError() -> Void {
        errorValue = AppudoError.None
    }

    public var internalValue : AsyncRaw {
        get {
            if case .asyncValue(let v) = _store {
                return v.internalValue
            }
            return _error
        }
        mutating set {
            switch _store {
            case .rawValue:
                _error = newValue
            case let .asyncValue(v):
                v.internalValue = newValue
            }
        }
    }

    public var internalInt : Int {
        get {
            if case .asyncValue(let v) = _store{
                return v.internalInt
            }
            return _error.intValue
        }
        mutating set {
            switch _store {
            case .rawValue:
                _error.intValue = newValue
            case let .asyncValue(v):
                v.internalInt = newValue
            }
        }
    }

    public var rawError : AppudoError {
        get {
            return _error.errorValue
        }
        mutating set {
            _error = .Error(newValue)
        }
    }

    public func to<W:OptionalType>() -> W where W == B.WType {
        return value
    }

    public func to() -> B.WType? {
        return value
    }

    public func to<W>() -> W? {
        fatalError("do not use")
    }

    public var rawValue : B.WType {
        get {
            switch _store {
            case let .rawValue(v):
                return v
            case let .asyncValue(v):
                return v.rawValue
            }
        }
        mutating set {
            switch _store {
            case .rawValue:
                _store = .rawValue(newValue)
            case let .asyncValue(v):
                v.rawValue = newValue
            }
        }
    }
}
