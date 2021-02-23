//
//  FreeformJSONTests.swift
//  FreeformJSONTests
//
//  Created by Fabio Rodella on 26/02/18.
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

import XCTest
@testable import FreeformJSON

class FreeformJSONTests: XCTestCase {
    
    private func fromString(_ json: String) throws -> JSON {
        return try JSONDecoder().decode(JSON.self, from: json.data(using: .utf8)!)
    }
    
    private func toString(_ json: JSON) throws -> String {
        return String(data: try JSONEncoder().encode(json), encoding: .utf8)!
    }
    
    private struct ValidEncodable: Encodable {
        let string: String
        let int: Int
        let double: Double
        let bool: Bool
        let date: Date
    }
    
    // MARK: Decoding
    
    func testDecodeObject() throws {
        let json = """
        {
            "string": "value",
            "int": 1,
            "double": 4.2,
            "bool": true
        }
        """
        let object = try fromString(json)
        XCTAssertNil(object.array)
        XCTAssertNotNil(object.object)
        
        XCTAssertEqual(object["string"].string, "value")
        XCTAssertEqual(object["int"].number, 1)
        XCTAssertEqual(object["double"].number, 4.2)
        XCTAssertEqual(object["bool"].bool, true)
        XCTAssertTrue(object["nonExisting"].isNull)
        XCTAssertTrue(object["string"]["nonExisting"].isNull)
        XCTAssertTrue(object["string"][0].isNull)
        
        XCTAssertNil(object["string"].number)
        XCTAssertNil(object["int"].string)
        XCTAssertNil(object["double"].bool)
        XCTAssertNil(object["bool"].array)
        XCTAssertNil(object["bool"].object)
        XCTAssertFalse(object["string"].isNull)
    }
    
    func testDecodeNestedObject() throws {
        let json = """
        {
            "name": "outer",
            "inner": {
                "name": "inner"
            }
        }
        """
        let object = try fromString(json)
        XCTAssertNil(object.array)
        XCTAssertNotNil(object.object)
        XCTAssertEqual(object["name"].string, "outer")
        XCTAssertEqual(object["inner"]["name"].string, "inner")
    }
    
    func testDecodeObjectWithNull() throws {
        let json = """
        {
            "name": null
        }
        """
        let object = try fromString(json)
        XCTAssertNotNil(object.object)
        XCTAssertNil(object["name"].string)
    }
    
    func testDecodeArrayOfObject() throws {
        let json = """
        [
            {
                "name": "first"
            },
            {
                "name": "second"
            }
        ]
        """
        let object = try fromString(json)
        XCTAssertNil(object.object)
        XCTAssertNotNil(object.array)
        XCTAssertEqual(object[0]["name"].string, "first")
        XCTAssertEqual(object[1]["name"].string, "second")
    }
    
    func testDecodeArrayOfValue() throws {
        let json = """
        [
            "first",
            "second"
        ]
        """
        let object = try fromString(json)
        XCTAssertNil(object.object)
        XCTAssertNotNil(object.array)
        XCTAssertEqual(object[0].string, "first")
        XCTAssertEqual(object[1].string, "second")
    }
    
    func testDecodeFragment() throws {
        let json = """
            "name"
        """
        let fragment = try fromString(json)
        XCTAssertNil(fragment.object)
        XCTAssertNil(fragment.array)
        XCTAssertEqual(fragment.string, "name")
    }
    
    func testDecodeInvalid() {
        let json = """
        {
            "valid": not really
        }
        """
        XCTAssertThrowsError(try fromString(json))
    }
    
    // MARK: Encoding
    
    func testEncodeObject() throws {
        let object: JSON = [
            "string": "value",
            "int": 1,
            "double": 4.2,
            "bool": true,
            "null": nil,
            "nested": [
                "name": "test",
                "value": nil
            ],
            "arrayOfObjects": [
                ["name": "element 1"],
                ["name": "element 2"],
            ],
            "arrayOfValues": [
                "element 1",
                "element 2"
            ]
        ]
        
        let _ = try toString(object)
    }
    
    // MARK: Raw initialization
    
    func testInitFromRawValue() throws {
        // Cast arguments to Any to use the failable initializer and not the ExpressibleBy*Literal ones
        let bool = try JSON(true as Any)
        XCTAssertEqual(bool.bool, true)
        
        let int = try JSON(1 as Any)
        XCTAssertEqual(int.number, 1)
        
        let double = try JSON(4.2 as Any)
        XCTAssertEqual(double.number, 4.2)
        
        let string = try JSON("value" as Any)
        XCTAssertEqual(string.string, "value")
        
        let null = try JSON(nil as Any?)
        XCTAssertTrue(null.isNull)
        
        let validObject = try JSON(["name": "value"])
        XCTAssertNotNil(validObject.object)
        
        XCTAssertThrowsError(try JSON(["calendar": Calendar.current]))
        
        let validArrayOfObjects = try JSON([["name": "value 1"], ["name": "value 2"], ["name": nil]])
        XCTAssertNotNil(validArrayOfObjects.array)
        
        XCTAssertThrowsError(try JSON([["calendar": Calendar.current], ["calendar": Calendar.current]]))
        
        let validArrayOfValues = try JSON(["value 1", "value 2", nil])
        XCTAssertNotNil(validArrayOfValues.array)
    }
    
    // MARK: Literal initialization
    
