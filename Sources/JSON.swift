//
//  JSON.swift
//  FreeformJSON
//
//  Created by Fabio Rodella on 24/02/18.
//  Copyright © 2018 Rodels. All rights reserved.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.

import Foundation

public enum JSON {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    indirect case array([JSON])
    indirect case object([String: JSON])
}

// MARK: - Equatable protocol

extension JSON: Equatable {
    
    public static func ==(lhs: JSON, rhs: JSON) -> Bool {
        switch (lhs, rhs) {
        case (.null, .null):
            return true
        case (.bool(let lhsWrapped), .bool(let rhsWrapped)):
            return lhsWrapped == rhsWrapped
        case (.number(let lhsWrapped), .number(let rhsWrapped)):
            return lhsWrapped == rhsWrapped
        case (.string(let lhsWrapped), .string(let rhsWrapped)):
            return lhsWrapped == rhsWrapped
        case (.array(let lhsWrapped), .array(let rhsWrapped)):
            return lhsWrapped == rhsWrapped
        case (.object(let lhsWrapped), .object(let rhsWrapped)):
            return lhsWrapped == rhsWrapped
        default:
            return false
        }
    }
}

// MARK: - Codable protocol

extension JSON: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let number = try? container.decode(Double.self) {
            self = .number(number)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([JSON].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: JSON].self) {
            self = .object(object)
        } else if container.decodeNil() {
            self = .null
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unexpected value type")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .bool(let bool):
            try container.encode(bool)
        case .number(let number):
            try container.encode(number)
        case .string(let string):
            try container.encode(string)
        case .array(let array):
            try container.encode(array)
        case .object(let object):
            try container.encode(object)
        case .null:
            try container.encodeNil()
        }
    }
}

// MARK: - Initialization from raw (untyped) values

extension JSON {
    
    public init(_ value: Any?) throws {
        if let bool = value as? Bool {
            self = .bool(bool)
        } else if let int = value as? Int {
            self = .number(Double(int))
        } else if let number = value as? Double {
            self = .number(number)
        } else if let string = value as? String {
            self = .string(string)
        } else if let array = value as? [Any?] {
            self = .array(try array.map(JSON.init))
        } else if let dictionary = value as? [String: Any?] {
            self = .object(try dictionary.mapValues(JSON.init))
        } else if value == nil {
            self = .null
        } else {
            throw DecodingError.typeMismatch(type(of: value), DecodingError.Context(codingPath: [], debugDescription: "Unexpected value type"))
        }
    }
}

// MARK: - Initialization from literal values

extension JSON: ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension JSON: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: Int) {
        self = .number(Double(value))
    }
}

extension JSON: ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: Double) {
        self = .number(value)
    }
}

extension JSON: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension JSON: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: JSON...) {
        self = .array(elements)
    }
}

extension JSON: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, JSON)...) {
        self = .object(Dictionary<String, JSON>(uniqueKeysWithValues: elements))
    }
}

extension JSON: ExpressibleByNilLiteral {
    
    public init(nilLiteral: ()) {
        self = .null
    }
}

// MARK: - Initialization from other Encodable types {

extension JSON {
    
    public static func fromEncodable<T: Encodable>(_ object: T, withEncoder encoder: JSONEncoder = JSONEncoder()) throws -> JSON {
        let data = try encoder.encode(object)
        return try JSONDecoder().decode(JSON.self, from: data)
    }
}

// MARK: - Data access

extension JSON {
    
    public var bool: Bool? {
        if case .bool(let bool) = self {
            return bool
        }
        return nil
    }
    
    public var number: Double? {
        if case .number(let number) = self {
            return number
        }
        return nil
    }
    
    public var string: String? {
        if case .string(let string) = self {
            return string
        }
        return nil
    }
    
    public var array: [JSON]? {
        if case .array(let array) = self {
            return array
        }
        return nil
    }
    
    public var object: [String: JSON]? {
        if case .object(let object) = self {
            return object
        }
        return nil
    }
    
    public var isNull: Bool {
        if case .null = self {
            return true
        }
        return false
    }
    
    public subscript(key: String) -> JSON {
        get {
            guard case .object(let object) = self else {
                return .null
            }
            return object[key] ?? .null
        }
        set {
            guard case .object(var object) = self else {
                return
            }
            object[key] = newValue
            self = .object(object)
        }
    }
    
    public subscript(index: Int) -> JSON {
        get {
            guard case .array(let array) = self else {
                return .null
            }
            return array[index]
        }
        set {
            guard case .array(var array) = self else {
                return
            }
            array[index] = newValue
            self = .array(array)
        }
    }
}

// MARK: - Raw (untyped) data extraction

extension JSON {
    
    public var rawValue: Any? {
        switch self {
        case .bool(let bool):
            return bool
        case .number(let number):
            return number
        case .string(let string):
            return string
        case .array(let array):
            return array.map { $0.rawValue }
        case .object(let object):
            return object.mapValues { $0.rawValue }
        case .null:
            return nil
        }
    }
    
    public func rawJsonData(withEncoder encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        return try encoder.encode(self)
    }
    
    public func rawJson(withEncoder encoder: JSONEncoder = JSONEncoder()) throws -> String {
        guard let rawJson = try String(data: rawJsonData(withEncoder: encoder), encoding: .utf8) else {
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: [], debugDescription: "Could not encode value"))
        }
        return rawJson
    }
}
