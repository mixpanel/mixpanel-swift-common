//  Minimal JSONLogicEvaluator Tests - Only supported operators
import Testing
import Foundation
@testable import MixpanelSwiftCommon

@Suite("JSONLogicEvaluator Tests")
struct JSONLogicEvaluatorTests {
    let evaluator = JSONLogicEvaluator()

    // MARK: - Strict Equality (===, !==)
    
    @Suite("Strict Equality")
    struct StrictEqualityTests {
        let evaluator = JSONLogicEvaluator()
        
        @Test("=== with same values")
        func testStrictEqualsSame() throws {
            #expect(try evaluator.evaluate(["===": [5, 5]], data: [:]) == true)
            #expect(try evaluator.evaluate(["===": ["hello", "hello"]], data: [:]) == true)
            #expect(try evaluator.evaluate(["===": [true, true]], data: [:]) == true)
        }
        
        @Test("=== rejects different types")
        func testStrictEqualsDifferentTypes() throws {
            #expect(try evaluator.evaluate(["===": [5, "5"]], data: [:]) == false)
            #expect(try evaluator.evaluate(["===": [true, 1]], data: [:]) == false)
            #expect(try evaluator.evaluate(["===": [false, 0]], data: [:]) == false)
        }
        
        @Test("!== (is not)")
        func testStrictInequality() throws {
            #expect(try evaluator.evaluate(["!==": [5, 3]], data: [:]) == true)
            #expect(try evaluator.evaluate(["!==": [5, 5]], data: [:]) == false)
            #expect(try evaluator.evaluate(["!==": [5, "5"]], data: [:]) == true)
        }

        @Test("=== with floating point numbers")
        func testStrictEqualsFloatingPoint() throws {
            #expect(try evaluator.evaluate(["===": [3.14, 3.14]], data: [:]) == true)
            #expect(try evaluator.evaluate(["===": [3.14, 3.140]], data: [:]) == true)
            #expect(try evaluator.evaluate(["===": [3.14, 3.15]], data: [:]) == false)
            #expect(try evaluator.evaluate(["===": [3.14, "3.14"]], data: [:]) == false)
            #expect(try evaluator.evaluate(["===": [0.0, 0]], data: [:]) == true)
            #expect(try evaluator.evaluate(["===": [-1.5, -1.5]], data: [:]) == true)
        }

        @Test("!== with floating point numbers")
        func testStrictInequalityFloatingPoint() throws {
            #expect(try evaluator.evaluate(["!==": [3.14, 3.15]], data: [:]) == true)
            #expect(try evaluator.evaluate(["!==": [3.14, 3.14]], data: [:]) == false)
            #expect(try evaluator.evaluate(["!==": [3.14, "3.14"]], data: [:]) == true)
            #expect(try evaluator.evaluate(["!==": [0.0, 0]], data: [:]) == false)
            #expect(try evaluator.evaluate(["!==": [-2.5, -2.6]], data: [:]) == true)
        }
    }
    
    // MARK: - Comparison Operators (>, >=, <, <=)
    
    @Suite("Comparison Operators")
    struct ComparisonTests {
        let evaluator = JSONLogicEvaluator()
        
        @Test("Greater than (>)")
        func testGreaterThan() throws {
            #expect(try evaluator.evaluate([">": [10, 5]], data: [:]) == true)
            #expect(try evaluator.evaluate([">": [5, 10]], data: [:]) == false)
            #expect(try evaluator.evaluate([">": [5, 5]], data: [:]) == false)
            
        }
        
        @Test("Greater or equal (>=)")
        func testGreaterOrEqual() throws {
            #expect(try evaluator.evaluate([">=": [10, 5]], data: [:]) == true)
            #expect(try evaluator.evaluate([">=": [5, 5]], data: [:]) == true)
            #expect(try evaluator.evaluate([">=": [3, 5]], data: [:]) == false)
        }
        
        @Test("Less than (<)")
        func testLessThan() throws {
            #expect(try evaluator.evaluate(["<": [5, 10]], data: [:]) == true)
            #expect(try evaluator.evaluate(["<": [10, 5]], data: [:]) == false)
            #expect(try evaluator.evaluate(["<": [5, 5]], data: [:]) == false)
        }
        
        @Test("Less or equal (<=)")
        func testLessOrEqual() throws {
            #expect(try evaluator.evaluate(["<=": [5, 10]], data: [:]) == true)
            #expect(try evaluator.evaluate(["<=": [5, 5]], data: [:]) == true)
            #expect(try evaluator.evaluate(["<=": [10, 5]], data: [:]) == false)
        }
        
        @Test("Greater/less or equal rejects type coercion")
        func testGreaterOrEqualStrict() throws {
            #expect(try evaluator.evaluate([">=": [5, "5"]], data: [:]) == false)
            #expect(try evaluator.evaluate(["<=": ["5", 5]], data: [:]) == false)
        }

