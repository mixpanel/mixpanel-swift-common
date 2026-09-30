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

### JSONLogicEvaluator
Essential JSONLogic operators for targeting and filtering.

Supports 10 operators: `===`, `!==`, `<`, `<=`, `>`, `>=`, `in`, `and`, `or`, `var`.

See [OPERATORS.md](docs/JSONLogic%20Operators.md) for complete documentation and examples.

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


## License

Copyright © 2026 Mixpanel. All rights reserved.
