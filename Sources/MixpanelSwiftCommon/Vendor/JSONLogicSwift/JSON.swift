//
//  JSON.swift
//  MixpanelSwiftCommon
//
//  Vendored from json-logic-swift (https://github.com/advantagefse/json-logic-swift)
//  Upstream path: Sources/JSON/JSON.swift, tag 1.2.4, commit 9088eed1b26937fe13d248aa24d7632a51be28e2
//  Created by Christos Koninis on 09/03/2019. Copyright (c) 2019 Advantage FSE.
//
//  MIT License
//
//  Copyright (c) 2019 Advantage FSE
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Local modifications (also listed in THIRD_PARTY_LICENSES.md at the repository root):
//    - all declarations made internal (the type is not part of the MixpanelSwiftCommon public API)
//    - `import JSON` removed; the type now lives in this module
//    - redundant `nil` pattern in `init(_ json: Any)` removed (a Swift 6 language-mode error)
//
import Foundation

enum JSON: Equatable {
    case Null
    case Array([JSON])
    case Dictionary([String: JSON])
    case Int(Int64)
    case Double(Double)
    case String(String)
    case Bool(Bool)
    case Error(JSON2Error)

    enum ContentType {
        case error, null, bool, number, string, array, object
    }

    var type: ContentType {
        switch self {
            case .Error:
                return .error
            case .Null:
                return .null
            case .Bool:
                return .bool
            case .Int, .Double:
                return .number
            case .String:
                return .string
            case .Array:
                return .array
            case .Dictionary:
                return .object
        }
    }

    enum JSON2Error: Error, Equatable, Hashable {
        case failedToParse
        case notJSONValue
        case indexOutOfRange(Int)
        case keyNotFound(String)
        case notSubscriptableType(ContentType)
        case NSError(NSError)
    }

    init() {
        self = .Null
    }

    init(_ array: [JSON]) {
        self = .Array(array)
    }

    init(_ dictionary: [String: JSON]) {
        self = .Dictionary(dictionary)
    }

    //swiftlint:disable syntactic_sugar
    init(_ json: Any) {
        switch json {
            case let array as Swift.Array<Any>:
                self = .Array(array.map({ JSON($0) }))
            case let dictionary as Swift.Dictionary<String, Any>:
                self = .Dictionary(dictionary.mapValues({ JSON($0) }))
            case let string as Swift.String:
                self = .String(string)
            case let number as NSNumber:
                switch Swift.String(cString: number.objCType) {
                    case "i", "s", "l", "q", "I", "S", "L", "Q":
                        self = .Int(number.int64Value)
                    case "f", "d":
                        self = .Double(number.doubleValue)
                    case "B", "c", "C":
                        self = .Bool(number.boolValue)
                    case "*":
                        self = .String(Swift.String(number.int8Value))
                    default:
                        self = .Error(.notJSONValue)
                }
            case Optional<Any>.none, is NSNull:
                self = .Null
            case let bool as Bool:
                self = .Bool(bool)
            case let int as Swift.Int:
                self = .Int(Int64(int))
            case let double as Swift.Double:
                self = .Double(double)
            default:
                self = .Error(.NSError(NSError(domain: "Can't convert value \(json) to JSON", code: 1)))
        }
    }
    //swiftlint:enable syntactic_sugar

    init(_ data: Data) {
        do {
            self.init(try JSONSerialization.jsonObject(with: data, options: [.allowFragments]))
        } catch let error as NSError {
            self = .Error(.NSError(error))
        } catch {
            self = .Error(.failedToParse)
        }
    }

    init?(string: String, encoding: String.Encoding = .utf8) {
        guard let data = string.data(using: encoding) else {
            return nil
        }
        self.init(data)
    }

