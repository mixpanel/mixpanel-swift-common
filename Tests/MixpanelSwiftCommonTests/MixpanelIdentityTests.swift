//
//  MixpanelIdentityTests.swift
//  MixpanelSwiftCommon
//

import Foundation
import Testing

@testable import MixpanelSwiftCommon

@Suite("MixpanelIdentity Tests")
struct MixpanelIdentityTests {

    @Test("Company and device default to nil")
    func testDefaults() {
        let identity = MixpanelIdentity(userId: "user_123")
        #expect(identity.userId == "user_123")
        #expect(identity.companyId == nil)
        #expect(identity.deviceId == nil)
        #expect(MixpanelIdentity(userId: "user_123", companyId: "acme").deviceId == nil)
        #expect(
            MixpanelIdentity(userId: "user_123", companyId: "acme", deviceId: "device_abc").deviceId
                == "device_abc")
    }

    @Test("Identities compare by value")
    func testEquality() {
        #expect(
            MixpanelIdentity(userId: "user_123", companyId: "acme")
                == MixpanelIdentity(userId: "user_123", companyId: "acme"))
        #expect(
            MixpanelIdentity(userId: "user_123", companyId: "acme")
                != MixpanelIdentity(userId: "user_123", companyId: "globex"))
        #expect(
            MixpanelIdentity(userId: "user_123", companyId: "acme", deviceId: "d1")
                != MixpanelIdentity(userId: "user_123", companyId: "acme", deviceId: "d2"))
        #expect(MixpanelIdentity(userId: nil) == MixpanelIdentity(userId: nil, companyId: nil, deviceId: nil))
        let set: Set<MixpanelIdentity> = [
            MixpanelIdentity(userId: "user_123", companyId: "acme"),
            MixpanelIdentity(userId: "user_123", companyId: "acme"),
        ]
        #expect(set.count == 1)
    }

    @Test("Description leaves out nil values")
    func testDescription() {
        #expect(
            MixpanelIdentity(userId: "u", companyId: "c").description
                == "MixpanelIdentity(userId=u, companyId=c)")
        #expect(
            MixpanelIdentity(userId: "u", companyId: "c", deviceId: "d").description
                == "MixpanelIdentity(userId=u, companyId=c, deviceId=d)")
        #expect(MixpanelIdentity(userId: "u").description == "MixpanelIdentity(userId=u)")
        #expect(MixpanelIdentity(userId: nil).description == "MixpanelIdentity()")
    }
}
