//
//  Vendored from json-logic-swift (https://github.com/advantagefse/json-logic-swift)
//  Upstream path: Tests/jsonlogicTests/AccessingDataOperations/MergeArrayTests.swift, tag 1.2.4, commit 9088eed1b26937fe13d248aa24d7632a51be28e2
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

class MergeTests: XCTestCase {

    let emptyIntArray = [Int]()

    func testMerge() {
        var rule =
            """
            {"merge":[]}
            """
        XCTAssertEqual(emptyIntArray, try applyRule(rule, to: nil))
        rule =
            """
            {"merge":[[1]]}
            """
        XCTAssertEqual([1], try applyRule(rule, to: nil))

        rule =
            """
            {"merge":[[1],[]]}
            """
        XCTAssertEqual([1], try applyRule(rule, to: nil))

        rule =
            """
            {"merge":[[1],[2]]}
            """
        XCTAssertEqual([1, 2], try applyRule(rule, to: nil))

        rule =
            """
            {"merge":[[1], [2], [3]]}
            """
        XCTAssertEqual([1, 2, 3], try applyRule(rule, to: nil))

        rule =
            """
            {"merge":[[1, 2], [3]]}
            """
        XCTAssertEqual([1, 2, 3], try applyRule(rule, to: nil))
    }

    func testMerge_withNonArrayArguments() {
        var rule =
            """
            {"merge":1}
            """
        XCTAssertEqual([1], try applyRule(rule, to: nil))

        rule =
            """
            {"merge":[1,2]}
            """
        XCTAssertEqual([1, 2], try applyRule(rule, to: nil))

        rule =
            """
            {"merge":[1,[2]]}
            """
        XCTAssertEqual([1, 2], try applyRule(rule, to: nil))
    }
}
