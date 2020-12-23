//
//  Backed.swift
//  ObjMapper
//
//  Created by JIANG PENG CHENG on 2020/12/17.
//

import Foundation

@propertyWrapper
public struct Backed<T: Codable & LosslessStringConvertible>: Codable {
    public var wrappedValue: T?
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = decodeValue(with: container)
    }
    
    public init() {
        self.wrappedValue = nil
    }
    
    public init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
}

public protocol DefaultValue {
    associatedtype Value: Codable
    static var defaultValue: Value { get }
}

@propertyWrapper
public struct Default<T: DefaultValue>: Codable {
    public typealias ValueType = T.Value
    public var wrappedValue: ValueType
    public init(wrappedValue: ValueType) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = decodeValue(with: container) ?? T.defaultValue
    }
}

public extension KeyedDecodingContainer {
    func decode<T>(_ type: Default<T>.Type, forKey key: Key) throws -> Default<T> where T: DefaultValue {
        try decodeIfPresent(type, forKey: key) ?? Default(wrappedValue: T.defaultValue)
    }
    
    func decode<T>(_ type: Backed<T>.Type, forKey key: Key) throws -> Backed<T> where T: LosslessStringConvertible {
        try decodeIfPresent(type, forKey: key) ?? Backed<T>()
    }
}

public extension KeyedEncodingContainer {
    mutating func encode<T>(_ value: Backed<T>, forKey key: KeyedEncodingContainer<K>.Key) throws where T : LosslessStringConvertible{
        try encodeIfPresent(value.wrappedValue, forKey: key)
    }
}

public extension Int {
    enum Zero: DefaultValue {
        public static let defaultValue = 0
    }
}

public extension Int8{
    enum Zero: DefaultValue {
        public static let defaultValue: Int8 = 0
    }
}

public extension Int16{
    enum Zero: DefaultValue {
        public static let defaultValue: Int16 = 0
    }
}

public extension Int32{
    enum Zero: DefaultValue {
        public static let defaultValue: Int32 = 0
    }
}

public extension Int64{
    enum Zero: DefaultValue {
        public static let defaultValue: Int64 = 0
    }
}

public extension UInt{
    enum Zero: DefaultValue {
        public static let defaultValue: UInt = 0
    }
}

public extension UInt8{
    enum Zero: DefaultValue {
        public static let defaultValue: UInt8 = 0
    }
}

public extension UInt16{
    enum Zero: DefaultValue {
        public static let defaultValue: UInt16 = 0
    }
}

public extension UInt32{
    enum Zero: DefaultValue {
        public static let defaultValue: UInt32 = 0
    }
}

public extension UInt64{
    enum Zero: DefaultValue {
        public static let defaultValue: UInt64 = 0
    }
}

public extension String{
    enum Empty: DefaultValue {
        public static let defaultValue = ""
    }
}

public extension Bool {
    enum False: DefaultValue {
        public static let defaultValue = false
    }
    enum True: DefaultValue {
        public static let defaultValue = true
    }
}

private func decodeValue<T, U>(with container: SingleValueDecodingContainer, type: U) -> T? where U: BinaryInteger & LosslessStringConvertible {
    if let num = try? container.decode(Int64.self) {
        return U(num) as? T
    } else if let str = try? container.decode(String.self) {
        return U(str) as? T
    } else if let num = try? container.decode(UInt64.self) {
        return U(num) as? T
    }  else if let num = try? container.decode(Double.self) {
        return U(num) as? T
    } else if let bool = try? container.decode(Bool.self) {
        return U(bool ? 1 : 0) as? T
    } else {
        return nil
    }
}

private func decodeValue<T, U>(with container: SingleValueDecodingContainer, type: U) -> T? where U: BinaryFloatingPoint & LosslessStringConvertible {
    if let num = try? container.decode(Int64.self) {
        return U(num) as? T
    } else if let str = try? container.decode(String.self) {
        return U(str) as? T
    } else if let num = try? container.decode(UInt64.self) {
        return U(num) as? T
    } else if let num = try? container.decode(Double.self) {
        return U(num) as? T
    } else if let bool = try? container.decode(Bool.self) {
        return U(bool ? 1 : 0) as? T
    } else {
        return nil
    }
}

private func decodeValue<T: Codable>(with container: SingleValueDecodingContainer) -> T? {
    if let v = try? container.decode(T.self) {
        return v
    } else if T.self == String.self {
        if let num = try? container.decode(Int64.self) {
            return "\(num)" as? T
        } else if let num = try? container.decode(UInt64.self) {
            return "\(num)" as? T
        }  else if let num = try? container.decode(Double.self) {
            return "\(num)" as? T
        }  else if let num = try? container.decode(Bool.self) {
            return "\(num)" as? T
        }
    } else if T.self == Bool.self {
        if let num = try? container.decode(Int64.self) {
            return (num != 0) as? T
        } else if let str = try? container.decode(String.self) {
            return Bool(str) as? T
        } else if let num = try? container.decode(UInt64.self) {
            return (num != 0) as? T
        }  else if let num = try? container.decode(Double.self) {
            return (num != 0) as? T
        }
    } else if T.self == Int.self {
        return decodeValue(with: container, type: Int(0))
    } else if T.self == UInt.self {
        return decodeValue(with: container, type: UInt(0))
    } else if T.self == Double.self {
        return decodeValue(with: container, type: Double(0))
    } else if T.self == Float.self {
        return decodeValue(with: container, type: Float(0))
    } else if T.self == Int8.self {
        return decodeValue(with: container, type: Int8(0))
    } else if T.self == Int16.self {
        return decodeValue(with: container, type: Int16(0))
    } else if T.self == Int32.self {
        return decodeValue(with: container, type: Int32(0))
    } else if T.self == Int64.self {
        return decodeValue(with: container, type: Int64(0))
    } else if T.self == UInt8.self {
        return decodeValue(with: container, type: UInt8(0))
    } else if T.self == UInt16.self {
        return decodeValue(with: container, type: UInt16(0))
    } else if T.self == UInt32.self {
        return decodeValue(with: container, type: UInt32(0))
    } else if T.self == UInt64.self {
        return decodeValue(with: container, type: UInt64(0))
    }
    
    return nil
}

