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
        
        @Test("=== throws for different types")
        func testStrictEqualsThrowsForDifferentTypes() throws {
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["===": [5, "5"]], data: [:])
            }
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["===": [true, 1]], data: [:])
            }
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["===": [false, 0]], data: [:])
            }
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["===": [NSNull(), 0]], data: [:])
            }
        }
        
        @Test("!== (is not)")
        func testStrictInequality() throws {
            #expect(try evaluator.evaluate(["!==": [5, 3]], data: [:]) == true)
            #expect(try evaluator.evaluate(["!==": [5, 5]], data: [:]) == false)
            // Different types throw error
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["!==": [5, "5"]], data: [:])
            }
        }

        @Test("=== with floating point numbers")
        func testStrictEqualsFloatingPoint() throws {
            #expect(try evaluator.evaluate(["===": [3.14, 3.14]], data: [:]) == true)
            #expect(try evaluator.evaluate(["===": [3.14, 3.140]], data: [:]) == true)
            #expect(try evaluator.evaluate(["===": [3.14, 3.15]], data: [:]) == false)
            // Number vs string throws error
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["===": [3.14, "3.14"]], data: [:])
            }
            #expect(try evaluator.evaluate(["===": [0.0, 0]], data: [:]) == true)
            #expect(try evaluator.evaluate(["===": [-1.5, -1.5]], data: [:]) == true)
        }

        @Test("!== with floating point numbers")
        func testStrictInequalityFloatingPoint() throws {
            #expect(try evaluator.evaluate(["!==": [3.14, 3.15]], data: [:]) == true)
            #expect(try evaluator.evaluate(["!==": [3.14, 3.14]], data: [:]) == false)
            // Number vs string throws error
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["!==": [3.14, "3.14"]], data: [:])
            }
            #expect(try evaluator.evaluate(["!==": [0.0, 0]], data: [:]) == false)
            #expect(try evaluator.evaluate(["!==": [-2.5, -2.6]], data: [:]) == true)
        }

        @Test("=== with arrays throws error")
        func testStrictEqualsArraysThrows() throws {
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["===": [[], []]], data: [:])
            }
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["===": [[1], [1]]], data: [:])
            }
        }

        @Test("!== with arrays throws error")
        func testStrictNotEqualsArraysThrows() throws {
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["!==": [[], []]], data: [:])
            }
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
        
        @Test("Comparison operators reject strings")
        func testComparisonRejectsStrings() throws {
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate([">": ["b", "a"]], data: [:])
            }
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["<": ["a", "b"]], data: [:])
            }
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate([">=": ["b", "b"]], data: [:])
            }
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["<=": ["a", "a"]], data: [:])
            }
        }

        @Test("Comparison operators reject booleans")
        func testComparisonRejectsBooleans() throws {
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate([">": [true, false]], data: [:])
            }
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["<": [false, true]], data: [:])
            }
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate([">=": [true, true]], data: [:])
            }
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["<=": [false, false]], data: [:])
            }
        }

        @Test("Comparison operators reject mixed types")
        func testComparisonRejectsMixedTypes() throws {
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate([">=": [5, "5"]], data: [:])
            }
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["<=": ["5", 5]], data: [:])
            }
        }

        @Test("Comparison operators reject null")
        func testComparisonRejectsNull() throws {
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate([">": [NSNull(), 5]], data: [:])
            }
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["<": [5, NSNull()]], data: [:])
            }
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate([">=": [NSNull(), 0]], data: [:])
            }
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["<=": [0, NSNull()]], data: [:])
            }
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

        @Test("Comparison operators reject booleans from var (NSNumber bridging)")
        func testComparisonRejectsBoolsFromVar() throws {
            // NSNumber bridging could let booleans pass as numbers - must be prevented
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate([">": [["var": "active"], 0]], data: ["active": true])
            }
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["<": [["var": "enabled"], 1]], data: ["enabled": false])
            }
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate([">=": [["var": "flag"], 0]], data: ["flag": true])
            }
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["<=": [["var": "status"], 1]], data: ["status": false])
            }
        }

        @Test("Comparison operators reject dictionary values")
        func testComparisonRejectsDictionaries() throws {
            // Dictionary from var
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["===": [["var": "obj"], ["a": 1]]], data: ["obj": ["a": 1]])
            }
            // Multi-key dictionary literals
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["===": [["x": 1, "y": 2], ["x": 1, "y": 2]]], data: [:])
            }
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

        @Test("Empty AND throws error")
        func testEmptyAndThrows() throws {
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["and": []], data: [:])
            }
        }

        @Test("Empty OR throws error")
        func testEmptyOrThrows() throws {
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["or": []], data: [:])
            }
        }

        @Test("AND with boolean expressions")
        func testAndWithBooleanExpressions() throws {
            let expr: [String: Any] = ["and": [["===": [1, 1]], ["===": [2, 2]]]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["and": [["===": [1, 1]], ["===": [1, 2]]]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)
        }

        @Test("OR with boolean expressions")
        func testOrWithBooleanExpressions() throws {
            let expr: [String: Any] = ["or": [["===": [1, 2]], ["===": [2, 2]]]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["or": [["===": [1, 2]], ["===": [2, 3]]]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)
        }

        @Test("AND throws for number literal operand")
        func testAndThrowsForNumberOperand() throws {
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["and": [["===": [1, 1]], 1]], data: [:])
            }
        }

        @Test("OR throws for string literal operand")
        func testOrThrowsForStringOperand() throws {
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["or": [["===": [1, 2]], "hello"]], data: [:])
            }
        }

        @Test("AND throws for var returning non-boolean")
        func testAndThrowsForVarNonBoolean() throws {
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["and": [["===": [1, 1]], ["var": "count"]]], data: ["count": 5])
            }
        }

        @Test("OR throws for null operand")
        func testOrThrowsForNullOperand() throws {
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["or": [["===": [1, 2]], NSNull()]], data: [:])
            }
        }

        @Test("AND validates all operands before short-circuit")
        func testAndValidatesAllOperands() throws {
            // Even though first operand is false, should validate second operand
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["and": [false, 5]], data: [:])
            }
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["and": [false, "hello"]], data: [:])
            }
        }

        @Test("OR validates all operands before short-circuit")
        func testOrValidatesAllOperands() throws {
            // Even though first operand is true, should validate second operand
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["or": [true, 5]], data: [:])
            }
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["or": [true, "hello"]], data: [:])
            }
        }

        @Test("AND validates all operands even with multiple non-boolean values")
        func testAndValidatesAllMultiple() throws {
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["and": [false, 1, 2, 3]], data: [:])
            }
        }

        @Test("OR validates all operands even with multiple non-boolean values")
        func testOrValidatesAllMultiple() throws {
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["or": [true, 1, 2, 3]], data: [:])
            }
        }

        @Test("AND rejects numbers from var (NSNumber bridging)")
        func testAndRejectsNumbersFromVar() throws {
            // NSNumber bridging could let numbers pass as Bool - must be prevented
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["and": [["var": "active"], ["===": [1, 1]]]], data: ["active": 1])
            }
        }

        @Test("OR rejects numbers from var (NSNumber bridging)")
        func testOrRejectsNumbersFromVar() throws {
            // NSNumber bridging could let numbers pass as Bool - must be prevented
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["or": [["var": "active"], ["===": [1, 2]]]], data: ["active": 0])
            }
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

        @Test("IN with type mismatch throws error")
        func testInTypeMismatchThrows() throws {
            // Array with numbers throws error (all elements must be strings)
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                let expr: [String: Any] = ["in": ["5", [5, 10]]]
                try evaluator.evaluate(expr, data: [:])
            }

            // String "5" should match string "5"
            let expr2: [String: Any] = ["in": ["5", ["5", "10"]]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)

            // Mixed array throws error
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                let expr3: [String: Any] = ["in": ["a", ["a", 1, "b"]]]
                try evaluator.evaluate(expr3, data: [:])
            }
        }

        @Test("IN operator rejects non-string types")
        func testInRejectsNonStrings() throws {
            // Number should be rejected
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                let expr: [String: Any] = ["in": [5, [1, 2, 3, 5]]]
                try evaluator.evaluate(expr, data: [:])
            }

            // Boolean should be rejected
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                let expr: [String: Any] = ["in": [true, [true, false]]]
                try evaluator.evaluate(expr, data: [:])
            }
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
        @Test("Variable with default value throws error")
        func testVarWithDefaultThrows() throws {
            let data: [String: Any] = ["name": "John"]
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluateRaw(["var": ["missing", "default"]], data: data)
            }
        }

        @Test("Variable with missing key returns null")
        func testVarMissingReturnsNull() throws {
            let data: [String: Any] = ["name": "John"]
            let result = try evaluator.evaluateRaw(["var": "missing"], data: data)
            #expect(result is NSNull)
        }

        @Test("Variable with dot notation throws error")
        func testVarDotNotationThrows() throws {
            // Dot notation is not supported in variable keys
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluateRaw(["var": "user.name"], data: ["username": "John"])
            }

            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluateRaw(["var": "a.b.c"], data: ["a.b.c": 42])
            }

            // Dot at the beginning
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluateRaw(["var": ".prop"], data: ["prop": "value"])
            }

            // Dot at the end
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluateRaw(["var": "prop."], data: ["prop.": "value"])
            }

            // Multiple dots
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluateRaw(["var": "user.profile.name"], data: ["name": "John"])
            }
        }

        @Test("Dot notation in var with expression")
        func testDotNotationInVarExpression() throws {
            // Dot notation in var key that comes from an expression
            let data: [String: Any] = ["key_name": "user.id", "user_id": 123]
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluateRaw(["var": ["var": "key_name"]], data: data)
            }
        }

        @Test("Dot notation in complex expressions")
        func testDotNotationInComplexExpressions() throws {
            // Dot in var used in comparison
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["===": [["var": "user.age"], 25]], data: ["age": 25])
            }

            // Dot in var used in logical operators
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(
                    ["and": [["===": [["var": "prop.name"], "value"]], ["===": [true, true]]]],
                    data: ["prop.name": "value"]
                )
            }
        }

        @Test("Data with dot notation in unused keys is allowed")
        func testUnusedDotNotationAllowed() throws {
            // Data can have keys with dots as long as they're not accessed
            let data: [String: Any] = ["user.name": "John", "age": 25]

            // This should work fine - we're not accessing the "user.name" key
            let result = try evaluator.evaluateRaw(["var": "age"], data: data)
            #expect(result as? Int == 25)

            // Multiple unused dot keys
            let data2: [String: Any] = ["a.b.c": 1, "x.y": 2, "name": "test"]
            let result2 = try evaluator.evaluateRaw(["var": "name"], data: data2)
            #expect(result2 as? String == "test")
        }

        @Test("Variable with numeric string key works")
        func testVarNumericStringKey() throws {
            // Numeric strings like "0", "123" are valid dictionary keys
            let data: [String: Any] = ["0": "zero", "123": "one-two-three"]
            let result1 = try evaluator.evaluateRaw(["var": "0"], data: data)
            #expect(result1 as? String == "zero")

            let result2 = try evaluator.evaluateRaw(["var": "123"], data: data)
            #expect(result2 as? String == "one-two-three")
        }

        @Test("Variable with empty string key throws error")
        func testVarEmptyStringKeyThrows() throws {
            let data: [String: Any] = ["name": "John"]
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluateRaw(["var": ""], data: data)
            }
        }

        @Test("Variable with null argument throws error")
        func testVarNullArgThrows() throws {
            let data: [String: Any] = ["name": "John"]
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluateRaw(["var": NSNull()], data: data)
            }
        }

        @Test("Variable with empty array throws error")
        func testVarEmptyArrayThrows() throws {
            let data: [String: Any] = ["name": "John"]
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluateRaw(["var": []], data: data)
            }
        }

        @Test("Variable that evaluates to null throws error")
        func testVarExpressionEvaluatingToNullThrows() throws {
            let data: [String: Any] = ["missing": NSNull()]
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluateRaw(["var": ["var": "missing"]], data: data)
            }
        }
        
        @Test("Variable with numeric key throws error")
        func testVarNumericKeyThrows() throws {
            let data: [String: Any] = ["name": "john"]
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluateRaw(["var": 22], data: data)
            }
        }

        @Test("Top-level non-boolean expression throws error in evaluate()")
        func testNonBooleanTopLevelThrows() throws {
            let data: [String: Any] = ["name": "Alice"]

            // evaluate() requires boolean result - non-boolean should throw
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(["var": "name"], data: data)
            }

            // evaluateRaw() allows any type - should work
            let result = try evaluator.evaluateRaw(["var": "name"], data: data)
            #expect(result as? String == "Alice")
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
        
        @Test("Missing values throw type mismatch")
        func testMissingValueThrows() throws {
            let data: [String: Any] = [
                "$score": 17,
            ]
            // Missing var returns null, comparing null with number throws error
            let expr: [String: Any] = [
                "or": [
                    [">=": [["var": "$score"], 80]],
                    ["===": [["var": "$player_type"], 90]]
                ]
            ]
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(expr, data: data)
            }
        }

        @Test("Feature flag default values not supported")
        func testFeatureFlagDefaultNotSupported() throws {
            let data: [String: Any] = [
                "$user_id": 12345
            ]
            // Default values not supported, throws error
            let expr: [String: Any] = [
                "and": [
                    ["===": [["var": ["$feature_flag", "disabled"]], "enabled"]],
                    [">": [["var": "$user_id"], 0]]
                ]
            ]
            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(expr, data: data)
            }
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
