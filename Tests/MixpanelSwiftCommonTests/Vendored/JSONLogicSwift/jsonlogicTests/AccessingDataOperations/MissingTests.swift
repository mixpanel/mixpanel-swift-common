//
//  Vendored from json-logic-swift (https://github.com/advantagefse/json-logic-swift)
//  Upstream path: Tests/jsonlogicTests/AccessingDataOperations/MissingTests.swift, tag 1.2.4, commit 9088eed1b26937fe13d248aa24d7632a51be28e2
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
class MissingTests: XCTestCase {

    let emptyStringArray = [String]()

    func testVar_withEmptyVarName() {
        let rule =
            """
            {"var":[""]}
            """
        let data =
            """
            [1, 2, 3]
            """
        XCTAssertEqual([1, 2, 3], try applyRule(rule, to: data))
    }

    func testMissing() {
        var rule =
            """
            {"missing":["a", "b"]}
            """
        var data =
            """
            {"a":"apple", "c":"carrot"}
            """
        XCTAssertEqual(["b"], try applyRule(rule, to: data))

        rule =
            """
            {"missing":["a", "b"]}
            """
        data =
            """
            {"a":"apple", "b":"banana"}
            """
        XCTAssertEqual(emptyStringArray, try applyRule(rule, to: data))

        rule =
            """
            {"missing":[]}
            """
        XCTAssertEqual(emptyStringArray, try applyRule(rule, to: nil))

        rule =
            """
            {"missing":["a"]}
            """
        XCTAssertEqual(["a"], try applyRule(rule, to: nil))

        rule =
            """
            {"missing":"a"}
            """
        XCTAssertEqual(["a"], try applyRule(rule, to: nil))

        rule =
            """
            {"missing":"a"}
            """
        data =
            """
            {"a":"apple"}
            """
        XCTAssertEqual(emptyStringArray, try applyRule(rule, to: data))

        rule =
            """
            {"missing":["a"]}
            """
        data =
            """
            {"a":"apple"}
            """
        XCTAssertEqual(emptyStringArray, try applyRule(rule, to: data))

        rule =
            """
            {"missing":["a","b"]}
            """
        data =
            """
            {"a":"apple"}
            """
        XCTAssertEqual(["b"], try applyRule(rule, to: data))

        rule =
            """
            {"missing":["a","b"]}
            """
        data =
            """
            {"b":"banana"}
            """
        XCTAssertEqual(["a"], try applyRule(rule, to: data))

        rule =
            """
            {"missing":["a","b"]}
            """
        data =
            """
            {"a":"apple", "b":"banana"}
            """
        XCTAssertEqual(emptyStringArray, try applyRule(rule, to: data))

        rule =
            """
            {"missing":["a","b"]}
            """
        data =
            """
            {}
            """
        XCTAssertEqual(["a", "b"], try applyRule(rule, to: data))

        rule =
            """
            {"missing":["a","b"]}
            """
        XCTAssertEqual(["a", "b"], try applyRule(rule, to: nil))
    }

    func testMissing_NestedKeys() {
        var rule =
            """
            {"missing":["a.b"]}
            """
        var data =
            """
            {"a":"apple"}
            """
        XCTAssertEqual(["a.b"], try applyRule(rule, to: data))

        rule =
            """
            {"missing":["a.b"]}
            """
        XCTAssertEqual(["a.b"], try applyRule(rule, to: nil))

        rule =
            """
            {"missing":["a.b"]}
            """
        data =
            """
            {"a":{"c":"apple cake"}}
            """
        XCTAssertEqual(["a.b"], try applyRule(rule, to: data))

        rule =
            """
            {"missing":["a.b"]}
            """
        data =
            """
            {"a":{"b":"apple brownie"}}
            """
        XCTAssertEqual(emptyStringArray, try applyRule(rule, to: data))

        rule =
            """
            {"missing":["a.b", "a.c"]}
            """
        data =
            """
            {"a":{"b":"apple brownie"}}
            """
        XCTAssertEqual(["a.c"], try applyRule(rule, to: data))
    }

    func testMissing_some() {
        var rule =
            """
            {"missing_some":[1, ["a", "b"]]}
            """
        var data =
            """
            {"a":"apple"}
            """
        XCTAssertEqual(emptyStringArray, try applyRule(rule, to: data))

        rule =
            """
            {"missing_some":[1, ["a", "b"]]}
            """
        data =
            """
            {"b":"banana"}
            """
        XCTAssertEqual(emptyStringArray, try applyRule(rule, to: data))

        rule =
            """
            {"missing_some":[1, ["a", "b"]]}
            """
        data =
            """
            {"b":"banana"}
            """
        XCTAssertEqual(emptyStringArray, try applyRule(rule, to: data))

        rule =
            """
            {"missing_some":[2, ["a", "b", "c"]]}
            """
        data =
            """
            {"a":"apple"}
            """
        XCTAssertEqual(["b", "c"], try applyRule(rule, to: data))

        //Following the rules for var for . notation
        rule =
            """
            {"missing_some":[2, ["person.name", "b", "c"]]}
            """
        data =
            """
            {"a":"apple", "person": {"name": "Bruce"} }
            """
        XCTAssertEqual(["b", "c"], try applyRule(rule, to: data))

        rule =
            """
            {"missing_some":[1, ["person.name", "b", "c"]]}
            """
        data =
            """
            {"a":"apple", "person": {"name": "Bruce"} }
            """
        XCTAssertEqual(emptyStringArray, try applyRule(rule, to: data))

        //with wrong arguments
        rule =
            """
            {"missing_some":[1]}
            """
        data =
            """
            {"b":"banana"}
            """
        XCTAssertNil(try applyRule(rule, to: data))

        rule =
            """
            {"if" :[
                {"merge": [
                {"missing":["first_name", "last_name"]},
                {"missing_some":[1, ["cell_phone", "home_phone"] ]}
            ]},
            "We require first name, last name, and one phone number.",
            "OK to proceed"
            ]}
            """

        data =
            """
            {"first_name":"Bruce", "last_name":"Wayne"}
            """
        XCTAssertEqual("We require first name, last name, and one phone number.", try applyRule(rule, to: data))
    }
}
