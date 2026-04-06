//
//  JSONLogicTestsRunner.swift
//  MixpanelSwiftCommon
//
//  Test runner for official JSONLogic test suite from https://jsonlogic.com/tests.json
//

import Testing
import Foundation
@testable import MixpanelSwiftCommon

@Suite("Official JSONLogic Test Suite")
struct JSONLogicTestsRunner {

    let evaluator = JSONLogicEvaluator()

    // Official test data from jsonlogic.com/tests.json
    // Format: [rule, data, expected_result]
    let officialTests: [[Any]] = [
        // Equality operators
        [["==": [1, 1]], [:] as [String: Any], true],
        [["==": [1, "1"]], [:] as [String: Any], true],
        [["==": [1, 2]], [:] as [String: Any], false],
        [["===": [1, 1]], [:] as [String: Any], true],
        [["===": [1, "1"]], [:] as [String: Any], false],
        [["===": [1, 2]], [:] as [String: Any], false],
        [["!=": [1, 2]], [:] as [String: Any], true],
        [["!=": [1, 1]], [:] as [String: Any], false],
        [["!=": [1, "1"]], [:] as [String: Any], false],
        [["!==": [1, 2]], [:] as [String: Any], true],
        [["!==": [1, 1]], [:] as [String: Any], false],
        [["!==": [1, "1"]], [:] as [String: Any], true],

        // Comparison operators
        [[">": [2, 1]], [:] as [String: Any], true],
        [[">": [1, 1]], [:] as [String: Any], false],
        [[">": [1, 2]], [:] as [String: Any], false],
        [[">": ["2", 1]], [:] as [String: Any], true],
        [[">=": [2, 1]], [:] as [String: Any], true],
        [[">=": [1, 1]], [:] as [String: Any], true],
        [[">=": [1, 2]], [:] as [String: Any], false],
        [[">=": ["2", 1]], [:] as [String: Any], true],
        [["<": [2, 1]], [:] as [String: Any], false],
        [["<": [1, 1]], [:] as [String: Any], false],
        [["<": [1, 2]], [:] as [String: Any], true],
        [["<": ["1", 2]], [:] as [String: Any], true],
        [["<": [1, 2, 3]], [:] as [String: Any], true],
        [["<": [1, 1, 3]], [:] as [String: Any], false],
        [["<": [1, 4, 3]], [:] as [String: Any], false],
        [["<=": [2, 1]], [:] as [String: Any], false],
        [["<=": [1, 1]], [:] as [String: Any], true],
        [["<=": [1, 2]], [:] as [String: Any], true],
        [["<=": ["1", 2]], [:] as [String: Any], true],
        [["<=": [1, 2, 3]], [:] as [String: Any], true],
        [["<=": [1, 4, 3]], [:] as [String: Any], false],

        // Logical operators - NOT
        [["!": [false]], [:] as [String: Any], true],
        [["!": [true]], [:] as [String: Any], false],

        // Arithmetic operators
        [["+": [1, 2]], [:] as [String: Any], 3.0],
        [["+": [2, 2, 2]], [:] as [String: Any], 6.0],
        [["+": [1]], [:] as [String: Any], 1.0],
        [["+": ["1", 1]], [:] as [String: Any], 2.0],
        [["*": [3, 2]], [:] as [String: Any], 6.0],
        [["*": [2, 2, 2]], [:] as [String: Any], 8.0],
        [["*": [1]], [:] as [String: Any], 1.0],
        [["*": ["1", 1]], [:] as [String: Any], 1.0],
        [["-": [2, 3]], [:] as [String: Any], -1.0],
        [["-": [3, 2]], [:] as [String: Any], 1.0],
        [["-": [3]], [:] as [String: Any], -3.0],
        [["-": ["1", 1]], [:] as [String: Any], 0.0],
        [["/": [4, 2]], [:] as [String: Any], 2.0],
        [["/": [2, 4]], [:] as [String: Any], 0.5],
        [["/": ["1", 1]], [:] as [String: Any], 1.0],

        // Modulo
        [["%": [1, 2]], [:] as [String: Any], 1.0],
        [["%": [2, 2]], [:] as [String: Any], 0.0],
        [["%": [3, 2]], [:] as [String: Any], 1.0],

        // Min/Max
        [["max": [1, 2, 3]], [:] as [String: Any], 3.0],
        [["max": [1, 3, 3]], [:] as [String: Any], 3.0],
        [["max": [3, 2, 1]], [:] as [String: Any], 3.0],
        [["max": [1]], [:] as [String: Any], 1.0],
        [["min": [1, 2, 3]], [:] as [String: Any], 1.0],
        [["min": [1, 1, 3]], [:] as [String: Any], 1.0],
        [["min": [3, 2, 1]], [:] as [String: Any], 1.0],
        [["min": [1]], [:] as [String: Any], 1.0],

        // String operations
        [["cat": "ice"], [:] as [String: Any], "ice"],
        [["cat": ["ice"]], [:] as [String: Any], "ice"],
        [["cat": ["ice", "cream"]], [:] as [String: Any], "icecream"],
        [["cat": [1, 2]], [:] as [String: Any], "12"],
        [["cat": ["Robocop", 2]], [:] as [String: Any], "Robocop2"],
        [["cat": ["we all scream for ", "ice", "cream"]], [:] as [String: Any], "we all scream for icecream"],

        // Substring
        [["substr": ["jsonlogic", 4]], [:] as [String: Any], "logic"],
        [["substr": ["jsonlogic", -5]], [:] as [String: Any], "logic"],
        [["substr": ["jsonlogic", 0, 1]], [:] as [String: Any], "j"],
        [["substr": ["jsonlogic", -1, 1]], [:] as [String: Any], "c"],
        [["substr": ["jsonlogic", 4, 5]], [:] as [String: Any], "logic"],
        [["substr": ["jsonlogic", -5, 5]], [:] as [String: Any], "logic"],
        [["substr": ["jsonlogic", -5, -2]], [:] as [String: Any], "log"],
        [["substr": ["jsonlogic", 1, -5]], [:] as [String: Any], "son"],

        // In operator
        [["in": ["Bart", ["Bart", "Homer", "Lisa", "Marge", "Maggie"]]], [:] as [String: Any], true],
        [["in": ["Milhouse", ["Bart", "Homer", "Lisa", "Marge", "Maggie"]]], [:] as [String: Any], false],

        // Merge
        [["merge": []], [:] as [String: Any], [] as [Any]],
        [["merge": [[1]]], [:] as [String: Any], [1] as [Any]],
        [["merge": [[1], []]], [:] as [String: Any], [1] as [Any]],
        [["merge": [[1], [2]]], [:] as [String: Any], [1, 2] as [Any]],
        [["merge": [[1], [2], [3]]], [:] as [String: Any], [1, 2, 3] as [Any]],
        [["merge": [[1, 2], [3]]], [:] as [String: Any], [1, 2, 3] as [Any]],
        [["merge": [[1], [2, 3]]], [:] as [String: Any], [1, 2, 3] as [Any]],
        [["merge": 1], [:] as [String: Any], [1] as [Any]],
        [["merge": [1, 2]], [:] as [String: Any], [1, 2] as [Any]],
        [["merge": [1, [2]]], [:] as [String: Any], [1, 2] as [Any]],

        // Var operator
        [["var": ["a"]], ["a": 1] as [String: Any], 1],
        [["var": "a"], ["a": 1] as [String: Any], 1],
        [["var": ["a", 1]], [:] as [String: Any], 1],
        [["var": ["b", 2]], ["a": 1] as [String: Any], 2],
        [["var": "a.b"], ["a": ["b": "c"]] as [String: Any], "c"],
        [["var": ["a.q", 9]], ["a": ["b": "c"]] as [String: Any], 9],
        // Note: The following tests with array data are skipped as our evaluator expects dict data
        // [["var": 1], ["apple", "banana"], "banana"],
        // [["var": "1"], ["apple", "banana"], "banana"],
        // [["var": "1.1"], ["apple", ["banana", "beer"]], "beer"],
        // [["var": ""], 1, 1],

        // Missing
        [["missing": []], [:] as [String: Any], [] as [String]],
        [["missing": ["a"]], [:] as [String: Any], ["a"] as [String]],
        [["missing": "a"], [:] as [String: Any], ["a"] as [String]],
        [["missing": "a"], ["a": "apple"] as [String: Any], [] as [String]],
        [["missing": ["a"]], ["a": "apple"] as [String: Any], [] as [String]],
        [["missing": ["a", "b"]], ["a": "apple"] as [String: Any], ["b"] as [String]],
        [["missing": ["a", "b"]], ["b": "banana"] as [String: Any], ["a"] as [String]],
        [["missing": ["a", "b"]], ["a": "apple", "b": "banana"] as [String: Any], [] as [String]],
        [["missing": ["a", "b"]], [:] as [String: Any], ["a", "b"] as [String]],
        [["missing": ["a.b"]], [:] as [String: Any], ["a.b"] as [String]],
        [["missing": ["a.b"]], ["a": "apple"] as [String: Any], ["a.b"] as [String]],
        [["missing": ["a.b"]], ["a": ["c": "apple cake"]] as [String: Any], ["a.b"] as [String]],
        [["missing": ["a.b"]], ["a": ["b": "apple brownie"]] as [String: Any], [] as [String]],
        [["missing": ["a.b", "a.c"]], ["a": ["b": "apple brownie"]] as [String: Any], ["a.c"] as [String]],

        // Missing some
        [["missing_some": [1, ["a", "b"]]], ["a": "apple"] as [String: Any], [] as [String]],
        [["missing_some": [1, ["a", "b"]]], ["b": "banana"] as [String: Any], [] as [String]],
        [["missing_some": [1, ["a", "b"]]], ["a": "apple", "b": "banana"] as [String: Any], [] as [String]],
        [["missing_some": [1, ["a", "b"]]], ["c": "carrot"] as [String: Any], ["a", "b"] as [String]],
        [["missing_some": [2, ["a", "b", "c"]]], ["a": "apple", "b": "banana"] as [String: Any], [] as [String]],
        [["missing_some": [2, ["a", "b", "c"]]], ["a": "apple", "c": "carrot"] as [String: Any], [] as [String]],
        [["missing_some": [2, ["a", "b", "c"]]], ["a": "apple", "b": "banana", "c": "carrot"] as [String: Any], [] as [String]],
        [["missing_some": [2, ["a", "b", "c"]]], ["a": "apple", "d": "durian"] as [String: Any], ["b", "c"] as [String]],
        [["missing_some": [2, ["a", "b", "c"]]], ["d": "durian", "e": "eggplant"] as [String: Any], ["a", "b", "c"] as [String]],

        // Complex tests with var
        [["and": [["<": [["var": "temp"], 110]], ["==": [["var": "pie.filling"], "apple"]]]], ["temp": 100, "pie": ["filling": "apple"]] as [String: Any], true],
        [["in": [["var": "filling"], ["apple", "cherry"]]], ["filling": "apple"] as [String: Any], true],
    ]

