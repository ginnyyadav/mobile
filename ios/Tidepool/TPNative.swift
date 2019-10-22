/*
 * Copyright (c) 2019, Tidepool Project
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the associated License, which is identical to the BSD 2-Clause
 * License as published by the Open Source Initiative at opensource.org.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the License for more details.
 *
 * You should have received a copy of the License along with this program; if
 * not, you can obtain one from Tidepool Project at tidepool.org.
 */

import Foundation
import TPHealthKitUploader
import UIKit

@objc(TPNative)
class TPNative: NSObject {
    @objc static func requiresMainQueueSetup() -> Bool {
        return true
    }

    @objc func setUser(_ userId: String, username: String, userFullName: String, isDSAUser: Bool, sessionToken: String) -> Void {
        Rollbar.currentConfiguration()?.setPersonId(userId, username: userFullName, email: username)

        TPApi.sharedInstance.sessionToken = sessionToken

        let dataController = TPDataController.sharedInstance
        dataController.currentUserId = userId
        dataController.currentUserFullName = userFullName
        dataController.currentUserIsDSAUser = isDSAUser
        dataController.configureHealthKitInterface()
    }

    @objc(clearUser)
    func clearUser() -> Void {
        Rollbar.currentConfiguration()?.setPersonId(nil, username: nil, email: nil)

        TPApi.sharedInstance.sessionToken = nil

        let dataController = TPDataController.sharedInstance
        dataController.currentUserId = nil
        dataController.currentUserFullName = nil
        dataController.currentUserIsDSAUser = false
        dataController.configureHealthKitInterface()
    }

    @objc func setEnvironment(_ environment: String) -> Void {
        Rollbar.currentConfiguration()?.environment = environment

        let api = TPApi.sharedInstance
        api.environment = environment
        api.configure()

        let dataController = TPDataController.sharedInstance
        dataController.configureHealthKitInterface()
    }

    @objc func testNativeCrash() -> Void {
        DispatchQueue.main.async(execute: {
            self.perform(Selector("Test native crash"), with: nil, afterDelay: 0.25)
        })
    }

    @objc func testLogWarning(_ message: String) -> Void {
        RollbarReactNative.warning(withMessage: message)
    }

    @objc func testLogError(_ message: String) -> Void {
        RollbarReactNative.error(withMessage: message)
    }
}
