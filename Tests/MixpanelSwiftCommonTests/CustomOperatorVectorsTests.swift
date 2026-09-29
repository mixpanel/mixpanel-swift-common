//
//  CustomOperatorVectorsTests.swift
//  MixpanelSwiftCommon
//
//  Runs the custom-operator golden vectors against the comparison helpers this module provides.
//
//  The vectors are the cross-SDK contract; the canonical copy and its README live in the analytics
//  monorepo. Each case is a `[subject, operator, target, expected]` row.
//
//  Each vector runs twice: once directly against the comparison helpers (which carry no JSONLogic
//  type), and once as a real rule through `MixpanelJSONLogicRule` with `semver_compare` / `datetime_compare`
//  registered as custom operators. The operator implementations below mirror the ones mixpanel-swift
//  ships, so this is the path a feature-flag property filter takes at runtime.
//

import Foundation
import Testing

@testable import MixpanelSwiftCommon

@Suite("Custom operator golden vectors")
struct CustomOperatorVectorsTests {

    private static func comparatorMatches(_ cmp: Int64, _ symbol: String) -> Bool {
        switch symbol {
            case "===":
                return cmp == 0
            case "!==":
                return cmp != 0
            case "<":
                return cmp < 0
            case "<=":
                return cmp <= 0
            case ">":
                return cmp > 0
            case ">=":
                return cmp >= 0
            default:
                return false
        }
    }

    /// One golden-vector row. A nil subject means the property is not set.
    private struct Vector {
        let name: String
        let subject: Any?
        let symbol: String
        let target: Any
        let want: Bool
    }

    /// Reads a golden-vector file. String entries are headings, array entries are cases.
    private static func loadVectors(_ operatorName: String) throws -> [Vector] {
        guard
            let url = Bundle.module.url(
                forResource: "\(operatorName)_compare_tests",
                withExtension: "json",
                subdirectory: "test-data"
            )
        else {
            throw VectorError.missingFile(operatorName)
        }

        guard let entries = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [Any] else {
            throw VectorError.malformed(operatorName)
        }

        var section = ""
        var vectors: [Vector] = []
        for (index, entry) in entries.enumerated() {
            if let heading = entry as? String {
                section = heading
                continue
            }
            guard
                let row = entry as? [Any], row.count == 4,
                let symbol = row[1] as? String,
                let want = row[3] as? Bool
            else {
                throw VectorError.malformed(operatorName)
            }
            // JSONSerialization decodes JSON null to NSNull rather than nil, so an unset property
            // has to be spelled out here.
            let subject = row[0] is NSNull ? nil : row[0]
            let name = "\(index) \(section): \(subject ?? "unset") \(symbol) \(row[2])"
            vectors.append(Vector(name: name, subject: subject, symbol: symbol, target: row[2], want: want))
        }
        return vectors
    }

    private enum VectorError: Error {
        case missingFile(String)
        case malformed(String)
    }

    private static func semverCompare(_ vector: Vector) -> Bool {
        guard
            let actual = vector.subject as? String,
            let target = vector.target as? String,
            let cmp = SemanticVersion.compare(actual, target)
        else {
            return false
        }
        return comparatorMatches(cmp, vector.symbol)
    }

    private static func datetimeCompare(_ vector: Vector) -> Bool {
        guard
            let raw = vector.subject as? String,
            let actual = Rfc3339.toUnixSeconds(raw),
            let millis = vector.target as? NSNumber,
            let target = Rfc3339.epochMillisToUnixSeconds(millis.doubleValue)
        else {
            return false
        }
        // A difference of whole seconds cannot overflow: both sides are bounded by the epoch-ms range.
        return comparatorMatches(actual - target, vector.symbol)
    }

    @Test("semver_compare golden vectors")
    func semverVectors() throws {
        for vector in try Self.loadVectors("semver") {
            #expect(Self.semverCompare(vector) == vector.want, "\(vector.name)")
        }
    }

    @Test("datetime_compare golden vectors")
    func datetimeVectors() throws {
        for vector in try Self.loadVectors("datetime") {
            #expect(Self.datetimeCompare(vector) == vector.want, "\(vector.name)")
        }
    }

    // MARK: - Through the JSONLogic engine

    /// `[actual, symbol, target]`, the operand shape both custom operators expect.
    private static func operands(_ json: MixpanelJSON?) -> (actual: MixpanelJSON, symbol: String, target: MixpanelJSON)?
    {
        guard case .array(let values)? = json, values.count == 3, let symbol = values[1].string else {
            return nil
        }
        return (values[0], symbol, values[2])
    }

    /// Mirrors mixpanel-swift's `semver_compare` operator.
    private static let semverOperator: MixpanelJSONLogicRule.CustomOperator = { json in
        guard
            let (actual, symbol, target) = operands(json),
            let actualStr = actual.string, let targetStr = target.string,
            let cmp = SemanticVersion.compare(actualStr, targetStr)
        else {
            return .bool(false)
        }
        return .bool(comparatorMatches(cmp, symbol))
    }

    /// Mirrors mixpanel-swift's `datetime_compare` operator: RFC 3339 actual, epoch-millisecond target.
    private static let datetimeOperator: MixpanelJSONLogicRule.CustomOperator = { json in
        guard let (actual, symbol, target) = operands(json), let raw = actual.string,
            let actualSec = Rfc3339.toUnixSeconds(raw)
        else {
            return .bool(false)
        }
        let targetSec: Int64?
        switch target {
            case .int(let millis):
                targetSec = Rfc3339.epochMillisToUnixSeconds(millis)
            case .double(let millis):
                targetSec = Rfc3339.epochMillisToUnixSeconds(millis)
            default:
                targetSec = nil
        }
        guard let targetSec else { return .bool(false) }
        return .bool(comparatorMatches(actualSec - targetSec, symbol))
    }

    private static let engineOperators: [String: MixpanelJSONLogicRule.CustomOperator] = [
        "semver_compare": semverOperator,
        "datetime_compare": datetimeOperator,
    ]

    /// Builds `{"<op>": [{"var": "subject"}, symbol, target]}` and `{"subject": ...}` the way a
    /// feature-flag property filter is evaluated, then runs it through the engine.
    private static func evaluateThroughEngine(_ operatorName: String, _ vector: Vector) throws -> Bool {
        let rule: [String: Any] = [operatorName: [["var": "subject"], vector.symbol, vector.target]]
        let data: [String: Any] = vector.subject.map { ["subject": $0] } ?? [:]
        let ruleString = String(decoding: try JSONSerialization.data(withJSONObject: rule), as: UTF8.self)
        let dataString = String(decoding: try JSONSerialization.data(withJSONObject: data), as: UTF8.self)
        return try MixpanelJSONLogicRule.evaluate(ruleString, data: dataString, customOperators: engineOperators)
    }

    @Test("semver_compare golden vectors through MixpanelJSONLogicRule")
    func semverVectorsThroughEngine() throws {
        for vector in try Self.loadVectors("semver") {
            #expect(try Self.evaluateThroughEngine("semver_compare", vector) == vector.want, "\(vector.name)")
        }
    }

    @Test("datetime_compare golden vectors through MixpanelJSONLogicRule")
    func datetimeVectorsThroughEngine() throws {
        for vector in try Self.loadVectors("datetime") {
            #expect(try Self.evaluateThroughEngine("datetime_compare", vector) == vector.want, "\(vector.name)")
        }
    }
}
