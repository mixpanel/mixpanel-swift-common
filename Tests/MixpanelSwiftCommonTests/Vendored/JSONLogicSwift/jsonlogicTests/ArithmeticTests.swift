//
//  Vendored from json-logic-swift (https://github.com/advantagefse/json-logic-swift)
//  Upstream path: Tests/jsonlogicTests/ArithmeticTests.swift, tag 1.2.4, commit 9088eed1b26937fe13d248aa24d7632a51be28e2
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
//  Arithmetic.swift
//  jsonlogicTests
//
//  Created by Christos Koninis on 11/02/2019.
//

import XCTest

@testable import MixpanelSwiftCommon

class Arithmetic: XCTestCase {

    func testAddition() {
        var rule =
            """
            { "+" : [4, 2] }
            """
        XCTAssertEqual(6, try applyRule(rule, to: nil))

        rule =
            """
            { "+" : [4, "2"] }
            """
        XCTAssertEqual(6, try applyRule(rule, to: nil))

        rule =
            """
            { "+" : [2, 2, 2, 2, 2]}
            """
        XCTAssertEqual(10, try applyRule(rule, to: nil))

        rule =
            """
            { "+" : "3.14"}
            """
        XCTAssertEqual(3.14, try applyRule(rule, to: nil))
    }

    func testSubtraction() {
        var rule =
            """
            { "-" : [4, 2] }
            """
        XCTAssertEqual(2, try applyRule(rule, to: nil))

        rule =
            """
            { "-" : [2, 3] }
            """
        XCTAssertEqual(-1, try applyRule(rule, to: nil))

        rule =
            """
            { "-" : [3] }
            """
        XCTAssertEqual(-3, try applyRule(rule, to: nil))

        rule =
            """
             { "-" : [1, "1"] }
            """
        XCTAssertEqual(0, try applyRule(rule, to: nil))
    }

    func testMultiplication() {
        var rule =
            """
            { "*" : [4, 2] }
            """
        XCTAssertEqual(8, try applyRule(rule, to: nil))

        rule =
            """
            { "*" : [2, 2, 2, 2, 2]}
            """
        XCTAssertEqual(32, try applyRule(rule, to: nil))

        rule =
            """
            { "*" : [3, 2] }
            """
        XCTAssertEqual(6, try applyRule(rule, to: nil))

        rule =
            """
            { "*" : [1]}
            """
        XCTAssertEqual(1, try applyRule(rule, to: nil))

        rule =
            """
            { "*" : ["1", 1]}
            """
        XCTAssertEqual(1, try applyRule(rule, to: nil))
    }

    func testMultiplication_TypeCoercion() {
        var rule =
            """
            {"*":["2","2"]}
            """
        XCTAssertEqual(4, try applyRule(rule, to: nil))

        rule =
            """
            {"*":["2"]}
            """
        XCTAssertEqual(2, try applyRule(rule, to: nil))
    }

    func testDivision() {
        var rule =
            """
            { "/" : [4, 2]}
            """
        XCTAssertEqual(2, try applyRule(rule, to: nil))

        rule =
            """
            { "/" : [2, 4]}
            """
        XCTAssertEqual(0.5, try applyRule(rule, to: nil))

        rule =
            """
            { "+" : [2, 2, 2, 2, 2]}
            """
        XCTAssertEqual(10, try applyRule(rule, to: nil))

        rule =
            """
            { "/" : ["1", 1]}
            """
        XCTAssertEqual(1, try applyRule(rule, to: nil))
    }

    func testModulo() {
        var rule =
            """
            { "%" : [1, 2]}
            """
        XCTAssertEqual(1, try applyRule(rule, to: nil))

        rule =
            """
            { "%" : [2, 2]}
            """
        XCTAssertEqual(0, try applyRule(rule, to: nil))

        rule =
            """
            { "%" : [3, 2]}
            """
        XCTAssertEqual(1, try applyRule(rule, to: nil))
    }

    func testUnaryMinus() {
        var rule =
            """
            { "-" : [2] }
            """
        XCTAssertEqual(-2, try applyRule(rule, to: nil))

        rule =
            """
            { "-" : [-2] }
            """
        XCTAssertEqual(2, try applyRule(rule, to: nil))
    }
}
