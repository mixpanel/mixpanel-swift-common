//
//  Vendored from json-logic-swift (https://github.com/advantagefse/json-logic-swift)
//  Upstream path: Tests/jsonlogicTests/CustomOperatorTests.swift, tag 1.2.4, commit 9088eed1b26937fe13d248aa24d7632a51be28e2
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
//  CustomOperatorTests.swift
//  jsonlogicTests
//
//  Created by Christos Koninis on 3/15/21.
//

import XCTest

@testable import MixpanelSwiftCommon

private class CustomOperatorWrapper {
    var isCustomOperatorCalled = false
    var evalutedJSONInput: JSON?

    lazy var customOperator: ((JSON?) -> JSON) = { [weak self] json in
        guard let strongSelf = self else { return JSON.Null }
        strongSelf.isCustomOperatorCalled = true
        strongSelf.evalutedJSONInput = json

        guard let array = json?.array else { return JSON.Null }

        return array.reduce(into: JSON(0)) { (result, arrayItem) in
            //swiftlint:disable:next shorthand_operator
            result = result + arrayItem.toNumber()
        }
    }
}

class CustomOperatorTests: XCTestCase {

    func testCustomOperatorIsCalled_GivenItIsRegisted() throws {
        let rule =
            """
            { "plus" : [1, 2] }
            """

        let customOperatorWrapper = CustomOperatorWrapper()
        let customOperators = ["plus": customOperatorWrapper.customOperator]

        XCTAssertEqual(3, try JsonLogic(rule, customOperators: customOperators).applyRule())
        XCTAssertTrue(customOperatorWrapper.isCustomOperatorCalled)
    }

    func testCustomOperatorIsNotCalled_GivenItIsNotRegisted() throws {
        let rule =
            """
            { "plus" : [1, 2] }
            """

        let customOperatorWrapper = CustomOperatorWrapper()

        let block = {
            try JsonLogic(rule, customOperators: [:]).applyRule() as Int
        }

        try _XCTAssertThrowsError(try block(), "") {
            let parseError: ParseError = try XCTUnwrap($0 as? ParseError)
            XCTAssertEqual(parseError, .UnimplementedExpressionFor("plus"))
        }
        XCTAssertFalse(customOperatorWrapper.isCustomOperatorCalled)
    }

    func testCustomOperatorIsNotCalled_GivenItIsRegistedWithSameNameAsInternalOperators() {
        let rule =
            """
            { "*" : [1, 2] }
            """

        let customOperatorWrapper = CustomOperatorWrapper()
        let customOperators = ["*": customOperatorWrapper.customOperator]

        XCTAssertEqual(2, try JsonLogic(rule, customOperators: customOperators).applyRule())
        XCTAssertFalse(
            customOperatorWrapper.isCustomOperatorCalled,
            "the custom operator should not override the internal")
    }

    func testCustomOperatorIsGivenExpetedJSONToEvaluate() throws {
        let rule =
            """
            { "plus" : [1, {"var" : "aVariable"}] }
            """

        let data =
            """
            { "aVariable" : 3 }
            """

        let expectedJSONInput = JSON(string: "[1, 3]")

        let customOperatorWrapper = CustomOperatorWrapper()
        let customOperators = ["plus": customOperatorWrapper.customOperator]

        let result: Int = try JsonLogic(rule, customOperators: customOperators).applyRule(to: data)
        XCTAssertEqual(4, result)
        XCTAssertEqual(expectedJSONInput, customOperatorWrapper.evalutedJSONInput)
    }
}
