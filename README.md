# mixpanel-swift-common
Shared common functionality for Mixpanel iOS SDKs.

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

See [OPERATORS.md](Sources/MixpanelSwiftCommon/Utils/JSONLogic%20Operators.md) for complete documentation and examples.

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
    .package(url: "https://github.com/mixpanel/mixpanel-swift-common.git", from: "1.0.0")
]
```


## License

Copyright © 2026 Mixpanel. All rights reserved.