        @Test("String comparison (lexicographic)")
        func testStringComparison() throws {
            #expect(try evaluator.evaluate([">": ["b", "a"]], data: [:]) == true)
            #expect(try evaluator.evaluate(["<": ["a", "b"]], data: [:]) == true)
            #expect(try evaluator.evaluate([">=": ["b", "b"]], data: [:]) == true)
            #expect(try evaluator.evaluate(["<=": ["a", "a"]], data: [:]) == true)
        }

        @Test("Greater than (>) with floating point")
        func testGreaterThanFloatingPoint() throws {
            #expect(try evaluator.evaluate([">": [3.14, 2.5]], data: [:]) == true)
            #expect(try evaluator.evaluate([">": [2.5, 3.14]], data: [:]) == false)
            #expect(try evaluator.evaluate([">": [3.14, 3.14]], data: [:]) == false)
            #expect(try evaluator.evaluate([">": [0.1, 0.01]], data: [:]) == true)
            #expect(try evaluator.evaluate([">": [-1.5, -2.5]], data: [:]) == true)
            #expect(try evaluator.evaluate([">": [-2.5, -1.5]], data: [:]) == false)
        }

        @Test("Greater or equal (>=) with floating point")
        func testGreaterOrEqualFloatingPoint() throws {
            #expect(try evaluator.evaluate([">=": [3.14, 2.5]], data: [:]) == true)
            #expect(try evaluator.evaluate([">=": [3.14, 3.14]], data: [:]) == true)
            #expect(try evaluator.evaluate([">=": [2.5, 3.14]], data: [:]) == false)
            #expect(try evaluator.evaluate([">=": [-1.5, -1.5]], data: [:]) == true)
            #expect(try evaluator.evaluate([">=": [0.0, 0]], data: [:]) == true)
        }

        @Test("Less than (<) with floating point")
        func testLessThanFloatingPoint() throws {
            #expect(try evaluator.evaluate(["<": [2.5, 3.14]], data: [:]) == true)
            #expect(try evaluator.evaluate(["<": [3.14, 2.5]], data: [:]) == false)
            #expect(try evaluator.evaluate(["<": [3.14, 3.14]], data: [:]) == false)
            #expect(try evaluator.evaluate(["<": [-2.5, -1.5]], data: [:]) == true)
            #expect(try evaluator.evaluate(["<": [0.01, 0.1]], data: [:]) == true)
        }

        @Test("Less or equal (<=) with floating point")
        func testLessOrEqualFloatingPoint() throws {
            #expect(try evaluator.evaluate(["<=": [2.5, 3.14]], data: [:]) == true)
            #expect(try evaluator.evaluate(["<=": [3.14, 3.14]], data: [:]) == true)
            #expect(try evaluator.evaluate(["<=": [3.14, 2.5]], data: [:]) == false)
            #expect(try evaluator.evaluate(["<=": [-1.5, -1.5]], data: [:]) == true)
            #expect(try evaluator.evaluate(["<=": [0, 0.0]], data: [:]) == true)
        }
    }
    
    // MARK: - Logical Operators (and, or)
    
    @Suite("Logical Operators")
    struct LogicalTests {
        let evaluator = JSONLogicEvaluator()
        
        @Test("AND operator")
        func testAnd() throws {
            let expr1: [String: Any] = ["and": [true, true, true]]
            #expect(try evaluator.evaluate(expr1, data: [:]) == true)
            
            let expr2: [String: Any] = ["and": [true, false, true]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)
        }
        
        @Test("OR operator")
        func testOr() throws {
            let expr1: [String: Any] = ["or": [false, true, false]]
            #expect(try evaluator.evaluate(expr1, data: [:]) == true)

            let expr2: [String: Any] = ["or": [false, false, false]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)
        }
    }
    
    // MARK: - IN Operator (array membership + substring)
    
    @Suite("IN Operator")
    struct InOperatorTests {
        let evaluator = JSONLogicEvaluator()
        
        @Test("Array membership")
        func testArrayMembership() throws {
            let data: [String: Any] = ["$city": "Louisville"]
            let expr: [String: Any] = ["in": [["var": "$city"], ["Louisville", "Miami"]]]
            #expect(try evaluator.evaluate(expr, data: data) == true)
            
            let data2: [String: Any] = ["$city": "Boston"]
            #expect(try evaluator.evaluate(expr, data: data2) == false)
        }
        
        @Test("Substring check")
        func testSubstring() throws {
            let data: [String: Any] = ["$address": "11 street, Louisville"]
            let expr: [String: Any] = ["in": ["Louisville", ["var": "$address"]]]
            #expect(try evaluator.evaluate(expr, data: data) == true)

            let expr2: [String: Any] = ["in": ["New york", ["var": "$address"]]]
            #expect(try evaluator.evaluate(expr2, data: data) == false)
        }

