//
//  Vendored from json-logic-swift (https://github.com/advantagefse/json-logic-swift)
//  Upstream path: Tests/jsonlogicTests/LogicAndBooleanOperations/EqualsTests.swift, tag 1.2.4, commit 9088eed1b26937fe13d248aa24d7632a51be28e2
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
//  EqualsTests.swift
//  jsonlogicTests
//
//  Created by Christos Koninis on 17/02/2019.
//

import Foundation
import XCTest

@testable import MixpanelSwiftCommon

class EqualsTests: XCTestCase {

    func testEquals() {
        var rule =
            """
            {"==":[1,1]}
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))

        rule =
            """
            {"==":[1,2]}
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))
    }

    func testEquals_WithTypeCoercion() {
        var rule =
            """
            {"==":[1,"1"]}
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))

        rule =
            """
            {"==":[1,"2"]}
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))

        rule =
            """
            {"==":[1,"1.0"]}
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))

        rule =
            """
            {"==":[null,1]}
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))

        rule =
            """
            {"==":[0,false]}
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))

        rule =
            """
            {"==":[[1],[1]]}
            """
        //http://jsonlogic.com/play.html returns false here
        XCTAssertEqual(true, try applyRule(rule, to: nil))
    }

    func testNotEquals() {
        var rule =
            """
            {"!=":[1,2]}
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))

        rule =
            """
            {"!=":[1,1]}
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))

        rule =
            """
            {"!=":[1,"1"]}
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))
    }

    func testNotEquals_WithTypeCoersion() {
        var rule =
            """
            {"!=":[1,"1"]}
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))

        rule =
            """
            {"!=":[1,"1.0"]}
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))

        rule =
            """
            {"!=":[0,true]}
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))
    }
}
