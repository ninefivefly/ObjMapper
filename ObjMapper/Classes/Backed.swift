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

extension Bool {
    enum False: DefaultValue {
        static let defaultValue = false
    }
    enum True: DefaultValue {
        static let defaultValue = true
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
    } else {
        if let string = try? container.decode(String.self) {
            if T.self == Int.self {
                return Int(string) as? T
            } else if T.self == Float.self {
               return Float(string) as? T
            } else if T.self == Bool.self {
                return Bool(string) as? T
            } else if T.self == Double.self {
                return Double(string) as? T
            } else if T.self == UInt.self {
                return UInt(string) as? T
            } else if T.self == Int8.self {
                return Int8(string) as? T
            } else if T.self == Int16.self {
                return Int16(string) as? T
            } else if T.self == Int32.self {
                return Int32(string) as? T
            } else if T.self == Int64.self {
                return Int64(string) as? T
            } else if T.self == UInt8.self {
                return UInt8(string) as? T
            } else if T.self == UInt16.self {
                return UInt16(string) as? T
            } else if T.self == UInt32.self {
                return UInt32(string) as? T
            } else if T.self == UInt64.self {
                return UInt64(string) as? T
            }
        }
    }
    
    return nil
}

