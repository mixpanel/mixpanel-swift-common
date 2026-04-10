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
Full JSONLogic implementation with semantic version comparison support.

```swift
let evaluator = JSONLogicEvaluator()
let result = try evaluator.evaluate(
    [">":[["var":"version"], "5.2.0"]],
    data: ["version": "5.10.0"]
) // Returns true
```

Supports semantic version strings (e.g., "5.10.0" > "5.2.0").

## Installation

This package is intended for use by Mixpanel SDK developers.

```swift
dependencies: [
    .package(url: "https://github.com/mixpanel/mixpanel-swift-common.git", from: "1.0.0")
]
```


## License

Copyright © 2026 Mixpanel. All rights reserved.
