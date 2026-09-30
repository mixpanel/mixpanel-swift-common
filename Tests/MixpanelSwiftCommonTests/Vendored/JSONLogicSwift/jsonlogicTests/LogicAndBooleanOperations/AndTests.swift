//
//  Vendored from json-logic-swift (https://github.com/advantagefse/json-logic-swift)
//  Upstream path: Tests/jsonlogicTests/LogicAndBooleanOperations/AndTests.swift, tag 1.2.4, commit 9088eed1b26937fe13d248aa24d7632a51be28e2
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
//  AndTests.swift
//  jsonlogicTests
//
//  Created by Christos Koninis on 12/02/2019.
//

import XCTest

@testable import MixpanelSwiftCommon

class AndTests: XCTestCase {

    func testAnd_twoBooleans() {
        XCTAssertEqual(
            true,
            try applyRule(
                """
                {"and": [true, true]}
                """, to: nil))

        XCTAssertEqual(
            false,
            try applyRule(
                """
                { "and" : [true, false] }
                """, to: nil))

        XCTAssertEqual(
            true,
            try applyRule(
                """
                { "and" : [true] }
                """, to: nil))
        XCTAssertEqual(
            false,
            try applyRule(
                """
                 { "and" : [false] }
                """, to: nil))
    }

    func testAnd_mixedArguments() {
        XCTAssertEqual(
            3,
            try applyRule(
                """
                { "and": [1, 3] }
                """, to: nil))

        XCTAssertEqual(
            "a",
            try applyRule(
                """
                { "and": ["a"] }
                """, to: nil))

        XCTAssertEqual(
            "",
            try applyRule(
                """
                { "and": [true,"",3] }
                """, to: nil))
    }
}
