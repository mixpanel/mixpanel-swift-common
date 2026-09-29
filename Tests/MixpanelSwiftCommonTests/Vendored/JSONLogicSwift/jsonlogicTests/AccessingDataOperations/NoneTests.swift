//
//  Vendored from json-logic-swift (https://github.com/advantagefse/json-logic-swift)
//  Upstream path: Tests/jsonlogicTests/AccessingDataOperations/NoneTests.swift, tag 1.2.4, commit 9088eed1b26937fe13d248aa24d7632a51be28e2
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

class NoneTests: XCTestCase {

    func testNone() {
        var rule =
            """
            {"none":[{"var":"integers"}, {">=":[{"var":""}, 1]}]}
            """
        let data =
            """
            {"integers":[1,2,3]}
            """
        XCTAssertEqual(false, try applyRule(rule, to: data))

        rule =
            """
            {"none":[{"var":"integers"}, {"==":[{"var":""}, 1]}]}
            """
        XCTAssertEqual(false, try applyRule(rule, to: data))

        rule =
            """
            {"none":[{"var":"integers"}, {"<":[{"var":""}, 1]}]}
            """
        XCTAssertEqual(true, try applyRule(rule, to: data))

        rule =
            """
            {"none":[{"var":"integers"}, {"<=":[{"var":""}, 1]}]}
            """
        XCTAssertEqual(false, try applyRule(rule, to: data))
    }

    func testNone_WithEmptyDataArray() {
        var rule =
            """
            {"none":[{"var":"integers"}, {"<":[{"var":""}, 1]}]}
            """
        var data =
            """
            {"integers":[]}
            """
        XCTAssertEqual(true, try applyRule(rule, to: data))

        rule =
            """
            {"none":[ {"var":"items"}, {">=":[{"var":"qty"}, 1]}]}
            """
        data =
            """
            {"items":[]}
            """
        XCTAssertEqual(true, try applyRule(rule, to: data))

        rule =
            """
            {"none":[ {"var":"items"}, {">=":[{"var":"qty"}, 1]}]}
            """
        data =
            """
            {"items":[]}
            """
        XCTAssertEqual(true, try applyRule(rule, to: data))
    }

    func testNone_WithNestedDataItems() {
        var rule =
            """
            {"none":[ {"var":"items"}, {">=":[{"var":"qty"}, 1]}]}
            """
        var data =
            """
            {"items":[{"qty":1,"sku":"apple"},{"qty":2,"sku":"banana"}]}
            """
        XCTAssertEqual(false, try applyRule(rule, to: data))

        rule =
            """
            {"none":[ {"var":"items"}, {">":[{"var":"qty"}, 1]}]}
            """
        data =
            """
            {"items":[{"qty":1,"sku":"apple"},{"qty":2,"sku":"banana"}]}
            """
        XCTAssertEqual(false, try applyRule(rule, to: data))

        rule =
            """
            {"none":[ {"var":"items"}, {"<":[{"var":"qty"}, 1]}]}
            """
        data =
            """
            {"items":[{"qty":1,"sku":"apple"},{"qty":2,"sku":"banana"}]}
            """
        XCTAssertEqual(true, try applyRule(rule, to: data))
    }

    func testNone_WithMissingArguments() {
        var rule =
            """
            {"none":[{"var":"integers"}]}
            """
        XCTAssertNil(try applyRule(rule))

        rule =
            """
            {"none":[]}
            """
        XCTAssertNil(try applyRule(rule))
    }
}
