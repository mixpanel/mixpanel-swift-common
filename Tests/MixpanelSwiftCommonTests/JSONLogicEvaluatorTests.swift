//
//  JSONLogicEvaluatorTests.swift
//  MixpanelSwiftCommon
//
//  Created by Mixpanel on 2026-03-31.
//

import Testing
import Foundation
@testable import MixpanelSwiftCommon

@Suite("JSONLogicEvaluator Tests")
struct JSONLogicEvaluatorTests {

    let evaluator = JSONLogicEvaluator()

    // MARK: - Comparison Operators

    @Suite("Equality Operators")
    struct EqualityTests {
        let evaluator = JSONLogicEvaluator()

        @Test("Loose equality (==) with same types")
        func testLooseEqualitySameTypes() throws {
            let expr: [String: Any] = ["==": [5, 5]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["==": ["hello", "hello"]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)

            let expr3: [String: Any] = ["==": [true, true]]
            #expect(try evaluator.evaluate(expr3, data: [:]) == true)
        }

        @Test("Loose equality (==) with type coercion")
        func testLooseEqualityWithCoercion() throws {
            let expr: [String: Any] = ["==": [5, "5"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["==": [5.0, 5]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)
        }

        @Test("Loose equality (==) with boolean coercion")
        func testLooseEqualityWithBooleanCoercion() throws {
            // Bool to String coercion
            let expr1: [String: Any] = ["==": [true, "true"]]
            #expect(try evaluator.evaluate(expr1, data: [:]) == true)

            let expr2: [String: Any] = ["==": [false, "false"]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)

            let expr3: [String: Any] = ["==": ["true", true]]
            #expect(try evaluator.evaluate(expr3, data: [:]) == true)

            let expr4: [String: Any] = ["==": ["false", false]]
            #expect(try evaluator.evaluate(expr4, data: [:]) == true)

            // Bool to Number coercion
            let expr5: [String: Any] = ["==": [true, 1]]
            #expect(try evaluator.evaluate(expr5, data: [:]) == true)

            let expr6: [String: Any] = ["==": [false, 0]]
            #expect(try evaluator.evaluate(expr6, data: [:]) == true)

            let expr7: [String: Any] = ["==": [1, true]]
            #expect(try evaluator.evaluate(expr7, data: [:]) == true)

            let expr8: [String: Any] = ["==": [0, false]]
            #expect(try evaluator.evaluate(expr8, data: [:]) == true)

            // Negative cases
            let expr9: [String: Any] = ["==": [true, "false"]]
            #expect(try evaluator.evaluate(expr9, data: [:]) == false)

            let expr10: [String: Any] = ["==": [true, 0]]
            #expect(try evaluator.evaluate(expr10, data: [:]) == false)

            // Test with var expressions (your use case)
            let data: [String: Any] = ["is_organic": true]
            let expr11: [String: Any] = ["==": [["var": "is_organic"], "true"]]
            #expect(try evaluator.evaluate(expr11, data: data) == true)

            let expr12: [String: Any] = ["==": [["var": "is_organic"], 1]]
            #expect(try evaluator.evaluate(expr12, data: data) == true)

            // Bool to numeric string coercion (critical for JSON rules)
            let expr13: [String: Any] = ["==": [true, "1"]]
            #expect(try evaluator.evaluate(expr13, data: [:]) == true)

            let expr14: [String: Any] = ["==": [false, "0"]]
            #expect(try evaluator.evaluate(expr14, data: [:]) == true)

            let expr15: [String: Any] = ["==": ["1", true]]
            #expect(try evaluator.evaluate(expr15, data: [:]) == true)

            let expr16: [String: Any] = ["==": ["0", false]]
            #expect(try evaluator.evaluate(expr16, data: [:]) == true)

            // Negative cases
            let expr17: [String: Any] = ["==": [true, "0"]]
            #expect(try evaluator.evaluate(expr17, data: [:]) == false)

            let expr18: [String: Any] = ["==": [false, "1"]]
            #expect(try evaluator.evaluate(expr18, data: [:]) == false)

            // Non-numeric strings should not match
            let expr19: [String: Any] = ["==": [true, "yes"]]
            #expect(try evaluator.evaluate(expr19, data: [:]) == false)
        }

        @Test("Loose equality (==) with null coercion")
        func testLooseEqualityWithNullCoercion() throws {
            // Null to number coercion (JSONLogic standard: null == 0)
            let expr1: [String: Any] = ["==": [NSNull(), 0]]
            #expect(try evaluator.evaluate(expr1, data: [:]) == true)

            let expr2: [String: Any] = ["==": [0, NSNull()]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)

            let expr3: [String: Any] = ["==": [NSNull(), 0.0]]
            #expect(try evaluator.evaluate(expr3, data: [:]) == true)

            // Null does not equal non-zero numbers
            let expr4: [String: Any] = ["==": [NSNull(), 1]]
            #expect(try evaluator.evaluate(expr4, data: [:]) == false)

            let expr5: [String: Any] = ["==": [NSNull(), -1]]
            #expect(try evaluator.evaluate(expr5, data: [:]) == false)

            // Null to null
            let expr6: [String: Any] = ["==": [NSNull(), NSNull()]]
            #expect(try evaluator.evaluate(expr6, data: [:]) == true)

            // Null does not equal strings, arrays, etc.
            let expr7: [String: Any] = ["==": [NSNull(), "null"]]
            #expect(try evaluator.evaluate(expr7, data: [:]) == false)

            let expr8: [String: Any] = ["==": [NSNull(), ""]]
            #expect(try evaluator.evaluate(expr8, data: [:]) == false)

            let expr9: [String: Any] = ["==": [NSNull(), []]]
            #expect(try evaluator.evaluate(expr9, data: [:]) == false)

            // Test with missing var (returns NSNull)
            let data: [String: Any] = ["name": "John"]
            let expr10: [String: Any] = ["==": [["var": "age"], 0]]
            #expect(try evaluator.evaluate(expr10, data: data) == true)

            let expr11: [String: Any] = ["==": [["var": "missing"], 0]]
            #expect(try evaluator.evaluate(expr11, data: [:]) == true)

            // Explicit null in data
            let dataWithNull: [String: Any] = ["count": NSNull()]
            let expr12: [String: Any] = ["==": [["var": "count"], 0]]
            #expect(try evaluator.evaluate(expr12, data: dataWithNull) == true)
        }

        @Test("Loose equality (==) with array unwrapping")
        func testLooseEqualityWithArrayUnwrapping() throws {
            // Single-element array unwrapping
            let expr1: [String: Any] = ["==": [[5], 5]]
            #expect(try evaluator.evaluate(expr1, data: [:]) == true)

            let expr2: [String: Any] = ["==": [5, [5]]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)

            let expr3: [String: Any] = ["==": [["hello"], "hello"]]
            #expect(try evaluator.evaluate(expr3, data: [:]) == true)

            let expr4: [String: Any] = ["==": [[true], true]]
            #expect(try evaluator.evaluate(expr4, data: [:]) == true)

            // Multi-element arrays do not unwrap
            let expr5: [String: Any] = ["==": [[5, 6], 5]]
            #expect(try evaluator.evaluate(expr5, data: [:]) == false)

            let expr6: [String: Any] = ["==": [[5, 6], [5, 6]]]
            #expect(try evaluator.evaluate(expr6, data: [:]) == false)

            // Empty array does not equal scalar
            let expr7: [String: Any] = ["==": [[], 0]]
            #expect(try evaluator.evaluate(expr7, data: [:]) == false)

            // Nested unwrapping
            let expr8: [String: Any] = ["==": [[5], [5]]]
            #expect(try evaluator.evaluate(expr8, data: [:]) == true)

            // Array with null unwraps and coerces
            let expr9: [String: Any] = ["==": [[NSNull()], 0]]
            #expect(try evaluator.evaluate(expr9, data: [:]) == true)

            // Test with var that returns single-element array
            let data: [String: Any] = ["selected": [42]]
            let expr10: [String: Any] = ["==": [["var": "selected"], 42]]
            #expect(try evaluator.evaluate(expr10, data: data) == true)

            // Array with boolean
            let expr11: [String: Any] = ["==": [[true], 1]]
            #expect(try evaluator.evaluate(expr11, data: [:]) == true)

            let expr12: [String: Any] = ["==": [[false], "false"]]
            #expect(try evaluator.evaluate(expr12, data: [:]) == true)
        }

        @Test("Loose equality (==) with version strings")
        func testLooseEqualityWithVersions() throws {
            let expr: [String: Any] = ["==": ["5.2.0", "5.2.0"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["==": ["5.2", "5.2.0"]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)
        }

        @Test("Strict equality (===) rejects type coercion")
        func testStrictEquality() throws {
            let expr: [String: Any] = ["===": [5, 5]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["===": [5, "5"]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)

            // Test with clearly different types (string vs number)
            let expr3: [String: Any] = ["===": ["5", 5]]
            #expect(try evaluator.evaluate(expr3, data: [:]) == false)

            // Test same values, same types
            let expr4: [String: Any] = ["===": ["hello", "hello"]]
            #expect(try evaluator.evaluate(expr4, data: [:]) == true)
        }

        @Test("Loose inequality (!=)")
        func testLooseInequality() throws {
            let expr: [String: Any] = ["!=": [5, 3]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["!=": [5, 5]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)
        }

        @Test("Strict inequality (!==)")
        func testStrictInequality() throws {
            let expr: [String: Any] = ["!==": [5, "5"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["!==": [5, 5]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)
        }
    }

    @Suite("Comparison Operators")
    struct ComparisonTests {
        let evaluator = JSONLogicEvaluator()

        @Test("Greater than (>) with numbers")
        func testGreaterThanNumbers() throws {
            let expr: [String: Any] = [">": [10, 5]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = [">": [5, 10]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)
        }

        @Test("Greater than (>) with version strings")
        func testGreaterThanVersions() throws {
            let expr: [String: Any] = [">": ["5.10.0", "5.2.0"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = [">": ["5.2.0", "5.10.0"]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)

            let expr3: [String: Any] = [">": ["2.0.0", "1.9.9"]]
            #expect(try evaluator.evaluate(expr3, data: [:]) == true)
        }

        @Test("Greater or equal (>=)")
        func testGreaterOrEqual() throws {
            let expr: [String: Any] = [">=": [10, 5]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = [">=": [5, 5]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)

            let expr3: [String: Any] = [">=": [3, 5]]
            #expect(try evaluator.evaluate(expr3, data: [:]) == false)
        }

        @Test("Less than (<) with numbers")
        func testLessThanNumbers() throws {
            let expr: [String: Any] = ["<": [5, 10]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["<": [10, 5]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)
        }

        @Test("Less than (<) with version strings")
        func testLessThanVersions() throws {
            let expr: [String: Any] = ["<": ["5.2.0", "5.10.0"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["<": ["5.10.0", "5.2.0"]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)
        }

        @Test("Less than (<) with 3-arg chaining")
        func testLessThanChaining() throws {
            let expr: [String: Any] = ["<": [1, 2, 3]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["<": [1, 3, 2]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)
        }

        @Test("Less or equal (<=)")
        func testLessOrEqual() throws {
            let expr: [String: Any] = ["<=": [5, 10]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["<=": [5, 5]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)

            let expr3: [String: Any] = ["<=": [10, 5]]
            #expect(try evaluator.evaluate(expr3, data: [:]) == false)
        }

        @Test("Less or equal (<=) with 3-arg chaining")
        func testLessOrEqualChaining() throws {
            let expr: [String: Any] = ["<=": [1, 2, 3]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["<=": [1, 2, 2]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)
        }
    }

    // MARK: - Logical Operators

    @Suite("Logical Operators")
    struct LogicalTests {
        let evaluator = JSONLogicEvaluator()

        @Test("AND operator - all true")
        func testAndAllTrue() throws {
            let expr: [String: Any] = [
                "and": [
                    [">": [5, 3]],
                    ["<": [2, 4]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("AND operator - one false")
        func testAndOneFalse() throws {
            let expr: [String: Any] = [
                "and": [
                    [">": [5, 3]],
                    ["<": [10, 4]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: [:]) == false)
        }

        @Test("OR operator - one true")
        func testOrOneTrue() throws {
            let expr: [String: Any] = [
                "or": [
                    [">": [5, 3]],
                    ["<": [10, 4]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("OR operator - all false")
        func testOrAllFalse() throws {
            let expr: [String: Any] = [
                "or": [
                    [">": [2, 3]],
                    ["<": [10, 4]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: [:]) == false)
        }

        @Test("NOT operator")
        func testNot() throws {
            let expr: [String: Any] = ["!": [">": [5, 3]]]
            #expect(try evaluator.evaluate(expr, data: [:]) == false)

            let expr2: [String: Any] = ["!": [">": [2, 3]]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)
        }

        @Test("Double negation (!!) for truthy values")
        func testDoubleNegation() throws {
            let expr: [String: Any] = ["!!": [1]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["!!": [0]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)

            let expr3: [String: Any] = ["!!": [""]]
            #expect(try evaluator.evaluate(expr3, data: [:]) == false)

            let expr4: [String: Any] = ["!!": ["text"]]
            #expect(try evaluator.evaluate(expr4, data: [:]) == true)
        }
    }

    // MARK: - Arithmetic Operators

    @Suite("Arithmetic Operators")
    struct ArithmeticTests {
        let evaluator = JSONLogicEvaluator()

        @Test("Addition (+)")
        func testAddition() throws {
            let expr: [String: Any] = ["+": [2, 3, 5]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true) // 10 is truthy

            // Verify actual value using comparison
            let expr2: [String: Any] = ["==": [["+": [2, 3]], 5]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)
        }

        @Test("Subtraction (-) binary")
        func testSubtractionBinary() throws {
            let expr: [String: Any] = ["==": [["-": [10, 3]], 7]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Subtraction (-) unary negation")
        func testSubtractionUnary() throws {
            let expr: [String: Any] = ["==": [["-": [5]], -5]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Multiplication (*)")
        func testMultiplication() throws {
            let expr: [String: Any] = ["==": [["*": [2, 3, 4]], 24]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Division (/)")
        func testDivision() throws {
            let expr: [String: Any] = ["==": [["/": [10, 2]], 5]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Modulo (%)")
        func testModulo() throws {
            let expr: [String: Any] = ["==": [["%": [10, 3]], 1]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Min function")
        func testMin() throws {
            let expr: [String: Any] = ["==": [["min": [5, 2, 8, 1]], 1]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Max function")
        func testMax() throws {
            let expr: [String: Any] = ["==": [["max": [5, 2, 8, 1]], 8]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }
    }

    // MARK: - String/Array Operators

    @Suite("String Operations")
    struct StringTests {
        let evaluator = JSONLogicEvaluator()

        @Test("Concatenation (cat)")
        func testCat() throws {
            let expr: [String: Any] = ["==": [["cat": ["Hello", " ", "World"]], "Hello World"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Substring (substr) - 2 args")
        func testSubstrTwoArgs() throws {
            let expr: [String: Any] = ["==": [["substr": ["Hello", 1]], "ello"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Substring (substr) - 3 args")
        func testSubstrThreeArgs() throws {
            let expr: [String: Any] = ["==": [["substr": ["Hello", 0, 3]], "Hel"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Substring (substr) - negative index")
        func testSubstrNegativeIndex() throws {
            let expr: [String: Any] = ["==": [["substr": ["Hello", -3]], "llo"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Substring (substr) - negative length")
        func testSubstrNegativeLength() throws {
            let expr: [String: Any] = ["==": [["substr": ["Hello", 0, -1]], "Hell"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("In operator - element in array")
        func testInOperator() throws {
            let expr: [String: Any] = ["in": ["banana", ["apple", "banana", "cherry"]]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["in": ["grape", ["apple", "banana", "cherry"]]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)
        }
    }

    @Suite("Array Operations")
    struct ArrayTests {
        let evaluator = JSONLogicEvaluator()

        @Test("Merge arrays")
        func testMerge() throws {
            // Test that merge flattens arrays
            let expr: [String: Any] = [
                "==": [
                    ["merge": [[1, 2], [3, 4]]],
                    [1, 2, 3, 4]
                ]
            ]
            // Note: Array comparison in JSONLogic isn't direct, so we test element presence
            // For now, just ensure it evaluates without error
            _ = try evaluator.evaluate(expr, data: [:])
        }

        @Test("Missing - find missing keys")
        func testMissing() throws {
            let data: [String: Any] = ["name": "John", "age": 30]

            // Should return empty array (truthy as non-empty array would be if there were missing)
            // But since it returns array of strings, we need to check differently
            // Let's verify the function doesn't throw
            let expr: [String: Any] = ["missing": ["name", "email"]]
            _ = try evaluator.evaluate(expr, data: data)
        }

        @Test("Missing some - check minimum required fields")
        func testMissingSome() throws {
            let data: [String: Any] = ["name": "John"]

            // Need at least 1 of [name, email, phone] - should pass
            let expr: [String: Any] = ["missing_some": [1, ["name", "email", "phone"]]]
            _ = try evaluator.evaluate(expr, data: data)
        }
    }

    // MARK: - Variable Resolution

    @Suite("Variable Operations")
    struct VariableTests {
        let evaluator = JSONLogicEvaluator()

        @Test("Var - simple variable access")
        func testVarSimple() throws {
            let data: [String: Any] = ["name": "John", "age": 30]
            let expr: [String: Any] = ["==": [["var": "name"], "John"]]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("Var - with default value")
        func testVarWithDefault() throws {
            let data: [String: Any] = ["name": "John"]
            let expr: [String: Any] = ["==": [["var": ["email", "default@example.com"]], "default@example.com"]]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("Var - nested property access")
        func testVarNested() throws {
            let data: [String: Any] = [
                "user": [
                    "profile": [
                        "name": "John"
                    ]
                ]
            ]
            let expr: [String: Any] = ["==": [["var": "user.profile.name"], "John"]]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("Var - array index access")
        func testVarArrayIndex() throws {
            let data: [String: Any] = ["items": ["first", "second", "third"]]
            let expr: [String: Any] = ["==": [["var": "items.1"], "second"]]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }
    }

    // MARK: - Complex Real-World Scenarios

    @Suite("Real-World Scenarios")
    struct RealWorldTests {
        let evaluator = JSONLogicEvaluator()

        @Test("Version comparison with variable")
        func testVersionComparisonWithVar() throws {
            let data: [String: Any] = ["$lib_version": "5.10.0"]
            let expr: [String: Any] = [">": [["var": "$lib_version"], "5.2.0"]]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("Complex AND/OR with multiple conditions")
        func testComplexLogic() throws {
            let data: [String: Any] = [
                "amount": 150,
                "currency": "USD",
                "status": "active"
            ]

            let expr: [String: Any] = [
                "and": [
                    [">": [["var": "amount"], 100]],
                    ["==": [["var": "currency"], "USD"]],
                    ["==": [["var": "status"], "active"]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("Property filter with missing field")
        func testPropertyFilterMissing() throws {
            let data: [String: Any] = ["name": "John"]
            let expr: [String: Any] = ["==": [["var": "email"], "test@example.com"]]
            // Missing field should not equal the value
            #expect(try evaluator.evaluate(expr, data: data) == false)
        }

        @Test("Arithmetic in comparisons")
        func testArithmeticInComparison() throws {
            let data: [String: Any] = ["price": 100, "tax": 10]
            let expr: [String: Any] = [">": [["+": [["var": "price"], ["var": "tax"]]], 100]]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("String concatenation with variables")
        func testStringConcatWithVars() throws {
            let data: [String: Any] = ["first": "Hello", "second": "World"]
            let expr: [String: Any] = [
                "==": [
                    ["cat": [["var": "first"], " ", ["var": "second"]]],
                    "Hello World"
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("Boolean with numeric string in AND condition")
        func testBooleanWithNumericStringInAnd() throws {
            // Real-world scenario: Event data with boolean flags and numeric thresholds
            let data: [String: Any] = [
                "severity": "critical",
                "is_blocking": true,      // Boolean from Swift
                "score": 9.5              // Number
            ]

            // Rule from JSON with string "1" for boolean check
            let expr: [String: Any] = [
                "and": [
                    ["==": [["var": "severity"], "critical"]],
                    ["==": [["var": "is_blocking"], "1"]],  // Bool true should equal "1"
                    [">": [["var": "score"], "9.1"]]        // Number should compare with string
                ]
            ]

            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("Mixed type comparisons in complex rule")
        func testMixedTypeComparisons() throws {
            let data: [String: Any] = [
                "is_organic": true,
                "count": 5,
                "version": "2.1.0"
            ]

            let expr: [String: Any] = [
                "and": [
                    ["==": [["var": "is_organic"], "1"]],     // Bool == numeric string
                    [">": [["var": "count"], "3"]],           // Number > numeric string
                    [">=": [["var": "version"], "2.0.0"]]     // Version string comparison
                ]
            ]

            #expect(try evaluator.evaluate(expr, data: data) == true)
        }
    }

    // MARK: - Error Cases

    @Suite("Error Handling")
    struct ErrorTests {
        let evaluator = JSONLogicEvaluator()

        @Test("Unsupported operator throws error")
        func testUnsupportedOperator() throws {
            let expr: [String: Any] = ["unknown_op": [1, 2]]

            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(expr, data: [:])
            }
        }

        @Test("Invalid expression format throws error")
        func testInvalidExpression() throws {
            let expr: [String: Any] = [:]

            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(expr, data: [:])
            }
        }

        @Test("Type mismatch in operators")
        func testTypeMismatch() throws {
            // Division requires exactly 2 args
            let expr: [String: Any] = ["/": [10]]

            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(expr, data: [:])
            }
        }
    }

    // MARK: - Edge Cases

    @Suite("Edge Cases")
    struct EdgeCaseTests {
        let evaluator = JSONLogicEvaluator()

        @Test("Empty string vs null")
        func testEmptyStringVsNull() throws {
            let expr: [String: Any] = ["==": ["", ""]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Zero is falsy")
        func testZeroFalsy() throws {
            let expr: [String: Any] = ["!!": [0]]
            #expect(try evaluator.evaluate(expr, data: [:]) == false)
        }

        @Test("Empty array is falsy")
        func testEmptyArrayFalsy() throws {
            let expr: [String: Any] = ["!!": [[Any]()]]
            #expect(try evaluator.evaluate(expr, data: [:]) == false)
        }

        @Test("Version string with 2 components")
        func testVersionTwoComponents() throws {
            let expr: [String: Any] = [">": ["5.10", "5.2"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Comparison with mixed number types")
        func testMixedNumberTypes() throws {
            let expr: [String: Any] = ["==": [5.0, 5]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }
    }

    // MARK: - Control Flow Operators

    @Suite("Control Flow Operators")
    struct ControlFlowTests {
        let evaluator = JSONLogicEvaluator()

        // MARK: Ternary Operator (?:)

        @Test("Ternary (?:) with true condition")
        func testTernaryTrue() throws {
            let expr: [String: Any] = ["?:": [true, "yes", "no"]]
            let result = try evaluator.evaluateRaw(expr, data: [:])
            #expect(result as? String == "yes")
        }

        @Test("Ternary (?:) with false condition")
        func testTernaryFalse() throws {
            let expr: [String: Any] = ["?:": [false, "yes", "no"]]
            let result = try evaluator.evaluateRaw(expr, data: [:])
            #expect(result as? String == "no")
        }

        @Test("Ternary (?:) with truthy/falsy values")
        func testTernaryTruthyFalsy() throws {
            // Non-zero number is truthy
            let expr1: [String: Any] = ["?:": [1, "yes", "no"]]
            #expect(try evaluator.evaluateRaw(expr1, data: [:]) as? String == "yes")

            // Zero is falsy
            let expr2: [String: Any] = ["?:": [0, "yes", "no"]]
            #expect(try evaluator.evaluateRaw(expr2, data: [:]) as? String == "no")

            // Empty array is falsy
            let expr3: [String: Any] = ["?:": [[Any](), "yes", "no"]]
            #expect(try evaluator.evaluateRaw(expr3, data: [:]) as? String == "no")
        }

        @Test("Ternary (?:) with nested expressions")
        func testTernaryNested() throws {
            let data: [String: Any] = ["age": 25]
            let expr: [String: Any] = [
                "?:": [
                    [">": [["var": "age"], 18]],
                    "adult",
                    "minor"
                ]
            ]
            let result = try evaluator.evaluateRaw(expr, data: data)
            #expect(result as? String == "adult")
        }

        // MARK: If Operator

        @Test("If passthrough (single value)")
        func testIfPassthrough() throws {
            let expr: [String: Any] = ["if": [true, "result"]]
            let result = try evaluator.evaluateRaw(expr, data: [:])
            #expect(result as? String == "result")
        }

        @Test("If-then-else")
        func testIfThenElse() throws {
            let expr1: [String: Any] = ["if": [true, "yes", "no"]]
            #expect(try evaluator.evaluateRaw(expr1, data: [:]) as? String == "yes")

            let expr2: [String: Any] = ["if": [false, "yes", "no"]]
            #expect(try evaluator.evaluateRaw(expr2, data: [:]) as? String == "no")
        }

        @Test("If with chained conditions (if-elseif-else)")
        func testIfChained() throws {
            let data: [String: Any] = ["temp": 75]
            let expr: [String: Any] = [
                "if": [
                    [">": [["var": "temp"], 90]], "hot",
                    [">": [["var": "temp"], 70]], "warm",
                    "cold"
                ]
            ]
            let result = try evaluator.evaluateRaw(expr, data: data)
            #expect(result as? String == "warm")
        }

        @Test("If with all false conditions returns last value")
        func testIfAllFalse() throws {
            let expr: [String: Any] = [
                "if": [
                    false, "first",
                    false, "second",
                    "default"
                ]
            ]
            let result = try evaluator.evaluateRaw(expr, data: [:])
            #expect(result as? String == "default")
        }

        @Test("If with falsy condition")
        func testIfFalsyCondition() throws {
            // Empty array is falsy
            let expr: [String: Any] = ["if": [[Any](), "yes", "no"]]
            #expect(try evaluator.evaluateRaw(expr, data: [:]) as? String == "no")

            // Zero is falsy
            let expr2: [String: Any] = ["if": [0, "yes", "no"]]
            #expect(try evaluator.evaluateRaw(expr2, data: [:]) as? String == "no")
        }

        @Test("If with variable conditions")
        func testIfWithVariables() throws {
            let data: [String: Any] = ["premium": true, "age": 30]
            let expr: [String: Any] = [
                "if": [
                    ["var": "premium"], "premium_user",
                    [">": [["var": "age"], 18]], "standard_user",
                    "guest"
                ]
            ]
            let result = try evaluator.evaluateRaw(expr, data: data)
            #expect(result as? String == "premium_user")
        }
    }

    // MARK: - Array Transformation Operators

    @Suite("Array Transformation Operators")
    struct ArrayTransformationTests {
        let evaluator = JSONLogicEvaluator()

        // MARK: Filter Operator

        @Test("Filter with simple predicate")
        func testFilterSimple() throws {
            let data: [String: Any] = ["numbers": [1, 2, 3, 4, 5]]
            let expr: [String: Any] = [
                "filter": [
                    ["var": "numbers"],
                    [">": [["var": ""], 2]]
                ]
            ]
            let result = try evaluator.evaluateRaw(expr, data: data) as? [Any]
            #expect(result?.count == 3)
            #expect(result?[0] as? Int == 3)
            #expect(result?[1] as? Int == 4)
            #expect(result?[2] as? Int == 5)
        }

        @Test("Filter with no matches")
        func testFilterNoMatches() throws {
            let data: [String: Any] = ["numbers": [1, 2, 3]]
            let expr: [String: Any] = [
                "filter": [
                    ["var": "numbers"],
                    [">": [["var": ""], 10]]
                ]
            ]
            let result = try evaluator.evaluateRaw(expr, data: data) as? [Any]
            #expect(result?.count == 0)
        }

        @Test("Filter with object arrays")
        func testFilterObjects() throws {
            let data: [String: Any] = [
                "users": [
                    ["name": "Alice", "age": 30],
                    ["name": "Bob", "age": 25],
                    ["name": "Charlie", "age": 35]
                ]
            ]
            let expr: [String: Any] = [
                "filter": [
                    ["var": "users"],
                    [">=": [["var": ".age"], 30]]
                ]
            ]
            let result = try evaluator.evaluateRaw(expr, data: data) as? [[String: Any]]
            #expect(result?.count == 2)
            #expect(result?[0]["name"] as? String == "Alice")
            #expect(result?[1]["name"] as? String == "Charlie")
        }

        @Test("Filter with all matches")
        func testFilterAllMatch() throws {
            let data: [String: Any] = ["numbers": [10, 20, 30]]
            let expr: [String: Any] = [
                "filter": [
                    ["var": "numbers"],
                    [">": [["var": ""], 5]]
                ]
            ]
            let result = try evaluator.evaluateRaw(expr, data: data) as? [Any]
            #expect(result?.count == 3)
        }

        @Test("Filter with null data")
        func testFilterNull() throws {
            let expr: [String: Any] = [
                "filter": [
                    NSNull(),
                    [">": [["var": ""], 2]]
                ]
            ]
            let result = try evaluator.evaluateRaw(expr, data: [:]) as? [Any]
            #expect(result?.count == 0)
        }

        // MARK: Map Operator

        @Test("Map with simple transformation")
        func testMapSimple() throws {
            let data: [String: Any] = ["numbers": [1, 2, 3]]
            let expr: [String: Any] = [
                "map": [
                    ["var": "numbers"],
                    ["*": [["var": ""], 2]]
                ]
            ]
            let result = try evaluator.evaluateRaw(expr, data: data) as? [Any]
            #expect(result?.count == 3)
            #expect(result?[0] as? Double == 2.0)
            #expect(result?[1] as? Double == 4.0)
            #expect(result?[2] as? Double == 6.0)
        }

        @Test("Map extracting property from objects")
        func testMapPropertyExtraction() throws {
            let data: [String: Any] = [
                "users": [
                    ["name": "Alice", "age": 30],
                    ["name": "Bob", "age": 25]
                ]
            ]
            let expr: [String: Any] = [
                "map": [
                    ["var": "users"],
                    ["var": ".name"]
                ]
            ]
            let result = try evaluator.evaluateRaw(expr, data: data) as? [Any]
            #expect(result?.count == 2)
            #expect(result?[0] as? String == "Alice")
            #expect(result?[1] as? String == "Bob")
        }

        @Test("Map with complex expression")
        func testMapComplex() throws {
            let data: [String: Any] = ["items": [10, 20, 30]]
            let expr: [String: Any] = [
                "map": [
                    ["var": "items"],
                    ["+": [["var": ""], 5]]
                ]
            ]
            let result = try evaluator.evaluateRaw(expr, data: data) as? [Any]
            #expect(result?.count == 3)
            #expect(result?[0] as? Double == 15.0)
            #expect(result?[1] as? Double == 25.0)
            #expect(result?[2] as? Double == 35.0)
        }

        @Test("Map with null data")
        func testMapNull() throws {
            let expr: [String: Any] = [
                "map": [
                    NSNull(),
                    ["*": [["var": ""], 2]]
                ]
            ]
            let result = try evaluator.evaluateRaw(expr, data: [:]) as? [Any]
            #expect(result?.count == 0)
        }

        // MARK: Reduce Operator

        @Test("Reduce with sum")
        func testReduceSum() throws {
            let data: [String: Any] = ["numbers": [1, 2, 3, 4]]
            let expr: [String: Any] = [
                "reduce": [
                    ["var": "numbers"],
                    ["+": [["var": "current"], ["var": "accumulator"]]],
                    0
                ]
            ]
            let result = try evaluator.evaluateRaw(expr, data: data)
            #expect(result as? Double == 10.0)
        }

        @Test("Reduce with product")
        func testReduceProduct() throws {
            let data: [String: Any] = ["numbers": [2, 3, 4]]
            let expr: [String: Any] = [
                "reduce": [
                    ["var": "numbers"],
                    ["*": [["var": "current"], ["var": "accumulator"]]],
                    1
                ]
            ]
            let result = try evaluator.evaluateRaw(expr, data: data)
            #expect(result as? Double == 24.0)
        }

        @Test("Reduce without initial value")
        func testReduceNoInitial() throws {
            let data: [String: Any] = ["numbers": [5, 10, 15]]
            let expr: [String: Any] = [
                "reduce": [
                    ["var": "numbers"],
                    ["+": [["var": "current"], ["var": "accumulator"]]]
                ]
            ]
            let result = try evaluator.evaluateRaw(expr, data: data)
            #expect(result as? Double == 30.0)
        }

        @Test("Reduce with variable initial value")
        func testReduceVariableInitial() throws {
            let data: [String: Any] = [
                "numbers": [1, 2, 3],
                "starting": 10
            ]
            let expr: [String: Any] = [
                "reduce": [
                    ["var": "numbers"],
                    ["+": [["var": "current"], ["var": "accumulator"]]],
                    ["var": "starting"]
                ]
            ]
            let result = try evaluator.evaluateRaw(expr, data: data)
            #expect(result as? Double == 16.0)
        }

        @Test("Reduce with object array")
        func testReduceObjects() throws {
            let data: [String: Any] = [
                "items": [
                    ["price": 10],
                    ["price": 20],
                    ["price": 30]
                ]
            ]
            let expr: [String: Any] = [
                "reduce": [
                    ["var": "items"],
                    ["+": [["var": "current.price"], ["var": "accumulator"]]],
                    0
                ]
            ]
            let result = try evaluator.evaluateRaw(expr, data: data)
            #expect(result as? Double == 60.0)
        }

        @Test("Reduce with null data")
        func testReduceNull() throws {
            let expr: [String: Any] = [
                "reduce": [
                    NSNull(),
                    ["+": [["var": "current"], ["var": "accumulator"]]],
                    0
                ]
            ]
            let result = try evaluator.evaluateRaw(expr, data: [:])
            #expect(result as? Int == 0)
        }

        // MARK: All Operator

        @Test("All with matching predicate")
        func testAllMatching() throws {
            let data: [String: Any] = ["numbers": [2, 4, 6, 8]]
            let expr: [String: Any] = [
                "all": [
                    ["var": "numbers"],
                    ["==": [["%": [["var": ""], 2]], 0]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("All with non-matching predicate")
        func testAllNonMatching() throws {
            let data: [String: Any] = ["numbers": [2, 3, 4]]
            let expr: [String: Any] = [
                "all": [
                    ["var": "numbers"],
                    ["==": [["%": [["var": ""], 2]], 0]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == false)
        }

        @Test("All with empty array")
        func testAllEmpty() throws {
            let data: [String: Any] = ["numbers": [Any]()]
            let expr: [String: Any] = [
                "all": [
                    ["var": "numbers"],
                    [">": [["var": ""], 0]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == false)
        }

        @Test("All with object array")
        func testAllObjects() throws {
            let data: [String: Any] = [
                "users": [
                    ["age": 25],
                    ["age": 30],
                    ["age": 35]
                ]
            ]
            let expr: [String: Any] = [
                "all": [
                    ["var": "users"],
                    [">=": [["var": ".age"], 18]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        // MARK: Some Operator

        @Test("Some with matching element")
        func testSomeMatching() throws {
            let data: [String: Any] = ["numbers": [1, 2, 3, 4, 5]]
            let expr: [String: Any] = [
                "some": [
                    ["var": "numbers"],
                    [">": [["var": ""], 4]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("Some with no matching element")
        func testSomeNonMatching() throws {
            let data: [String: Any] = ["numbers": [1, 2, 3]]
            let expr: [String: Any] = [
                "some": [
                    ["var": "numbers"],
                    [">": [["var": ""], 10]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == false)
        }

        @Test("Some with empty array")
        func testSomeEmpty() throws {
            let data: [String: Any] = ["numbers": [Any]()]
            let expr: [String: Any] = [
                "some": [
                    ["var": "numbers"],
                    [">": [["var": ""], 0]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == false)
        }

        @Test("Some with object array")
        func testSomeObjects() throws {
            let data: [String: Any] = [
                "users": [
                    ["premium": false],
                    ["premium": true],
                    ["premium": false]
                ]
            ]
            let expr: [String: Any] = [
                "some": [
                    ["var": "users"],
                    ["var": ".premium"]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        // MARK: None Operator

        @Test("None with non-matching elements")
        func testNoneNonMatching() throws {
            let data: [String: Any] = ["numbers": [1, 2, 3, 4]]
            let expr: [String: Any] = [
                "none": [
                    ["var": "numbers"],
                    [">": [["var": ""], 10]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("None with matching element")
        func testNoneMatching() throws {
            let data: [String: Any] = ["numbers": [1, 2, 3, 15]]
            let expr: [String: Any] = [
                "none": [
                    ["var": "numbers"],
                    [">": [["var": ""], 10]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == false)
        }

        @Test("None with empty array")
        func testNoneEmpty() throws {
            let data: [String: Any] = ["numbers": [Any]()]
            let expr: [String: Any] = [
                "none": [
                    ["var": "numbers"],
                    [">": [["var": ""], 0]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("None with object array")
        func testNoneObjects() throws {
            let data: [String: Any] = [
                "users": [
                    ["banned": false],
                    ["banned": false],
                    ["banned": false]
                ]
            ]
            let expr: [String: Any] = [
                "none": [
                    ["var": "users"],
                    ["var": ".banned"]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }
    }

    // MARK: - Production Type Safety Tests

    @Suite("Production Type Safety & Crash Prevention")
    struct ProductionTypeSafetyTests {
        let evaluator = JSONLogicEvaluator()

        @Test("NSNumber(1) vs string literal comparisons")
        func testNSNumberVsStringLiterals() throws {
            // Simulate JSONSerialization data
            let json = #"{"count": 1, "zero": 0}"#
            let data = try JSONSerialization.jsonObject(
                with: json.data(using: .utf8)!
            ) as! [String: Any]

            // count=1 (NSNumber) should NOT equal "true"
            let e1: [String: Any] = ["==": [["var": "count"], "true"]]
            #expect(try evaluator.evaluate(e1, data: data) == false)

            // count=1 (NSNumber) SHOULD equal "1"
            let e2: [String: Any] = ["==": [["var": "count"], "1"]]
            #expect(try evaluator.evaluate(e2, data: data) == true)

            // zero=0 should NOT equal "false"
            let e3: [String: Any] = ["==": [["var": "zero"], "false"]]
            #expect(try evaluator.evaluate(e3, data: data) == false)

            // zero=0 SHOULD equal "0"
            let e4: [String: Any] = ["==": [["var": "zero"], "0"]]
            #expect(try evaluator.evaluate(e4, data: data) == true)
        }

        @Test("JSONSerialization boolean vs string comparisons")
        func testNSBooleanVsStrings() throws {
            let json = #"{"flag": true, "disabled": false}"#
            let data = try JSONSerialization.jsonObject(
                with: json.data(using: .utf8)!
            ) as! [String: Any]

            // flag=true SHOULD equal "true" (literal)
            let e1: [String: Any] = ["==": [["var": "flag"], "true"]]
            #expect(try evaluator.evaluate(e1, data: data) == true)

            // flag=true SHOULD equal "1" (numeric)
            let e2: [String: Any] = ["==": [["var": "flag"], "1"]]
            #expect(try evaluator.evaluate(e2, data: data) == true)

            // disabled=false SHOULD equal "false"
            let e3: [String: Any] = ["==": [["var": "disabled"], "false"]]
            #expect(try evaluator.evaluate(e3, data: data) == true)

            // disabled=false SHOULD equal "0"
            let e4: [String: Any] = ["==": [["var": "disabled"], "0"]]
            #expect(try evaluator.evaluate(e4, data: data) == true)
        }

        @Test("Null recursive coercion")
        func testNullRecursiveCoercion() throws {
            let data: [String: Any] = ["name": "John"]

            // missing property = null, should equal "0" (null→0→"0")
            let e1: [String: Any] = ["==": [["var": "age"], "0"]]
            #expect(try evaluator.evaluate(e1, data: data) == true)

            // null should equal 0 (null→0)
            let e2: [String: Any] = ["==": [["var": "age"], 0]]
            #expect(try evaluator.evaluate(e2, data: data) == true)

            // null should NOT equal "true" or "false" (non-numeric strings)
            let e3: [String: Any] = ["==": [["var": "age"], "true"]]
            #expect(try evaluator.evaluate(e3, data: data) == false)

            let e4: [String: Any] = ["==": [["var": "age"], "false"]]
            #expect(try evaluator.evaluate(e4, data: data) == false)

            // null should NOT equal non-zero strings
            let e5: [String: Any] = ["==": [["var": "age"], "1"]]
            #expect(try evaluator.evaluate(e5, data: data) == false)
        }

        @Test("Array unwrapping in comparisons - no crash")
        func testArrayUnwrappingNoThrow() throws {
            let data: [String: Any] = ["items": [5, 10, 15]]

            // Array comparison shouldn't throw
            let e1: [String: Any] = [">": [["var": "items"], "3"]]
            #expect(try evaluator.evaluate(e1, data: data) == true)  // [5,10,15] → 5 > 3

            let e2: [String: Any] = ["<": [["var": "items"], "10"]]
            #expect(try evaluator.evaluate(e2, data: data) == true)  // [5,10,15] → 5 < 10

            // Single-element array
            let data2: [String: Any] = ["value": [42]]
            let e3: [String: Any] = ["==": [["var": "value"], "42"]]
            #expect(try evaluator.evaluate(e3, data: data2) == true)  // [42] → 42 == "42"

            // Empty array does not unwrap (stays as array, not equal to scalar)
            let data3: [String: Any] = ["value": []]
            let e4: [String: Any] = ["==": [["var": "value"], "0"]]
            #expect(try evaluator.evaluate(e4, data: data3) == false)  // [] does not unwrap
        }

        @Test("All operators with string RHS values")
        func testAllOperatorsStringRHS() throws {
            let json = #"{"count": 5, "name": "test", "flag": true, "items": ["a", "b"]}"#
            let data = try JSONSerialization.jsonObject(
                with: json.data(using: .utf8)!
            ) as! [String: Any]

            // Equality
            #expect(try evaluator.evaluate(["==": [["var": "count"], "5"]], data: data) == true)

            // Greater than
            #expect(try evaluator.evaluate([">": [["var": "count"], "3"]], data: data) == true)

            // Greater or equal
            #expect(try evaluator.evaluate([">=": [["var": "count"], "5"]], data: data) == true)

            // Less than
            #expect(try evaluator.evaluate(["<": [["var": "count"], "10"]], data: data) == true)

            // Less or equal
            #expect(try evaluator.evaluate(["<=": [["var": "count"], "5"]], data: data) == true)

            // String contains
            #expect(try evaluator.evaluate(["in": ["te", ["var": "name"]]], data: data) == true)

            // Array contains
            #expect(try evaluator.evaluate(["in": ["b", ["var": "items"]]], data: data) == true)
        }

        @Test("Division and modulo by zero - graceful degradation")
        func testDivisionByZero() throws {
            // Division by zero returns infinity
            let e1: [String: Any] = ["/": [10, 0]]
            let result1 = try evaluator.evaluateRaw(e1, data: [:]) as! Double
            #expect(result1.isInfinite)

            // Modulo by zero returns 0 (matches Android behavior)
            let e2: [String: Any] = ["%": [10, 0]]
            let result2 = try evaluator.evaluateRaw(e2, data: [:]) as! Double
            #expect(result2 == 0.0)

            // These shouldn't crash subsequent comparisons
            let e3: [String: Any] = [">": [["/": [10, 0]], "100"]]
            #expect(try evaluator.evaluate(e3, data: [:]) == true)  // inf > 100
        }

        @Test("Regression: Native Swift Bool still works")
        func testNativeSwiftBool() throws {
            // Native Swift Bool (not from JSONSerialization)
            let data: [String: Any] = ["flag": true]  // Swift.Bool

            let e1: [String: Any] = ["==": [["var": "flag"], "true"]]
            #expect(try evaluator.evaluate(e1, data: data) == true)

            let e2: [String: Any] = ["==": [["var": "flag"], "1"]]
            #expect(try evaluator.evaluate(e2, data: data) == true)
        }

        @Test("Regression: Version comparison still works")
        func testVersionComparison() throws {
            let data: [String: Any] = ["version": "5.10.0"]

            let e1: [String: Any] = [">": [["var": "version"], "5.2.0"]]
            #expect(try evaluator.evaluate(e1, data: data) == true)
        }
    }
}