        @Test("IN with type mismatch (strict matching)")
        func testInTypeMismatch() throws {
            // Number 5 should NOT match string "5" (strict equality)
            let expr: [String: Any] = ["in": [5, ["5", "10"]]]
            #expect(try evaluator.evaluate(expr, data: [:]) == false)

            // String "5" should NOT match number 5
            let expr2: [String: Any] = ["in": ["5", [5, 10]]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)
        }
    }
    
    // MARK: - VAR Operator (variable resolution)
    
    @Suite("VAR Operator")
    struct VarOperatorTests {
        let evaluator = JSONLogicEvaluator()
        
        @Test("Simple variable access")
        func testSimpleVar() throws {
            let data: [String: Any] = ["name": "John", "age": 30]
            let result = try evaluator.evaluateRaw(["var": "name"], data: data)
            #expect(result as? String == "John")
        }
        
        @Test("Nested property access")
        func testNestedVar() throws {
            let data: [String: Any] = ["user": ["name": "John", "age": 30]]
            let result = try evaluator.evaluateRaw(["var": "user.name"], data: data)
            #expect(result as? String == "John")
        }
        
        @Test("Variable with default value")
        func testVarWithDefault() throws {
            let data: [String: Any] = ["name": "John"]
            let result = try evaluator.evaluateRaw(["var": ["missing", "default"]], data: data)
            #expect(result as? String == "default")
        }
    }
    
    // MARK: - Combined Examples
    
    @Suite("Real-World Examples")
    struct RealWorldTests {
        let evaluator = JSONLogicEvaluator()

        // MARK: - Basic Combinations (3-4 operators)

        @Test("City targeting with AND")
        func testCityTargeting() throws {
            let data: [String: Any] = [
                "$city": "Louisville",
                "$age": 25
            ]
            let expr: [String: Any] = [
                "and": [
                    ["in": [["var": "$city"], ["Louisville", "Miami"]]],
                    [">=": [["var": "$age"], 21]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }
        
        @Test("Substring and comparison")
        func testSubstringAndComparison() throws {
            let data: [String: Any] = [
                "$email": "user@gmail.com",
                "$score": 85
            ]
            let expr: [String: Any] = [
                "and": [
                    ["in": ["gmail", ["var": "$email"]]],
                    [">": [["var": "$score"], 80]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("Account tier check with OR")
        func testAccountTierWithOr() throws {
            let data: [String: Any] = [
                "$tier": "premium",
                "$credits": 100
            ]
            let expr: [String: Any] = [
                "and": [
                    ["or": [
                        ["===": [["var": "$tier"], "premium"]],
                        ["===": [["var": "$tier"], "enterprise"]]
                    ]],
                    [">": [["var": "$credits"], 0]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("Trial user eligibility check")
        func testTrialEligibility() throws {
            let data: [String: Any] = [
                "$status": "active",
                "$trial_days": 15
            ]
            let expr: [String: Any] = [
                "and": [
                    ["!==": [["var": "$status"], "banned"]],
                    ["<": [["var": "$trial_days"], 30]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("Discount eligibility")
        func testDiscountEligibility() throws {
            let data: [String: Any] = [
                "$age": 17,
                "$is_student": false
            ]
            let expr: [String: Any] = [
                "or": [
                    ["<=": [["var": "$age"], 18]],
                    ["===": [["var": "$is_student"], true]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }
        
        @Test("Range eligibility")
        func testRange() throws {
            let data: [String: Any] = [
                "$score": 17,
            ]
            let expr: [String: Any] = [
                "or": [
                    [">=": [["var": "$score"], 80]],
                    ["<=": [["var": "$score"], 90]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }
        
        @Test("Missing values")
        func testMissingValue() throws {
            let data: [String: Any] = [
                "$score": 17,
            ]
            let expr: [String: Any] = [
                "or": [
                    [">=": [["var": "$score"], 80]],
                    ["===": [["var": "$player_type"], 90]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == false)
        }

        @Test("Feature flag with default value")
        func testFeatureFlagWithDefault() throws {
            let data: [String: Any] = [
                "$user_id": 12345
            ]
            // Feature flag is missing, should use default "disabled"
            let expr: [String: Any] = [
                "and": [
                    ["===": [["var": ["$feature_flag", "disabled"]], "enabled"]],
                    [">": [["var": "$user_id"], 0]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == false)
        }

        // MARK: - Advanced Combinations (5+ operators)

        @Test("Complex targeting rule")
        func testComplexTargeting() throws {
            let data: [String: Any] = [
                "$tier": "premium",
                "$city": "SF",
                "$engagement_score": 85
            ]
            let expr: [String: Any] = [
                "or": [
                    ["===": [["var": "$tier"], "premium"]],
                    ["and": [
                        ["in": [["var": "$city"], ["SF", "NYC", "LA"]]],
                        [">=": [["var": "$engagement_score"], 80]]
                    ]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }
    }
}