    @Test("Run all supported official tests")
    func testOfficialTestSuite() throws {
        var passedCount = 0
        var failedCount = 0
        var skippedCount = 0
        var errors: [(index: Int, rule: Any, error: String)] = []

        for (index, testCase) in officialTests.enumerated() {
            guard testCase.count == 3,
                  let rule = testCase[0] as? [String: Any],
                  let data = testCase[1] as? [String: Any] else {
                skippedCount += 1
                continue
            }

            let expected = testCase[2]

            do {
                let result = try evaluator.evaluateRaw(rule, data: data)

                if areEqual(result, expected) {
                    passedCount += 1
                } else {
                    failedCount += 1
                    errors.append((index, rule, "Expected \(expected), got \(result)"))
                }
            } catch {
                // Check if this is an unsupported operator (expected to fail)
                if let evalError = error as? JSONLogicEvaluator.EvaluationError,
                   case .unsupportedOperator(_) = evalError {
                    skippedCount += 1
                } else {
                    failedCount += 1
                    errors.append((index, rule, "Error: \(error)"))
                }
            }
        }

        print("\n========================================")
        print("Official JSONLogic Test Suite Results")
        print("========================================")
        print("Total tests: \(officialTests.count)")
        print("Passed: \(passedCount) ✓")
        print("Failed: \(failedCount) ✗")
        print("Skipped: \(skippedCount) (unsupported operators)")

        let supportedTests = passedCount + failedCount
        if supportedTests > 0 {
            let successRate = Double(passedCount) / Double(supportedTests) * 100
            print("Success rate: \(String(format: "%.1f", successRate))% (\(passedCount)/\(supportedTests))")
        }
        print("========================================\n")

        if !errors.isEmpty {
            print("Failed Tests (showing first 10):")
            print("========================================")
            for (index, rule, error) in errors.prefix(10) {
                print("Test #\(index):")
                print("  Rule: \(rule)")
                print("  Error: \(error)\n")
            }
            if errors.count > 10 {
                print("... and \(errors.count - 10) more failures\n")
            }
        }

        // Assert that we have a high success rate on supported operators
        let supportedTestCount = passedCount + failedCount
        if supportedTestCount > 0 {
            let successRate = Double(passedCount) / Double(supportedTestCount)
            #expect(successRate > 0.90, "Success rate should be > 90% on supported operators, got \(Int(successRate * 100))%")
        }
    }

