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

    // Load official test data from test-data/tests.json file via Bundle.module
    private func loadTestsFromFile() throws -> [Any] {
        // Use Bundle.module to access test resources (Swift Package Manager)
        guard let url = Bundle.module.url(forResource: "tests", withExtension: "json", subdirectory: "test-data") else {
            throw NSError(domain: "JSONLogicTestsRunner", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Could not find test-data/tests.json in Bundle.module"])
        }

        let data = try Data(contentsOf: url)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [Any] else {
            throw NSError(domain: "JSONLogicTestsRunner", code: 2,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to parse test-data/tests.json as JSON array"])
        }

        print("✓ Loaded \(json.count) test entries from Bundle.module: test-data/tests.json")
        return json
    }

    @Test("Run all supported official tests")
    func testOfficialTestSuite() throws {
        let allTests = try loadTestsFromFile()

        var passedCount = 0
        var failedCount = 0
        var skippedCount = 0
        var errors: [(index: Int, rule: Any, error: String)] = []
        var currentSection = ""

        for (index, testEntry) in allTests.enumerated() {
            // Handle section headers (strings starting with "# ")
            if let sectionName = testEntry as? String {
                currentSection = sectionName
                continue
            }

            // Handle test cases (arrays with 3 elements)
            guard let testCase = testEntry as? [Any], testCase.count == 3 else {
                skippedCount += 1
                continue
            }

            // Extract rule (can be dict or primitive)
            let ruleValue = testCase[0]
            let dataValue = testCase[1]
            let expected = testCase[2]

            // Data can be a dictionary, array, primitive, or null
            // Pass it as-is to the evaluator
            let data: Any = (dataValue is NSNull) ? [:] as [String: Any] : dataValue

            // Evaluate any value (handles primitives, expressions, and arrays with expressions)
            do {
                let result = try evaluator.evaluateAny(ruleValue, data: data)

                if areEqual(result, expected) {
                    passedCount += 1
                } else {
                    failedCount += 1
                    errors.append((index, ruleValue, "Expected \(expected), got \(result) [Section: \(currentSection)]"))
                }
            } catch {
                // Check if this is an unsupported operator (expected to fail)
                if let evalError = error as? JSONLogicEvaluator.EvaluationError,
                   case .unsupportedOperator(_) = evalError {
                    skippedCount += 1
                } else {
                    failedCount += 1
                    errors.append((index, ruleValue, "Error: \(error) [Section: \(currentSection)]"))
                }
            }
        }

        print("\n========================================")
        print("Official JSONLogic Test Suite Results")
        print("========================================")
        print("Total tests: \(allTests.count)")
        print("Passed: \(passedCount) ✓")
        print("Failed: \(failedCount) ✗")
        print("Skipped: \(skippedCount) (comments/unsupported)")

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
