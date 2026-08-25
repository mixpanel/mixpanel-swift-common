//
//  Constants.swift
//  MixpanelSwiftCommon
//
//  Copyright © 2024 Mixpanel. All rights reserved.
//

import Foundation

/// Constants for MixpanelSwiftCommon library
public struct MixpanelCommonConstants {
    /// Current library version
    private static let libVersion = "1.0.2"

    /// Library identifier
    private static let mpLib = "swift-common"

    /// Returns the current library version
    public static var currentLibVersion: String {
        return libVersion
    }

    /// Returns the library identifier
    public static var currentMpLib: String {
        return mpLib
    }
}