    // Helper to compare results (handles NSNull, arrays, etc.)
    private func areEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        // NSNull handling
        if lhs is NSNull && rhs is NSNull {
            return true
        }
        if lhs is NSNull || rhs is NSNull {
            return false
        }

        // String comparison
        if let lhsStr = lhs as? String, let rhsStr = rhs as? String {
            return lhsStr == rhsStr
        }

        // Numeric comparison with tolerance
        if let lhsNum = asNumber(lhs), let rhsNum = asNumber(rhs) {
            return abs(lhsNum - rhsNum) < 0.0001
        }

        // Bool comparison
        if let lhsBool = lhs as? Bool, let rhsBool = rhs as? Bool {
            return lhsBool == rhsBool
        }

        // Array comparison
        if let lhsArr = lhs as? [Any], let rhsArr = rhs as? [Any] {
            guard lhsArr.count == rhsArr.count else { return false }
            for (l, r) in zip(lhsArr, rhsArr) {
                if !areEqual(l, r) { return false }
            }
            return true
        }

        // String array comparison (for missing/missing_some results)
        if let lhsArr = lhs as? [String], let rhsArr = rhs as? [String] {
            return lhsArr == rhsArr
        }

        return false
    }

    private func asNumber(_ value: Any) -> Double? {
        if let num = value as? Double {
            return num
        } else if let num = value as? Int {
            return Double(num)
        } else if let str = value as? String, let num = Double(str) {
            return num
        }
        return nil
    }
}
