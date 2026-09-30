//
//  Vendored from json-logic-swift (https://github.com/advantagefse/json-logic-swift)
//  Upstream path: Tests/jsonlogicTests/JsonLogicTests.swift, tag 1.2.4, commit 9088eed1b26937fe13d248aa24d7632a51be28e2
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

import XCTest

@testable import MixpanelSwiftCommon

final class JsonLogicTests: XCTestCase {

    func testEqualsWithTwoSameConstants() {
        let rule =
            """
                { "===" : [1, 1] }
            """

        XCTAssertTrue(try applyRule(rule, to: nil))
    }

    func testEqualsWithDifferentSameConstants() {
        let rule =
            """
                { "===" : [1, 2] }
            """

        XCTAssertFalse(try applyRule(rule, to: nil))
    }

    func testSetOneStringVariableFromData() {
        let rule =
            """
                { "var" : "a" }
            """
        let data =
            """
                { "a" : "1" }
            """

        XCTAssertEqual("1", try applyRule(rule, to: data))
    }

    func testSetOneIntegerVariableFromData() {
        let rule =
            """
                { "var" : "a" }
            """
        let data =
            """
                { "a" : 1 }
            """

        XCTAssertEqual(1, try applyRule(rule, to: data))
    }

    func testSetOneBoolVariableFromData() {
        let rule =
            """
                { "var" : "a" }
            """
        let data =
            """
                { "a" : true }
            """

        XCTAssertTrue(try applyRule(rule, to: data))
    }

    func testSetTwoStringVariablesFromData() {
        let rule =
            """
                { "var" : "a" }
            """
        let data =
            """
                { "a" : true }
            """

        XCTAssertTrue(try applyRule(rule, to: data))
    }

    func testSetOneStringNestedVariableFromData() {
        let rule =
            """
                { "var" : "person.name" }
            """
        let data =
            """
                { "person" : { "name" : "Jon" } }
            """

        XCTAssertEqual("Jon", try applyRule(rule, to: data))
    }

    func testSetOneStringArrayVariableFromData() {
        let rule =
            """
                { "var" : ["a"] }
            """
        let data =
            """
                { "a" : "1" }
            """

        XCTAssertEqual("1", try applyRule(rule, to: data))
    }

    func testAddTwoIntsFromVariables() {
        let rule =
            """
                { "===" : [{ "var" : ["a"] }, "1"] }
            """
        let data =
            """
                { "a" : "1" }
            """

        XCTAssertTrue(try applyRule(rule, to: data))
    }

    func testNestedVar() {
        let rule =
            """
                { "var" : [{ "var" : ["a"] }] }
            """
        let data =
            """
                { "a" : "b", "b" : "1" }
            """

        XCTAssertEqual("1", try applyRule(rule, to: data))
    }

    func testNestedVarWithStrictEquals() {
        let rule =
            """
                { "===" : [ {"var" : [ {"var" : ["a"]} ] }, {"var" : ["oneNest.one"]}] }
            """
        let data =
            """
                { "a" : "b", "b" : "1", "oneNest" : {"one" : "1"} }
            """

        XCTAssertTrue(try applyRule(rule, to: data))
    }

    func testNestedStrictEqualsWithVar() {
        let rule =
            """
                { "var" : [ {"var" : [ {"var" : ["a"] } ] } ] }
            """
        let data =
            """
                { "a" : "b", "b" : "oneNest.one", "oneNest" : {"one" : "10"} }
            """

        XCTAssertEqual("10", try applyRule(rule, to: data))
    }

    func testNotSupportedResultType() {
        let rule =
            """
                { "===" : [1, 1] }
            """

        class SomeType {}

        XCTAssertThrowsError(try { try applyRule(rule) as SomeType }(), "") {
            //swiftlint:disable:next force_cast
            XCTAssertEqual($0 as! JSONLogicError, .canNotConvertResultToType(SomeType.self))
        }
    }

    /// Test for the bug advantagefse/json-logic-swift/issues/24
    func testComplexRule() {
        let rule =
            """
            {
                "!": [{
                    "and": [{
                            "in": ["Population", {
                                "var": "CHOIX"
                            }]
                        },
                        {
                            "in": [{
                                    "var": "TAILLE_POP"
                                },
                                ["", null]
                            ]
                        }
                    ]
                }]
            }
            """
        let data =
            """
                { "COMPARTIEMENT" : "Faune/Wildlife", "ACTIF" : "false" }
            """

        XCTAssertTrue(try applyRule(rule, to: data))
    }
}
