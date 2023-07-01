//
//  JsonValue.swift
//  ObjMapper
//
//  Created by JIANG PENG CHENG on 2020/12/17.
//

import Foundation

public enum JsonValue: Codable {
    case string(String)
    case int(Int)
    case uint(UInt)
    case int8(Int8)
    case uint8(UInt8)
    case int16(Int16)
    case uint16(UInt16)
    case int32(Int32)
    case uint32(UInt32)
    case int64(Int64)
    case uint64(UInt64)
    case float(Float)
    case double(Double)
    case bool(Bool)
    case object([String: JsonValue])
    case array([JsonValue])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(UInt.self) {
            self = .uint(value)
        } else if let value = try? container.decode(Int32.self) {
            self = .int32(value)
        } else if let value = try? container.decode(UInt32.self) {
            self = .uint32(value)
        } else if let value = try? container.decode(Int64.self) {
            self = .int64(value)
        } else if let value = try? container.decode(UInt64.self) {
            self = .uint64(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode([String: JsonValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([JsonValue].self) {
            self = .array(value)
        } else {
            throw DecodingError.typeMismatch(JsonValue.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Not a JSON"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let val):
            try container.encode(val)
        case .int(let val):
            try container.encode(val)
        case .int8(let val):
            try container.encode(val)
        case .int16(let val):
            try container.encode(val)
        case .int32(let val):
            try container.encode(val)
        case .int64(let val):
            try container.encode(val)
        case .uint(let val):
            try container.encode(val)
        case .uint8(let val):
            try container.encode(val)
        case .uint16(let val):
            try container.encode(val)
        case .uint32(let val):
            try container.encode(val)
        case .uint64(let val):
            try container.encode(val)
        case .float(let val):
            try container.encode(val)
        case .double(let val):
            try container.encode(val)
        case .bool(let val):
            try container.encode(val)
        case .object(let val):
            try container.encode(val)
        case .array(let val):
            try container.encode(val)
        }
    }
    
    public var dictionaryValue: [String: JsonValue]?{
        if case let JsonValue.object(v) = self {
            return v
        } else {
            return nil
        }
    }
    
    public var arrayValue: [JsonValue]?{
        if case let JsonValue.array(v) = self {
            return v
        } else {
            return nil
        }
    }

    public var intValue: Int { value() }
    public var int8Value: Int8 { value() }
    public var int16Value: Int16 { value() }
    public var int32Value: Int32 { value() }
    public var int64Value: Int64 { value() }
    public var uintValue: UInt { value() }
    public var uint8Value: UInt8 { value() }
    public var uint16Value: UInt16 { value() }
    public var uint32Value: UInt32 { value() }
    public var uint64Value: UInt64 { value()}
    public var floatValue: Float { value()}
    public var doubleValue: Double { value()}
    public var boolValue: Bool {
        switch self {
        case .int(let val):
            return val != 0
        case .int8(let val):
            return val != 0
        case .int16(let val):
            return val != 0
        case .int32(let val):
            return val != 0
        case .int64(let val):
            return val != 0
        case .uint(let val):
            return val != 0
        case .uint8(let val):
            return val != 0
        case .uint16(let val):
            return val != 0
        case .uint32(let val):
            return val != 0
        case .uint64(let val):
            return val != 0
        case .float(let val):
            return val != 0
        case .double(let val):
            return val != 0
        case .bool(let val):
            return val
        case .string(let val):
            return (val as NSString).boolValue
        case .object(_), .array(_):
            return false
        }
    }
    
    private func value<T>()->T where T:BinaryInteger & LosslessStringConvertible {
        switch self {
        case .int(let val):
            return T(val)
        case .int8(let val):
            return T(val)
        case .int16(let val):
            return T(val)
        case .int32(let val):
            return T(val)
        case .int64(let val):
            return T(val)
        case .uint(let val):
            return T(val)
        case .uint8(let val):
            return T(val)
        case .uint16(let val):
            return T(val)
        case .uint32(let val):
            return T(val)
        case .uint64(let val):
            return T(val)
        case .float(let val):
            return T(val)
        case .double(let val):
            return T(val)
        case .bool(let val):
            return T(val ? 1 : 0)
        case .string(let val):
            return T(val) ?? 0
        case .object(_), .array(_):
            return 0
        }
    }
    
    private func value<T>()->T where T:BinaryFloatingPoint & LosslessStringConvertible {
        switch self {
        case .int(let val):
            return T(val)
        case .int8(let val):
            return T(val)
        case .int16(let val):
            return T(val)
        case .int32(let val):
            return T(val)
        case .int64(let val):
            return T(val)
        case .uint(let val):
            return T(val)
        case .uint8(let val):
            return T(val)
        case .uint16(let val):
            return T(val)
        case .uint32(let val):
            return T(val)
        case .uint64(let val):
            return T(val)
        case .float(let val):
            return T(val)
        case .double(let val):
            return T(val)
        case .bool(let val):
            return T(val ? 1 : 0)
        case .string(let val):
            return T(val) ?? 0
        case .object(_), .array(_):
            return 0
        }
    }
}