    //Strict Equality
    static func === (lhs: JSON, rhs: JSON) -> Bool {
        switch (lhs, rhs) {
            case (.Bool(let x), .Bool(let y)):
                return x == y
            case (.Double(let x), .Double(let y)):
                return x == y
            case (.Int(let x), .Int(let y)):
                return x == y
            case (.String(let lhsString), .String(let rhsString)):
                return lhsString == rhsString
            case (.Dictionary(let lhs), .Dictionary(let rhs)):
                let lhsKeys = lhs.keys
                let rhsKeys = rhs.keys
                if lhsKeys.count == rhsKeys.count {
                    for key in lhsKeys {
                        if lhs[key]! !== rhs[key]! {
                            return false
                        }
                    }
                } else {
                    return false
                }
                return true
            case (.Array(let lhsArray), .Array(let rhsArray)) where lhsArray.count == rhsArray.count:
                for (idx, value) in lhsArray.enumerated() where value !== rhsArray[idx] {
                    return false
                }
                return true
            case (.Null, .Null):
                return true
            default:
                return false
        }
    }

    //Strict inEquality
    static func !== (lhs: JSON, rhs: JSON) -> Bool {
        return !(lhs === rhs)
    }

    //swiftlint:disable:next cyclomatic_complexity function_body_length
    static func == (lhs: JSON, rhs: JSON) -> Bool {
        switch (lhs, rhs) {
            case (.Double(let x), .Double(let y)):
                return x == y
            case (.Int(let x), .Int(let y)):
                return x == y
            case (.Double(let x), .Int(let y)):
                return x == Swift.Double(y)
            case (.Int(let x), .Double(let y)):
                return Swift.Double(x) == y
            case (_, .Bool):
                return lhs == (try? toNumber(rhs))
            case (.Bool, _):
                return (try? toNumber(lhs)) == rhs
            case (.String(let lhsString), .String(let rhsString)):
                return lhsString == rhsString
            case (.String, .Int):
                guard let number = try? toNumber(lhs) else {
                    return false
                }
                return number == rhs
            case (.String, .Double):
                guard let number = try? toNumber(lhs) else {
                    return false
                }
                return number == rhs
            case (.Double, .String):
                guard let number = try? toNumber(rhs) else {
                    return false
                }
                return lhs == number
            case (.Int, .String):
                guard let number = try? toNumber(rhs) else {
                    return false
                }
                return lhs == number
            case (.Dictionary(let lhs), .Dictionary(let rhs)):
                return lhs == rhs
            case (.Array(let lhsArray), .Array(let rhsArray)) where lhsArray.count == rhsArray.count:
                return lhsArray == rhsArray
            case (.Array(let array), _) where array.count <= 1:
                return (array.first ?? .Null) == rhs
            case (_, .Array(let array)) where array.count <= 1:
                return lhs == (array.first ?? .Null)
            case (_, .Null):
                return lhs == JSON(0)
            case (.Null, _):
                return JSON(0) == rhs
            default:
                return false
        }
    }

    static func + (lhs: JSON, rhs: JSON) -> JSON {
        switch (lhs, rhs) {
            case (.Double(let x), .Double(let y)):
                return JSON(x + y)
            case (.Int(let x), .Int(let y)):
                return JSON(x + y)
            case (.Double(let x), .Int(let y)):
                return JSON(x + Swift.Double(y))
            case (.Int(let x), .Double(let y)):
                return JSON(y + Swift.Double(x))
            default:
                return JSON.Null
        }
    }

    static prefix func - (json: JSON) -> JSON {
        switch json {
            case .Double(let x):
                return JSON(-x)
            case .Int(let x):
                return JSON(-x)
            default:
                return JSON.Null
        }
    }

    static func - (lhs: JSON, rhs: JSON) -> JSON {
        return lhs + (-rhs)
    }

    static func * (lhs: JSON, rhs: JSON) -> JSON {
        switch (lhs, rhs) {
            case (.Double(let x), .Double(let y)):
                return JSON(x * y)
            case (.Int(let x), .Int(let y)):
                return JSON(x * y)
            case (.Double(let x), .Int(let y)):
                return JSON(x * Swift.Double(y))
            case (.Int(let x), .Double(let y)):
                return JSON(y * Swift.Double(x))
            default:
                return JSON.Null
        }
    }

    static func / (lhs: JSON, rhs: JSON) -> JSON {
        switch (lhs, rhs) {
            case (.Double(let x), .Double(let y)):
                return .Double(x / y)
            case (.Int(let x), .Int(let y)):
                if x % y == 0 {
                    return .Int(x / y)
                }
                return .Double(Swift.Double(x) / Swift.Double(y))
            case (.Double(let x), .Int(let y)):
                return .Double(x / Swift.Double(y))
            case (.Int(let x), .Double(let y)):
                return .Double(Swift.Double(x) / y)
            default:
                return JSON.Null
        }
    }

