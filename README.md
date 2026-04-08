# mixpanel-swift-common
Shared common functionality for Mixpanel iOS SDKs.

## Components

### Logger
A thread-safe logging system with explicit initialization.

**Important:** Logger must be initialized before use:

```swift
import MixpanelSwiftCommon

// In your SDK initialization
MixpanelLogger.initialize() // Uses build-appropriate defaults

// Then log anywhere
MixpanelLogger.debug("Debug info")
MixpanelLogger.error("Error occurred")
```

**Features:**
- Explicit initialization (required)
- Build-aware defaults (DEBUG vs RELEASE)
- Multi-SDK support with level union
- Thread-safe operations
- Extensible with custom loggers

[See full Logger documentation →](Sources/MixpanelSwiftCommon/Logging/README.md)

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

## Usage in SDKs

### mixpanel-swift

```swift
public class Mixpanel {
    public init(...) {
        MixpanelLogger.initialize() // Enable logging
        // ... rest of initialization
    }
}
```

### session-replay

```swift
public class MixpanelSessionReplay {
    public init(...) {
        MixpanelLogger.initialize() // Enable logging
        // ... rest of initialization
    }
}
```

### Multiple SDKs

When multiple SDKs use this library, each can call `MixpanelLogger.initialize()` independently.
Log levels will be unioned (most permissive wins).

## License

Copyright © 2026 Mixpanel. All rights reserved.
