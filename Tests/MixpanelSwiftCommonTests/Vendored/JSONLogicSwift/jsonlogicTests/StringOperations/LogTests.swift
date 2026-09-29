//
//  Vendored from json-logic-swift (https://github.com/advantagefse/json-logic-swift)
//  Upstream path: Tests/jsonlogicTests/StringOperations/LogTests.swift, tag 1.2.4, commit 9088eed1b26937fe13d248aa24d7632a51be28e2
//  Local modifications: imports switched to `@testable import MixpanelSwiftCommon`; reformatted.
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

//
//  IfTests.swift
//  jsonlogicTests
//
//  Created by Christos Koninis on 11/02/2019.
//

import XCTest

@testable import MixpanelSwiftCommon

class LogTests: XCTestCase {

    func testLog() {
        let rule =
            """
            {"log":"apple"}
            """
        XCTAssertEqual("apple", try applyRule(rule, to: nil))
    }

    func testLog_withComplexExpression() {
        let rule =
            """
            {"log":{"cat":[1,[2,3]]}}
            """
        XCTAssertEqual("12,3", try applyRule(rule, to: nil))
    }

    //swiftlint:disable:next function_body_length
    func testLog_nestedInOtherExpressions() {

        let rule =
            """
                    {
                        "if": [{
                        "==": [{
                            "log": {
                                "%": [{
                                    "var": "i"
                                }, 15]
                            }
                        }, 0]
                    }, "fizzbuzz", {
                        "log": {
                            "==": [{
                                "%": [{
                                    "var": "i"
                                }, 3]
                            }, 0]
                        }
                    }, "fizz", {
                        "==": [{
                            "%": [{
                                "var": "i"
                            }, {
                                "log": 5
                            }]
                        }, 0]
                    }, {
                        "log": "buzz"
                    }, {
                        "var": "i"
                    }]
                    }
            """

        XCTAssertEqual("fizzbuzz", try applyRule(rule, to: "{\"i\" : 0}"))
        XCTAssertEqual(1, try applyRule(rule, to: "{\"i\" : 1}"))
        XCTAssertEqual(2, try applyRule(rule, to: "{\"i\" : 2}"))
        XCTAssertEqual("fizz", try applyRule(rule, to: "{\"i\" : 3}"))
        XCTAssertEqual("buzz", try applyRule(rule, to: "{\"i\" : 5}"))
        XCTAssertEqual("fizzbuzz", try applyRule(rule, to: "{\"i\" : 15}"))
        XCTAssertEqual("fizzbuzz", try applyRule(rule, to: "{\"i\" : 45}"))
    }
}
