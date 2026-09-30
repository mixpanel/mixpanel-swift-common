//
//  Vendored from json-logic-swift (https://github.com/advantagefse/json-logic-swift)
//  Upstream path: Tests/jsonlogicTests/AccessingDataOperations/VarTests.swift, tag 1.2.4, commit 9088eed1b26937fe13d248aa24d7632a51be28e2
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
//  VarTests.swift
//  jsonlogic
//
//  Created by Christos Koninis on 2/12/22.
//

import XCTest

@testable import MixpanelSwiftCommon

class VarTests: XCTestCase {

    let emptyIntArray = [Int]()

    func testVar_withDefaultArgument_GivenArgumentIsMissing() {
        let rule =
            """
             {"var": ["a"]}
            """
        XCTAssertNil(try applyRule(rule))
    }

    func testVar_withDefaultArgument() {
        let rule =
            """
             {"var": ["a", 0]}
            """
        XCTAssertEqual(try applyRule(rule), 0)
    }

    func testVar_withInvalidVarPath() {
        let rule =
            """
             {"var": ["a..b"]}
            """
        XCTAssertNil(try applyRule(rule))
    }

    func testVar_withInvalidVarPath_GivenArgumentIsMissing() {
        let rule =
            """
             {"var": ["a..b", 0]}
            """
        XCTAssertEqual(try applyRule(rule), 0)
    }

    func testVar_withDefaultArgumentString() {
        let rule =
            """
             {"var": ["a", "0"]}
            """
        XCTAssertEqual(try applyRule(rule), "0")
    }

    func testVar_withDefaultArgumentString_GivenArgumentExistsInData() {
        let rule =
            """
             {"var": ["a", "0"]}
            """
        let data =
            """
            {"a": "1"}
            """
        XCTAssertEqual(try applyRule(rule, to: data), "1")
    }

    func testVar_withDefaultArgumentString_GivenArgumentDoesNotExistsInData() {
        let rule =
            """
             {"var": ["a", "0"]}
            """
        let data =
            """
            {"b": "1"}
            """
        XCTAssertEqual(try applyRule(rule, to: data), "0")
    }

    func testVar_withDefaultArgumentString_GivenNestedArgumentDoesNotExistsInData() {
        let rule =
            """
             {"var": ["a.b", "0"]}
            """
        let data =
            """
            {"a": "1"}
            """
        XCTAssertEqual(try applyRule(rule, to: data), "0")
    }

}