    func testInitWithValidLiteral() {
        let object: JSON = [
            "string": "value",
            "int": 1,
            "double": 4.2,
            "bool": true,
            "nested": [
                "name": "test",
                "value": nil
            ],
            "arrayOfObjects": [
                ["name": "element 1"],
                ["name": "element 2"],
            ],
            "arrayOfValues": [
                "element 1",
                "element 2"
            ]
        ]
        
        XCTAssertEqual(object["string"].string, "value")
        XCTAssertEqual(object["int"].number, 1)
        XCTAssertEqual(object["double"].number, 4.2)
        XCTAssertEqual(object["bool"].bool, true)
        XCTAssertNotNil(object["nested"].object)
        XCTAssertNotNil(object["arrayOfObjects"].array)
        XCTAssertNotNil(object["arrayOfValues"].array)
    }
    
    // MARK: Encodable initialization
    
    func testInitWithEncodable() throws {
        let date = Date()
        let valid = ValidEncodable(string: "value", int: 1, double: 4.2, bool: true, date: date)
        var object = try JSON.fromEncodable(valid)
        
        XCTAssertEqual(object["string"].string, "value")
        XCTAssertEqual(object["int"].number, 1)
        XCTAssertEqual(object["double"].number, 4.2)
        XCTAssertEqual(object["bool"].bool, true)
        XCTAssertEqual(object["date"].number, date.timeIntervalSinceReferenceDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let customEncoder = JSONEncoder()
        customEncoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        object = try JSON.fromEncodable(valid, withEncoder: customEncoder)
        XCTAssertEqual(object["date"].string, dateFormatter.string(from: date))
    }
    
    // MARK: Raw values
    
    func testGetRawValue() throws {
        // Cast arguments to Any to use the failable initializer and not the ExpressibleBy*Literal ones
        let bool = try JSON(true as Any)
        XCTAssertEqual(bool.rawValue as? Bool, true)
        
        let int = try JSON(1 as Any)
        XCTAssertNil(int.rawValue as? Int)
        XCTAssertEqual(int.rawValue as? Double, 1)
        
        let double = try JSON(4.2 as Any)
        XCTAssertEqual(double.rawValue as? Double, 4.2)
        
        let string = try JSON("value" as Any)
        XCTAssertEqual(string.rawValue as? String, "value")
        
        let null = try JSON(nil as Any?)
        XCTAssertNil(null.rawValue)
        
        let rawDict = ["name": "value"]
        let object = try JSON(rawDict)
        XCTAssertEqual(object.rawValue as! [String: String], rawDict)
        
        let rawArray = ["value 1", "value 2"]
        let array = try JSON(rawArray)
        XCTAssertEqual(array.rawValue as! [String], rawArray)
    }
    
    func testGetRawData() throws {
        let object: JSON = [
            "string": "value",
            "int": 1,
            "double": 4.2,
            "bool": true
        ]
        
        let data = try object.rawJsonData()
        let restoredObject = try JSONDecoder().decode(JSON.self, from: data)
        XCTAssertEqual(object, restoredObject)
    }
    
    func testGetRawJson() throws {
        let object: JSON = [
            "string": "value",
            "int": 1,
            "double": 4.2,
            "bool": true
        ]
        
        var json = try object.rawJson()
        XCTAssertNil(json.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines))
        
        let customEncoder = JSONEncoder()
        customEncoder.outputFormatting = .prettyPrinted
        json = try object.rawJson(withEncoder: customEncoder)
        XCTAssertNotNil(json.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines))
    }
    
    // MARK: Equality
    
    func testDifferent() {
        let object1: JSON = ["name": "test"]
        let object2: JSON = ["element 1", "element 2"]
        XCTAssertNotEqual(object1, object2)
    }
    
    // MARK: Mutability
    
    func testSetObjectValue() {
        var object: JSON = [
            "string": "value",
            "int": 1,
            "double": 4.2,
            "bool": true
        ]
        
        // Change existing property value
        object["string"] = "abc"
        XCTAssertEqual(object["string"].string, "abc")
        
        // Change existing property type
        object["string"] = 4.2
        XCTAssertNil(object["string"].string)
        XCTAssertEqual(object["string"].number, 4.2)
        
        // Add new property
        XCTAssertNil(object["new"].string)
        object["new"] = "new"
        XCTAssertEqual(object["new"].string, "new")
        
        // Remove property
        object["new"] = nil
        XCTAssertNil(object["new"].string)
        
        // Attempt to change non-object
        let before = object
        object["string"]["invalid"] = "abc"
        XCTAssertEqual(before, object)
    }
    
    func testSetArrayValue() {
        var object: JSON = [
            "name": "name",
            "array": [
                "element 1",
                "element 2"
            ]
        ]
        
        // Change with valid index
        object["array"][0] = "element 0"
        XCTAssertEqual(object["array"][0].string, "element 0")
        
        // Attempt to change non-array
        let before = object
        object["name"][0] = "abc"
        XCTAssertEqual(before, object)
    }
    
    // MARK: Swift PM support
    
    static var allTests = [
        ("testDecodeObject", testDecodeObject),
        ("testDecodeNestedObject", testDecodeNestedObject),
        ("testDecodeObjectWithNull", testDecodeObjectWithNull),
        ("testDecodeArrayOfObject", testDecodeArrayOfObject),
        ("testDecodeArrayOfValue", testDecodeArrayOfValue),
        ("testDecodeFragment", testDecodeFragment),
        ("testDecodeInvalid", testDecodeInvalid),
        ("testEncodeObject", testEncodeObject),
        ("testInitFromRawValue", testInitFromRawValue),
        ("testInitWithValidLiteral", testInitWithValidLiteral),
        ("testInitWithEncodable", testInitWithEncodable),
        ("testGetRawValue", testGetRawValue),
        ("testGetRawData", testGetRawData),
        ("testGetRawJson", testGetRawJson),
        ("testDifferent", testDifferent),
        ("testSetObjectValue", testSetObjectValue),
        ("testSetArrayValue", testSetArrayValue)
        ]
}
