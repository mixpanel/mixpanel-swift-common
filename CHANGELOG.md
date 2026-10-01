# Changelog

All notable changes to this project will be documented in this file.


## [2.0.0](https://github.com/mixpanel/mixpanel-swift-common/tree/2.0.0) (2026-10-01)

### Features

- Vendor json-logic-swift into MixpanelSwiftCommon (#18) ([#18](https://github.com/mixpanel/mixpanel-swift-common/pull/18))

### ⚠️ Breaking Changes 

- **Raised minimum deployment targets** to support Xcode 27, which rejects any build target (including CocoaPods pod targets) below these versions ([#19](https://github.com/mixpanel/mixpanel-swift-common/pull/19)):

  | Platform | 1.x    | 2.0.0 |
  |----------|--------|-------|
  | iOS      | 12.0   | 15.0  |
  | tvOS     | 12.0   | 15.0  |
  | macOS    | 10.13  | 12.0  |
  | watchOS  | 4.0    | 9.0   |

- **Minimum Swift tools version is now 5.7** (previously 5.5).

[Full Changelog](https://github.com/mixpanel/mixpanel-swift-common/commits/2.0.0)

## [1.1.0](https://github.com/mixpanel/mixpanel-swift-common/tree/1.1.0) (2026-09-01)

### Fixes

- restore prepare release workflow parsing (#16) ([#16](https://github.com/mixpanel/mixpanel-swift-common/pull/16))

[Full Changelog](https://github.com/mixpanel/mixpanel-swift-common/commits/1.1.0)
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
