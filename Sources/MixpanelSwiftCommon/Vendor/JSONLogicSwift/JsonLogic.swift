//
//  JsonLogic.swift
//  MixpanelSwiftCommon
//
//  Vendored from json-logic-swift (https://github.com/advantagefse/json-logic-swift)
//  Upstream path: Sources/jsonlogic/JsonLogic.swift, tag 1.2.4, commit 9088eed1b26937fe13d248aa24d7632a51be28e2
//  Created by Christos Koninis on 06/06/2018. Copyright (c) 2019 Advantage FSE.
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
//    - all declarations made internal; MixpanelJSONLogicRule is the public entry point
//    - `import JSON` removed
//    - debug `print` on the failed-cast path removed
//    - dead `#if compiler(>=5) && swift(<5)` branch (SR-14356 workaround) removed
//
import Foundation

///  Errors that can be thrown from JsonLogic methods
enum JSONLogicError: Error, Equatable {
    static func == (lhs: JSONLogicError, rhs: JSONLogicError) -> Bool {
        switch lhs {
            case let canNotParseJSONData(ltype):
                if case let canNotParseJSONData(rtype) = rhs {
                    return ltype == rtype
                }
                return false
            case let canNotConvertResultToType(ltype):
                if case let canNotConvertResultToType(rtype) = rhs {
                    return ltype == rtype
                }
                return false
            case .canNotParseJSONRule(let ltype):
                if case let canNotParseJSONRule(rtype) = rhs {
                    return ltype == rtype
                }
                return false
        }
    }

    /// Invalid json data was passed
    case canNotParseJSONData(String)

    /// Invalid json rule was passed
    case canNotParseJSONRule(String)

    /// Could not convert the result from applying the rule to the expected type
    case canNotConvertResultToType(Any.Type)
}

/// A shortcut method to parse and apply a json logic rule.
///
/// If you need to apply the same rule to multiple json data, it is more efficient to
/// instantiate a `JsonLogic` class that will cache and reuse the parsed rule.
func applyRule<T>(_ jsonRule: String, to jsonDataOrNil: String? = nil) throws -> T {
    return try JsonLogic(jsonRule).applyRule(to: jsonDataOrNil)
}

/// It parses json rule strings and executes the rules on provided data.
final class JsonLogic {
    // The parsed json string to an Expression that can be used for evaluation upon specific data
    private let parsedRule: Expression

    /**
    It parses the string containing a json logic and caches the result for reuse.

    All calls to `applyRule()` will use the same parsed rule.

    - parameters:
        - jsonRule: A valid json rule string

    - throws:
      - `JSONLogicError.canNotParseJSONRule`
     If The jsonRule could not be parsed, possible the syntax is invalid
      - `ParseError.UnimplementedExpressionFor(_ operator: String)` :
     If you pass an json logic operation that is not currently implemented
      - `ParseError.GenericError(String)` :
     An error occurred during parsing of the rule
    */
    convenience init(_ jsonRule: String) throws {
        try self.init(jsonRule, customOperators: nil)
    }

    /**
    It parses the string containing a json logic and caches the result for reuse.

    All calls to `applyRule()` will use the same parsed rule.

    - parameters:
        - jsonRule: A valid json rule string
        - customOperators: custom operations that will be used during evalution

    - throws:
      - `JSONLogicError.canNotParseJSONRule`
     If The jsonRule could not be parsed, possible the syntax is invalid
      - `ParseError.UnimplementedExpressionFor(_ operator: String)` :
     If you pass an json logic operation that is not currently implemented
      - `ParseError.GenericError(String)` :
     An error occurred during parsing of the rule
    */
    init(_ jsonRule: String, customOperators: [String: (JSON?) -> JSON]?) throws {
        guard let rule = JSON(string: jsonRule) else {
            throw JSONLogicError.canNotParseJSONRule("Not valid JSON object")
        }
        parsedRule = try Parser(json: rule, customOperators: customOperators).parse()
    }

    /**
    It applies the rule, you can optionally pass data to be used for the rule.

    - parameter jsonDataOrNil: Data for the rule to operate on

    - throws:
      - `JSONLogicError.canNotConvertResultToType(Any.Type)` :
              When the result from the calculation can not be converted to the return type

            //This throws JSONLogicError.canNotConvertResultToType(Double)
            let r: Double = JsonLogic("{ "===" : [1, 1] }").applyRule()
      - `JSONLogicError.canNotParseJSONData(String)` :
     If `jsonDataOrNil` is not valid json
    */
    func applyRule<T>(to jsonDataOrNil: String? = nil) throws -> T {
        var jsonData: JSON?

        if let jsonDataOrNil = jsonDataOrNil {
            jsonData = JSON(string: jsonDataOrNil)
        }

        let result = try parsedRule.evalWithData(jsonData)

        let convertedToSwiftStandardType = try result.convertToSwiftTypes()

        switch convertedToSwiftStandardType {
            case .some(let value):
                guard let convertedResult = value as? T else {
                    throw JSONLogicError.canNotConvertResultToType(T.self)
                }
                return convertedResult
            default:
                guard let convertedResult = convertedToSwiftStandardType as? T else {
                    throw JSONLogicError.canNotConvertResultToType(T.self)
                }
                return convertedResult
        }
    }
}

extension JSON {
    func convertToSwiftTypes() throws -> Any? {
        switch self {
            case .Error:
                throw JSONLogicError.canNotParseJSONData("\(self)")
            case .Null:
                return Optional<Any>.none
            case .Bool:
                return self.bool
            case .Int:
                return Swift.Int(self.int!)
            case .Double:
                return self.double
            case .String:
                return self.string
            case JSON.Array(let array):
                return try array.map { try $0.convertToSwiftTypes() }
            case .Dictionary:
                let o = self.dictionary!
                return try o.mapValues {
                    try $0.convertToSwiftTypes()
                }
        }
    }
}
