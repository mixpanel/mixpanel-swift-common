//
//  Vendored from json-logic-swift (https://github.com/advantagefse/json-logic-swift)
//  Upstream path: Tests/jsonlogicTests/AccessingDataOperations/ArrayMapTests.swift, tag 1.2.4, commit 9088eed1b26937fe13d248aa24d7632a51be28e2
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

//swiftlint:disable function_body_length
class ArrayMapTests: XCTestCase {

    let emptyIntArray = [Int]()

    func testMap() {
        var rule =
            """
            {"map":[{"var":"integers"}, {"*":[{"var":""},2]}]}
            """
        var data =
            """
            {"integers":[1,2,3]}
            """
        XCTAssertEqual([2, 4, 6], try applyRule(rule, to: data))

        rule =
            """
            {"map":[{"var":"integers"}, {"*":[{"var":""},2]}]}
            """
        XCTAssertEqual(emptyIntArray, try applyRule(rule, to: nil))

        rule =
            """
            {"map":[{"var":"desserts"}, {"var":"qty"}]}
            """
        data =
            """
            {"desserts":[
            {"name":"apple","qty":1},
            {"name":"brownie","qty":2},
            {"name":"cupcake","qty":3}
            ]}
            """
        XCTAssertEqual([1, 2, 3], try applyRule(rule, to: data))

        rule =
            """
            {"map":[{"var":"desserts"}]}
            """
        XCTAssertEqual(emptyIntArray, try applyRule(rule))
    }

    func testReduce() {
        var rule =
            """
            {"reduce":[
            {"var":"integers"},
            {"+":[{"var":"current"}, {"var":"accumulator"}]},
            0
            ]}
            """
        var data =
            """
            {"integers":[1,2,3,4]}
            """
        XCTAssertEqual(10, try applyRule(rule, to: data))

        rule =
            """
            {"reduce":[
            {"var":"integers"},
            {"+":[{"var":"current"}, {"var":"accumulator"}]},
            0
            ]}
            """
        XCTAssertEqual(0, try applyRule(rule, to: nil))

        rule =
            """
            {"reduce":[
            {"var":"integers"},
            {"*":[{"var":"current"}, {"var":"accumulator"}]},
            1
            ]}
            """
        data =
            """
            {"integers":[1,2,3,4]}
            """
        XCTAssertEqual(24, try applyRule(rule, to: data))

        rule =
            """
            {"reduce":[
            {"var":"integers"},
            {"*":[{"var":"current"}, {"var":"accumulator"}]},
            0
            ]}
            """
        data =
            """
            {"integers":[1,2,3,4]}
            """
        XCTAssertEqual(0, try applyRule(rule, to: data))

        rule =
            """
            {"reduce": [
            {"var":"desserts"},
            {"+":[ {"var":"accumulator"}, {"var":"current.qty"}]},
            0
            ]}
            """
        data =
            """
            {"desserts":[
            {"name":"apple","qty":1},
            {"name":"brownie","qty":2},
            {"name":"cupcake","qty":3}
            ]}
            """
        XCTAssertEqual(6, try applyRule(rule, to: data))
    }

    func testFilter() {
        var rule =
            """
            {"filter":[{"var":"integers"}, true]}
            """
        var data =
            """
            {"integers":[1,2,3]}
            """
        XCTAssertEqual([1, 2, 3], try applyRule(rule, to: data))

        rule =
            """
            {"filter":[{"var":"integers"}, false]}
            """
        data =
            """
            {"integers":[1,2,3]}
            """
        XCTAssertEqual(emptyIntArray, try applyRule(rule, to: data))

        rule =
            """
            {"filter":[{"var":"integers"}, {">=":[{"var":""},2]}]}
            """
        data =
            """
            {"integers":[1,2,3]}
            """
        XCTAssertEqual([2, 3], try applyRule(rule, to: data))

        rule =
            """
            {"filter":[{"var":"integers"}, {"%":[{"var":""},2]}]}
            """
        data =
            """
            {"integers":[1,2,3]}
            """
        XCTAssertEqual([1, 3], try applyRule(rule, to: data))

        rule =
            """
            {"filter":[{"var":"integers"}]}
            """
        XCTAssertEqual(emptyIntArray, try applyRule(rule, to: data))
    }

    func testFilter_withMissingArguments() {
        let rule =
            """
             {"filter":[]}
            """
        XCTAssertEqual(emptyIntArray, try applyRule(rule))
    }

    func testReduce_withMissingArguments() {
        let rule =
            """
             {"reduce":[]}
            """
        XCTAssertNil(try applyRule(rule))
    }

    func testMap_withMissingArguments() {
        let rule =
            """
             {"map":[]}
            """
        XCTAssertEqual(emptyIntArray, try applyRule(rule))
    }

    func testAccessingVariableWithArrayIndexPath() {
        let rule =
            """
            { "var" : "person.name.0" }
            """
        let data =
            """
            { "person" : { "name" : ["John", "Green"] } }
            """
        XCTAssertEqual("John", try applyRule(rule, to: data))
    }
}