    static func % (lhs: JSON, rhs: JSON) -> JSON {
        switch (lhs, rhs) {
            case (.Double(let x), .Double(let y)):
                return .Double(x.truncatingRemainder(dividingBy: y))
            case (.Int(let x), .Int(let y)):
                return .Int(x % y)
            case (.Double(let x), .Int(let y)):
                return .Double(x.truncatingRemainder(dividingBy: Swift.Double(y)))
            case (.Int(let x), .Double(let y)):
                return .Double(Swift.Double(x).truncatingRemainder(dividingBy: y))
            default:
                return JSON.Null
        }
    }

    var bool: Bool? {
        if case .Bool(let value) = self { return value }
        return nil
    }

    var int: Int64? {
        if case .Int(let value) = self { return value }
        return nil
    }

    var double: Double? {
        if case .Double(let value) = self { return value }
        return nil
    }

    var string: String? {
        if case .String(let value) = self { return value }
        return nil
    }

    var array: [JSON]? {
        if case .Array(let value) = self { return value }
        return nil
    }

    //swiftlint:disable:next line_length
    var dictionary: [String: JSON]? {
        if case .Dictionary(let value) = self { return value }
        return nil
    }
}

extension JSON: Comparable {
    static func < (lhs: JSON, rhs: JSON) -> Bool {
        return (try? lessThanWithTypeCoercion(lhs, rhs)) ?? false
    }

    fileprivate static func toNumber(_ json: JSON) throws -> JSON {
        let result = json.toNumber()
        switch json.toNumber() {
            case .Double, .Int:
                return result
            default:
                throw JSON.JSON2Error.notJSONValue
        }
    }

    //swiftlint:disable:next cyclomatic_complexity function_body_length
    private static func lessThanWithTypeCoercion(_ lhs: JSON, _ rhs: JSON) throws -> Bool {
        switch (lhs, rhs) {
            case (.Double(let x), .Double(let y)):
                return x < y
            case (.Int(let x), .Int(let y)):
                return x < y
            case (.Double(let x), .Int(let y)):
                return x < Swift.Double(y)
            case (.Int(let x), .Double(let y)):
                return Swift.Double(x) < y
            case (.Array(let lhsArray), .Array(let rhsArray)):
                return try lessThanWithTypeCoercion(lhsArray.first ?? .Null, rhsArray.first ?? .Null)
            case (_, .Bool):
                return try lessThanWithTypeCoercion(lhs, (try toNumber(rhs)))
            case (.Bool, _):
                return try lessThanWithTypeCoercion(toNumber(lhs), rhs)
            case (.String(let lhsString), .String(let rhsString)):
                return lhsString < rhsString
            case (.String, .Int):
                return try lessThanWithTypeCoercion(try toNumber(lhs), rhs)
            case (.Int, .String):
                return try lessThanWithTypeCoercion(lhs, (try toNumber(rhs)))
            case (.String, .Double):
                return try lessThanWithTypeCoercion(try toNumber(lhs), rhs)
            case (.Double, .String):
                return try lessThanWithTypeCoercion(lhs, (try toNumber(rhs)))
            case (.Array(let array), _):
                return try lessThanWithTypeCoercion(array.first ?? .Null, rhs)
            case (_, .Array(let array)):
                return try lessThanWithTypeCoercion(lhs, array.first ?? .Null)
            case (_, .Null):
                return try lessThanWithTypeCoercion(lhs, JSON(0))
            case (.Null, _):
                return try lessThanWithTypeCoercion(JSON(0), rhs)
            default:
                throw JSON.JSON2Error.notJSONValue
        }
    }

    static func > (lhs: JSON, rhs: JSON) -> Bool {
        guard let isLessThan = try? lessThanWithTypeCoercion(lhs, rhs) else {
            return false
        }
        return !isLessThan && (lhs != rhs)
    }

    static func >= (lhs: JSON, rhs: JSON) -> Bool {
        do {
            let isLessThan = try lessThanWithTypeCoercion(lhs, rhs)
            return !isLessThan || (lhs == rhs)
        } catch {
            return false
        }
    }

