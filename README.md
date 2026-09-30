# mixpanel-swift-common
Shared common functionality for Mixpanel iOS SDKs.

## Requirements

| Platform | Minimum version |
|---|---|
| iOS | 15.0 |
| tvOS | 15.0 |
| macOS | 12.0 |
| watchOS | 9.0 |

Swift tools version 5.7 or later. These floors match what Xcode 27 requires for every build target, including CocoaPods pod targets. Need iOS 12–14? Stay on the 1.x line with Xcode 26.

## Components

### MixpanelEventBridge
Event bridge for multicasting Mixpanel events to external consumers via AsyncStream.

```swift
let bridge = MixpanelEventBridge.shared
let stream = bridge.eventStream()

// Consume events
for await event in stream {
    print("Event: \(event.eventName)")
}
```

### MixpanelJSONLogicRule
Full jsonlogic.com rule evaluation, backed by a vendored copy of
[json-logic-swift](https://github.com/advantagefse/json-logic-swift) 1.2.4 (see
[THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md)). Supports every standard operator, including type
coercion, and lets the caller register custom operators. Parse a rule once and evaluate it as often as
needed; a parsed rule is immutable and safe to evaluate from any thread.

```swift
let rule = try MixpanelJSONLogicRule(
    #"{"and": [{"===": [{"var": "plan"}, "pro"]}, {">": [{"var": "seats"}, 5]}]}"#
)
try rule.evaluate(data: #"{"plan": "pro", "seats": 12}"#)  // true

// Custom operators receive their evaluated arguments as `MixpanelJSON`
let operators: [String: MixpanelJSONLogicRule.CustomOperator] = [
    "semver_compare": { args in
        guard let values = args?.array, values.count == 3,
              let actual = values[0].string, let symbol = values[1].string, let target = values[2].string,
              let cmp = SemanticVersion.compare(actual, target)
        else { return .bool(false) }
        return .bool(symbol == ">=" ? cmp >= 0 : cmp == 0)
    }
]
try MixpanelJSONLogicRule.evaluate(
    #"{"semver_compare": [{"var": "$app_version"}, ">=", "2.1.0"]}"#,
    data: #"{"$app_version": "2.3.0"}"#,
    customOperators: operators
)  // true
```

A rule must evaluate to a boolean; anything else throws `MixpanelJSONLogicRule.EvaluationError.resultNotBoolean`.
Unknown operators throw `unsupportedOperator`, malformed rules `invalidRule`, malformed data `invalidData`.

### JSONLogicEvaluator (strict 10-operator subset)
A separate, deliberately strict evaluator for targeting and filtering. Unlike `MixpanelJSONLogicRule`, it
performs no type coercion and throws on type mismatches.

Supports 10 operators: `===`, `!==`, `<`, `<=`, `>`, `>=`, `in`, `and`, `or`, `var`.

See [JSONLogic Operators.md](docs/JSONLogic%20Operators.md) for complete documentation and examples.

```swift
let evaluator = JSONLogicEvaluator()
let result = try evaluator.evaluate(
    [">": [["var": "score"], 50]],
    data: ["score": 75]
) // Returns true
```

## Installation

This package is intended for use by Mixpanel SDK developers.

```swift
dependencies: [
    .package(url: "https://github.com/mixpanel/mixpanel-swift-common.git", from: "2.0.0")
]
```


## Third-party code

This package bundles json-logic-swift under the MIT license. See
[THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md) for the notice and the list of local modifications.

## License

Copyright © 2026 Mixpanel. All rights reserved.
