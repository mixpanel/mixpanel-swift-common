//
//  Vendored from json-logic-swift (https://github.com/advantagefse/json-logic-swift)
//  Upstream path: Tests/jsonlogicTests/StringOperations/CatTests.swift, tag 1.2.4, commit 9088eed1b26937fe13d248aa24d7632a51be28e2
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
class CatTests: XCTestCase {

    func testCat() {
        var rule =
            """
            {"cat":"ice"}
            """
        XCTAssertEqual("ice", try applyRule(rule, to: nil))

        rule =
            """
            {"cat":["ice"]}
            """
        XCTAssertEqual("ice", try applyRule(rule, to: nil))

        rule =
            """
            {"cat":["ice","cream"]}
            """
        XCTAssertEqual("icecream", try applyRule(rule, to: nil))

        rule =
            """
            {"cat":[1,2]}
            """
        XCTAssertEqual("12", try applyRule(rule, to: nil))

        rule =
            """
            {"cat":[1.1,2.1]}
            """
        XCTAssertEqual("1.12.1", try applyRule(rule, to: nil))

        rule =
            """
            {"cat":["Robocop",2]}
            """
        XCTAssertEqual("Robocop2", try applyRule(rule, to: nil))

        rule =
            """
            {"cat":["we all scream for ","ice","cream"]}
            """
        XCTAssertEqual("we all scream for icecream", try applyRule(rule, to: nil))
    }

    func testCat_WithNullOrEmpty() {
        var rule =
            """
            {"cat":[1,null]}
            """
        XCTAssertEqual("1", try applyRule(rule, to: nil))

        rule =
            """
            {"cat":[1,[]]}
            """
        XCTAssertEqual("1", try applyRule(rule, to: nil))

        rule =
            """
            {"cat":[1,""]}
            """
        XCTAssertEqual("1", try applyRule(rule, to: nil))
    }

    func testCat_WithBoolean() {
        var rule =
            """
            {"cat":["jsonlogic", true]}
            """
        XCTAssertEqual("jsonlogictrue", try applyRule(rule, to: nil))

        rule =
            """
            {"cat":[false, true]}
            """
        XCTAssertEqual("falsetrue", try applyRule(rule, to: nil))
    }

    func testCat_WithArrays() {
        var rule =
            """
            {"cat":[1,[2,3]]}
            """
        XCTAssertEqual("12,3", try applyRule(rule, to: nil))

        rule =
            """
            {"cat":[[1]]}
            """
        XCTAssertEqual("1", try applyRule(rule, to: nil))

        rule =
            """
            {"cat":[1,[false,true]]}
            """
        XCTAssertEqual("1false,true", try applyRule(rule, to: nil))
    }
}