    static func <= (lhs: JSON, rhs: JSON) -> Bool {
        do {
            let isLessThan = try lessThanWithTypeCoercion(lhs, rhs)
            return isLessThan || (lhs == rhs)
        } catch {
            return false
        }
    }
}

extension JSON: Hashable {
}

extension JSON: ExpressibleByIntegerLiteral, ExpressibleByArrayLiteral, ExpressibleByBooleanLiteral,
    ExpressibleByNilLiteral, ExpressibleByStringLiteral, ExpressibleByDictionaryLiteral,
    ExpressibleByFloatLiteral
{

    init(stringLiteral value: String) {
        self = .String(value)
    }

    init(nilLiteral: ()) {
        self = .Null
    }

    init(arrayLiteral elements: Int...) {
        self.init(elements)
    }

    init(booleanLiteral value: BooleanLiteralType) {
        self = .Bool(value)
    }

    init(dictionaryLiteral value: (Swift.String, JSON)...) {
        var result: [Swift.String: JSON] = [:]
        for pair in value {
            result[pair.0] = pair.1
        }
        self = .Dictionary(result)
    }

    init(integerLiteral value: IntegerLiteralType) {
        self = .Int(Int64(value))
    }

    init(floatLiteral value: Double) {
        self = .Double(value)
    }
}

extension JSON {
    /**
    If the JSON element is of type .Array, this will return/set the idx element.

    Trying to set an value to an non .Array type will result in runtime error.
    */
    subscript(_ idx: Int) -> JSON {
        get {
            switch self {
                //we want the nested error to propagate unaltered
                case .Error:
                    return self
                case .Array(let array):
                    guard idx < array.count else { return .Error(.indexOutOfRange(idx)) }
                    return array[idx]
                default:
                    return .Error(.notSubscriptableType(self.type))
            }
        }
        set {
            switch self {
                case .Array(var array):
                    if idx < array.count {
                        array[idx] = newValue
                    } else {
                        for _ in array.count..<idx {
                            array.append(.Null)
                        }
                        array.append(newValue)
                    }
                    self = .Array(array)
                default:
                    fatalError("attempted to subscript \"\(self)\" which is not an array")
            }
        }
    }

    /**
    If the JSON element is of type .Dictionary, this will return/set a element by it's key.

    Trying to set an value to an non .Dictionary type will result in runtime error.
    */
    subscript(_ key: Key) -> JSON {
        get {
            switch self {
                //we want the nested error to propagate unaltered
                case .Error:
                    return self
                case .Dictionary(let dictionary):
                    return dictionary[key] ?? .Error(.keyNotFound(key))
                default:
                    return .Error(.notSubscriptableType(self.type))
            }
        }
        set {
            switch self {
                case .Dictionary(var dictionary):
                    dictionary[key] = newValue
                    self = .Dictionary(dictionary)
                default:
                    fatalError("\"\(self)\" is not an object")
            }
        }
    }
}

extension JSON {
    /**
    Evaluates the truth value of the JSON object according to the json logic.

    - Returns: the truth value of the JSON object
    */
    func truthy() -> Bool {
        switch self {
            case .Bool(let bool):
                return bool
            case .Int(let number):
                return number != 0
            case .Double(let number):
                return number != 0.0
            case .String(let string):
                return !string.isEmpty
            case .Array(let array):
                return !array.isEmpty
            case .Dictionary(dictionary):
                return !dictionary!.isEmpty
            default:
                return false
        }
    }
}

extension JSON {
    /**
    Tries to convert the current JSON to a number.

    - Returns: a converted JSON number value (either .Double or .Int) or .Null if it fails
    */
    func toNumber() -> JSON {
        switch self {
            case .Bool(let bool):
                return bool ? 1 : 0
            case .Null:
                return 0
            case .Int:
                return self
            case .Double:
                return self
            case .String(let string):
                guard let integer = Swift.Int(string) else {
                    guard let float = Swift.Double(string) else {
                        return JSON.Null
                    }
                    return JSON(float)
                }
                return JSON(integer)
            default:
                return JSON.Null
        }
    }
}
