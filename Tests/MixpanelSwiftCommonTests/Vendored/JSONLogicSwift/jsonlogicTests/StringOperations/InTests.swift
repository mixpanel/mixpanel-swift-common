//
//  Vendored from json-logic-swift (https://github.com/advantagefse/json-logic-swift)
//  Upstream path: Tests/jsonlogicTests/StringOperations/InTests.swift, tag 1.2.4, commit 9088eed1b26937fe13d248aa24d7632a51be28e2
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

class InTests: XCTestCase {

    func testIn_StringArgument() {
        var rule =
            """
            { "in" : ["Spring", "Springfield"] }
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))

        rule =
            """
            {"in":["Spring","Springfield"]}
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))

        rule =
            """
            {"in":["i","team"]}
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))
    }

    func testIn_ArrayArgument() {
        var rule =
            """
            {"in":["Bart",["Bart","Homer","Lisa","Marge","Maggie"]]}
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))

        rule =
            """
            {"in":["Milhouse",["Bart","Homer","Lisa","Marge","Maggie"]]}
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))
    }

    func testIn_IntegerArgument() {
        var rule =
            """
            {"in":[5,[-1,0,1,2,3,4,5]]}
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))

        rule =
            """
            {"in":[5,[-0,0,1,2,3,4,6]]}
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))
    }

    func testIn_DoubleArgument() {
        var rule =
            """
            {"in":[5.1,[1.2,2.5,3.5,4.333,5.1]]}
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))

        rule =
            """
            {"in":[5.1,[1.2,2,2.5,3.5,4.333,5]]}
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))
    }

    func testIn_BoolArgument() {
        var rule =
            """
            {"in":[true,[false, true, false]]}
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))

        rule =
            """
            {"in":[true,[false, false, false]]}
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))
    }
}
