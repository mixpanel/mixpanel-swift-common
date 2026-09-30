//
//  Vendored from json-logic-swift (https://github.com/advantagefse/json-logic-swift)
//  Upstream path: Tests/jsonlogicTests/LogicAndBooleanOperations/NotStrictEqualsTests.swift, tag 1.2.4, commit 9088eed1b26937fe13d248aa24d7632a51be28e2
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
//  NotStringEquals.swift
//  jsonlogicTests
//
//  Created by Christos Koninis on 11/02/2019.
//

import XCTest

@testable import MixpanelSwiftCommon

class NotStrictEquals: XCTestCase {

    func testNot_StrictEquals_withConstants() {
        let rule =
            """
                { "!==" : [1, 2] }
            """

        XCTAssertEqual(true, try applyRule(rule, to: nil))
    }

    func testNot_StrictEquals_withConstants1() {
        let rule =
            """
                { "!==" : [1, "1"] }
            """

        XCTAssertEqual(true, try applyRule(rule, to: nil))
    }

    func testNot_StrictEquals_withConstants2() {
        let rule =
            """
                { "!==" : [1, 1] }
            """

        XCTAssertEqual(false, try applyRule(rule, to: nil))
    }

    func testNot_StrictEquals_withConstants3() {
        let rule =
            """
                { "!==" : [1, []] }
            """

        XCTAssertEqual(true, try applyRule(rule, to: nil))
    }

    func testNotStringEquals_NestedVar() {
        let rule =
            """
                { "!==" : [ {"var" : [ {"var" : ["a"]} ] }, {"var" : ["oneNest.one"]}] }
            """
        let data =
            """
                { "a" : "b", "b" : "1", "oneNest" : {"one" : "1"} }
            """

        XCTAssertEqual(false, try applyRule(rule, to: data))
    }

    func testLogicalNot_withBooleanConstants() {
        var rule =
            """
                { "!" : [true] }
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))

        rule =
            """
                { "!" : [false] }
            """
        XCTAssertTrue(try applyRule(rule, to: nil))

        rule =
            """
                {"!" : true}
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))

        rule =
            """
                {"!" : false}
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))
    }

    func testLogicalNot_withArrays() {
        var rule =
            """
                {"!" : []}
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))

        rule =
            """
                {"!" : [[]]}
            """
        XCTAssertTrue(try applyRule(rule, to: nil))

        rule =
            """
                {"!" : [[]]}
            """
        XCTAssertTrue(try applyRule(rule, to: nil))

        rule =
            """
                {"!" : [true, 2, 3]}
            """
        XCTAssertFalse(try applyRule(rule, to: nil))

        rule =
            """
                {"!" : [false, 2, 3]}
            """
        XCTAssertTrue(try applyRule(rule, to: nil))
    }

    func testLogicalNot_withNumbers() {
        var rule =
            """
                { "!" : 0 }
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))

        rule =
            """
                { "!" : 1 }
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))
    }

    func testLogicalNot_withStrings() {
        var rule =
            """
                {"!" : ""}
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))

        rule =
            """
                {"!" : ""}
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))

        rule =
            """
                {"!" : "1"}
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))
    }

    func testLogicalNot_withNull() {
        let rule =
            """
                {"!" : null}
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))
    }

    func testLogicalNot_withVariables() {
        let data =
            """
                { "a" : "b", "b" : "1", "oneNest" : {"one" : true} }
            """

        var rule =
            """
                { "!" : [ {"var" : ["oneNest.one"] } ] }
            """
        XCTAssertEqual(false, try applyRule(rule, to: data))

        rule =
            """
                { "!" : {"var" : ["a"] } }
            """
        XCTAssertEqual(false, try applyRule(rule, to: data))

        rule =
            """
                { "!" : {"var" : ["nonExistant"] } }
            """
        XCTAssertEqual(true, try applyRule(rule, to: data))
    }
}
