//
//  MixpanelIdentity.swift
//  MixpanelSwiftCommon
//
//  Copyright © 2026 Mixpanel. All rights reserved.
//

import Foundation

/// Names who events, profile updates and replays belong to, shared by the Mixpanel Swift SDKs.
///
/// Analytics owns the device id, so it reports a complete identity through
/// `MixpanelInstance.identity` and takes only ``userId`` and ``companyId`` when identifying.
/// Session Replay owns none of these values and takes the identity analytics reports, so its
/// recordings resolve to the same user as the app's events:
///
/// ```swift
/// mixpanel.identify(identity: MixpanelIdentity(userId: "user_123", companyId: "acme"))
/// ```
///
/// On a project that uses hierarchical groups, Mixpanel builds the user's distinct id from
/// `$company_id` and `$user_id`, so the company is part of the user's identity: the same user id
/// in two companies is two users. Other projects ignore ``companyId``.
///
/// Every value is optional so that a missing id is reported by the SDK it is passed to rather
/// than rejected here. Instances are immutable and compare by value.
public struct MixpanelIdentity: Equatable, Hashable, CustomStringConvertible {
    /// The user's id. On a hierarchical groups project it only needs to be unique within the
    /// company.
    public let userId: String?

    /// The id of the user's top-level company, on a hierarchical groups project.
    public let companyId: String?

    /// The device id analytics assigned. Events and replays that carry it are attributed to the
    /// device until the user is known, then follow the user.
    public let deviceId: String?

    /// Creates an identity for a user and, on a hierarchical groups project, their company.
    ///
    /// - parameter userId: the user's id
    /// - parameter companyId: the id of the user's company, on a hierarchical groups project
    public init(userId: String?, companyId: String? = nil) {
        self.init(userId: userId, companyId: companyId, deviceId: nil)
    }

    /// For internal use by the Mixpanel SDKs only, which own the device id. Apps create an
    /// identity with ``init(userId:companyId:)``.
    ///
    /// - parameter userId: the user's id
    /// - parameter companyId: the id of the user's company, on a hierarchical groups project
    /// - parameter deviceId: the device id analytics assigned
    public init(userId: String?, companyId: String?, deviceId: String?) {
        self.userId = userId
        self.companyId = companyId
        self.deviceId = deviceId
    }

    /// `MixpanelIdentity(userId=u, companyId=c, deviceId=d)`, leaving out values that are nil.
    public var description: String {
        let fields = [
            userId.map { "userId=\($0)" },
            companyId.map { "companyId=\($0)" },
            deviceId.map { "deviceId=\($0)" },
        ].compactMap { $0 }
        return "MixpanelIdentity(\(fields.joined(separator: ", ")))"
    }
}
