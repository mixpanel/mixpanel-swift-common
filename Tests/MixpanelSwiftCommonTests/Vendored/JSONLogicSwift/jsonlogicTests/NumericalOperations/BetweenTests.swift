//
//  Vendored from json-logic-swift (https://github.com/advantagefse/json-logic-swift)
//  Upstream path: Tests/jsonlogicTests/NumericalOperations/BetweenTests.swift, tag 1.2.4, commit 9088eed1b26937fe13d248aa24d7632a51be28e2
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
//  BetweenTests.swift
//  jsonlogicTests
//
//  Created by Christos Koninis on 11/02/2019.
//

import XCTest

@testable import MixpanelSwiftCommon

class BetweenTests: XCTestCase {

    func testBetween_withNumberConstants() {
        var rule =
            """
            { "<" : [1, 2, 3] }
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))

        rule =
            """
            { "<" : [1, 1, 3] }
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))

        rule =
            """
            { "<" : [1, 3, 3] }
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))

        rule =
            """
            { "<=" : [1, 3, 3] }
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))

        rule =
            """
            { "<=" : [2, 2, 3] }
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))

        rule =
            """
             { "<=" : [1, 4, 3] }
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))
    }

    //    func testBetween_withNonNumbericConstants() {
    //        let rulesAndResults = [
    //            //When both are strings the comparison in done lexicographaclly e.g. "111111" < "2"
    //            """
    //            { "<" : ["1", "2222", "3"] }
    //            """ : true,
    //            """
    //            { "<=" : ["2", "2", "3"] }
    //            """ : true,
    //            """
    //            { "<" : ["2", "2", "3"] }
    //            """ : false,
    //            """
    //            { "<=" : [null, [], "2"] }
    //            """ : true,
    //            """
    //            { "<" : [null, [], "2"] }
    //            """ : false
    //        ]
    //
    //        for (rule, result) in rulesAndResults {
    //            XCTAssertEqual(result, try applyRule(rule, to: nil))
    //        }
    //    }

    //    func testBetween_withMixedNumbericAndNonConstants() {
    //        let rulesAndResults = [
    //            //When one is numeric then the other is converted to numberic
    //            """
    //            { "<=" : ["111", "2", 1111] }
    //            """ : true,
    //            """
    //            { "<=" : ["1", "2222", 11111] }
    //            """ : false,
    //            """
    //            { "<=" : [1, "b", 1111] }
    //            """ : false,
    //            //Anything but null when compared with null is greater
    //            """
    //            { "<" : [0, 1, null] }
    //            """ : false,
    //            """
    //            { "<=" : [[], 0, "2"] }
    //            """ : true,
    //            """
    //            { "<=" : [10, 10, "11"] }
    //            """ : true,
    //            """
    //            { "<=" : [null, [], null] }
    //            """ : false,
    //            """
    //            { "<=" : [null, [], 2] }
    //            """ : true,
    //            """
    //            { "<=" : ["11", "2", 3] }
    //            """ : true,
    //            """
    //            { "<=" : ["", 1, [[]]] }
    //            """ : false
    //        ]
    //
    //        for (rule, result) in rulesAndResults {
    //            XCTAssertEqual(result, try applyRule(rule, to: nil))
    //        }
    //    }

    func testBetween_withVariables() {
        var rule =
            """
            { "<=" : [3, {"var" : ["b"]}, 9] }
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))

        rule =
            """
            { "<=" : [0, {"var" : ["b"] }, 2] }
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))

        rule =
            """
            { "<=" : [1, {"var" : ["a"] }, 9] }
            """
        XCTAssertEqual(false, try applyRule(rule, to: nil))

        rule =
            """
            { "<=" : [1, 3, 3] }
            """
        XCTAssertEqual(true, try applyRule(rule, to: nil))
    }
}
