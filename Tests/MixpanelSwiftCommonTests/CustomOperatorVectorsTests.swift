//
//  CustomOperatorVectorsTests.swift
//  MixpanelSwiftCommon
//
//  Runs the custom-operator golden vectors against the comparison helpers this module provides.
//
//  The vectors are the cross-SDK contract; the canonical copy and its README live in the analytics
//  monorepo. Each case is a `[subject, operator, target, expected]` row. The SDKs reach these
//  helpers through a JSONLogic engine, but the helpers themselves carry no JSONLogic type, so the
//  row is applied directly here. That keeps the module covered by the same cases its consumers run,
//  without tying it to a particular engine.
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
}
