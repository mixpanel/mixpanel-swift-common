//
//  Vendored from json-logic-swift (https://github.com/advantagefse/json-logic-swift)
//  Upstream path: Tests/jsonlogicTests/StringOperations/SubstringTests.swift, tag 1.2.4, commit 9088eed1b26937fe13d248aa24d7632a51be28e2
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

class SubstringTests: XCTestCase {

    func testSubstring() {
        var rule =
            """
            {"substr":["jsonlogic", 4]}
            """
        XCTAssertEqual("logic", try applyRule(rule, to: nil))

        rule =
            """
            {"substr":["jsonlogic", -5]}
            """
        XCTAssertEqual("logic", try applyRule(rule, to: nil))
    }

    func testSubstring_withRange() {
        var rule =
            """
            {"substr":["jsonlogic", 0, 1]}
            """
        XCTAssertEqual("j", try applyRule(rule, to: nil))

        rule =
            """
            {"substr":["jsonlogic", -1, 1]}
            """
        XCTAssertEqual("c", try applyRule(rule, to: nil))

        rule =
            """
            {"substr":["jsonlogic", 4, 5]}
            """
        XCTAssertEqual("logic", try applyRule(rule, to: nil))

        rule =
            """
            {"substr":["jsonlogic", -5, 5]}
            """
        XCTAssertEqual("logic", try applyRule(rule, to: nil))

        rule =
            """
            {"substr":["jsonlogic", -5, -2]}
            """
        XCTAssertEqual("log", try applyRule(rule, to: nil))

        rule =
            """
            {"substr":["jsonlogic", 1, -5]}
            """
        XCTAssertEqual("son", try applyRule(rule, to: nil))
    }

    func testSunString_withInvalidLength() {
        let rule =
            """
            {"substr":["jsonlogic", 1, null]}
            """
        XCTAssertNil(try applyRule(rule, to: nil))
    }

    func testSunString_withInvalidStart() {
        var rule =
            """
            {"substr":["jsonlogic", null, 1]}
            """
        XCTAssertNil(try applyRule(rule, to: nil))

        rule =
            """
            {"substr":["jsonlogic", null]}
            """
        XCTAssertNil(try applyRule(rule, to: nil))
    }
}
