# Third-party licenses

MixpanelSwiftCommon is licensed under the Apache License 2.0 (see `LICENSE`). It bundles the
third-party code listed below, which remains under its original license.

## json-logic-swift

- Upstream: https://github.com/advantagefse/json-logic-swift
- Version vendored: tag `1.2.4`, commit `9088eed1b26937fe13d248aa24d7632a51be28e2` (December 31, 2023)
- Location: `Sources/MixpanelSwiftCommon/Vendor/JSONLogicSwift/` (sources) and
  `Tests/MixpanelSwiftCommonTests/Vendored/JSONLogicSwift/` (upstream test suite)
- Upstream modules `JSON` and `jsonlogic` are folded into the `MixpanelSwiftCommon` module so that no
  package in a consumer's dependency graph has to vend a module named `JSON`.

### Local modifications

Upstream is unmaintained, so this is a vendored copy rather than a tracked fork. Changes from the
upstream files at the commit above:

- All declarations were made `internal`. The public entry points are `MixpanelJSONLogicRule` and
  `MixpanelJSON` in `Sources/MixpanelSwiftCommon/Utils/MixpanelJSONLogicRule.swift`, written by Mixpanel.
- `import JSON` statements were removed because the type now lives in the same module.
- `JSON.swift`: the redundant `nil` pattern in `init(_ json: Any)` was removed; matching `nil` against a
  non-optional `Any` is an error in the Swift 6 language mode.
- `JsonLogic.swift`: the debug `print` on the failed result-cast path and the dead
  `#if compiler(>=5) && swift(<5)` branch (an SR-14356 workaround) were removed.
- `Parser.swift`: the `log` operator no longer prints to the console. The value is still converted so
  error propagation matches upstream.
- The upstream `jsonlogic-cli` executable, podspecs, example app and CI configuration were not copied.
- Test files: `import` statements were switched to `@testable import MixpanelSwiftCommon`, and
  `XCTestManifests.swift` / `LinuxMain.swift` were not copied.
- Every vendored file (sources and tests) carries the full MIT license text and the upstream provenance
  (path, tag, commit) in its header.
- Files were reformatted with the repository's `.swift-format` configuration.

### License (MIT)

```
MIT License

Copyright (c) 2019 Advantage FSE

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
