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
import CocoaLumberjack
import UIKit

@objc(TPNativeHealth)
class TPNativeHealth: RCTEventEmitter {
    private let connector = TPUploaderAPI.connector()
    private let uploader = TPUploaderAPI.connector().uploader()
    
    public override init() {
        super.init()

        connector.nativeHealthBridge = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(TPNativeHealth.handleTurnOnUploader(_:)), name: Notification.Name(rawValue: TPUploaderNotifications.TurnOnUploader), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TPNativeHealth.handleTurnOffUploader(_:)), name: Notification.Name(rawValue: TPUploaderNotifications.TurnOffUploader), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TPNativeHealth.handleStatsUpdated(_:)), name: Notification.Name(rawValue: TPUploaderNotifications.Updated), object: nil)
    }

    override static func requiresMainQueueSetup() -> Bool {
        return true
    }

    @objc func enableHealthKitInterface() -> NSNumber {
        uploader.enableHealthKitInterface()
        return NSNumber(value: true)
    }

    @objc func disableHealthKitInterface() -> NSNumber {
        _ = stopUploadingHistoricalAndReset();
        uploader.disableHealthKitInterface()
        return NSNumber(value: true)
    }

    @objc func shouldShowHealthKitUI() -> NSNumber {
        return NSNumber(value: uploader.shouldShowHealthKitUI())
    }

    @objc func healthKitInterfaceEnabledForCurrentUser() -> NSNumber {
        return NSNumber(value: connector.isInterfaceOn)
    }

    @objc func healthKitInterfaceConfiguredForOtherUser() -> NSNumber {
        return NSNumber(value: uploader.healthKitInterfaceConfiguredForOtherUser())
    }
    
    @objc func currentHealthKitUsername() -> NSString {
        if let currentHealthKitUsername = uploader.curHKUserName() {
            return currentHealthKitUsername as NSString
        }
        return ""
    }

    @objc func uploaderProgress() -> NSDictionary {
        let isUploadingHistorical = self.uploader.isUploadInProgressForMode(TPUploader.Mode.HistoricalAll)
        let progress = self.uploader.uploaderProgress()
        let lastSuccessfulCurrentUploadTime = progress.lastSuccessfulCurrentUploadTime
        return [
            "isUploadingHistorical": isUploadingHistorical,
            "historicalUploadCurrentDay": progress.currentDayHistorical,
            "historicalUploadTotalDays": progress.totalDaysHistorical,
            "lastCurrentUploadUiDescription": lastCurrentUploadUiDescription()
        ]
    }

    @objc func startUploadingHistorical() -> NSNumber {
        let dataCtl = TPDataController.sharedInstance
        guard let _ = dataCtl.currentUserId else {
            return NSNumber(value: false)
        }
        uploader.startUploading(TPUploader.Mode.HistoricalAll)
        return NSNumber(value: true)
    }

    @objc func stopUploadingHistoricalAndReset() -> NSNumber {
        uploader.stopUploading(mode: .HistoricalAll, reason: .interfaceTurnedOff)
        uploader.resetPersistentStateForMode(.HistoricalAll)
        return NSNumber(value: true)
    }
    
    override func supportedEvents() -> [String]! {
      return ["onTurnOnInterface", "onTurnOffInterface", "onTurnOnHistoricalUpload", "onTurnOffHistoricalUpload", "onUploadStatsUpdated"]
    }
    
    var isObserving: Bool = false
    
    override func startObserving() -> Void {
        DDLogVerbose("trace")

        isObserving = true
    }

    override func stopObserving() -> Void {
        DDLogVerbose("trace")

        isObserving = false
    }

    func onTurnOnInterface() {
        DDLogVerbose("trace")

        guard isObserving else {
            return
        }

        DispatchQueue.main.async {
            let body = [
                "shouldShowHealthKitUI": self.uploader.shouldShowHealthKitUI(),
                "healthKitInterfaceEnabledForCurrentUser": self.connector.isInterfaceOn,
                "healthKitInterfaceConfiguredForOtherUser": self.uploader.healthKitInterfaceConfiguredForOtherUser(),
                "currentHealthKitUsername": self.currentHealthKitUsername()
                ] as [String : Any]
            self.sendEvent(withName: "onTurnOnInterface", body: body)
        }
    }

    func onTurnOffInterface() {
        DDLogVerbose("trace")

        guard isObserving else {
            return
        }

        DispatchQueue.main.async {
            let body = [
                "shouldShowHealthKitUI": self.uploader.shouldShowHealthKitUI(),
                "healthKitInterfaceEnabledForCurrentUser": self.connector.isInterfaceOn,
                "healthKitInterfaceConfiguredForOtherUser": self.uploader.healthKitInterfaceConfiguredForOtherUser(),
                "currentHealthKitUsername": self.currentHealthKitUsername()
                ] as [String : Any]
            self.sendEvent(withName: "onTurnOffInterface", body: body)
        }
    }
    
    @objc func handleTurnOnUploader(_ note: Notification) {
        DDLogVerbose("trace")

        guard isObserving else {
            return
        }

        DispatchQueue.main.async {
            let userInfo = note.userInfo!
            let mode = userInfo["mode"] as! TPUploader.Mode
            if mode == TPUploader.Mode.HistoricalAll {
                self.sendEvent(withName: "onTurnOnHistoricalUpload", body:nil)
            }
        }
    }
    
    @objc func handleTurnOffUploader(_ note: Notification) {
        DDLogVerbose("trace")

        guard isObserving else {
            return
        }

        DispatchQueue.main.async {
            let userInfo = note.userInfo!
            let mode = userInfo["mode"] as! TPUploader.Mode
            let type = userInfo["type"] as! String
            let reason = userInfo["reason"] as! TPUploader.StoppedReason
            DDLogInfo("Type: \(type), Mode: \(mode), Reason: \(reason)")
            
            var body: Any? = nil
            if mode == TPUploader.Mode.HistoricalAll {
                // Update status
                switch reason {
                case .interfaceTurnedOff:
                    body = ["turnOffUploaderReason": "turned off", "turnOffUploaderError": ""]
                    break
                case .uploadingComplete:
                    body = ["turnOffUploaderReason": "complete", "turnOffUploaderError": ""]
                    break
                case .error(let error):
                    body = ["turnOffUploaderReason": "error", "turnOffUploaderError": String("\(type) upload error: \(error.localizedDescription.prefix(50))")]
                    break
                default:
                    break
                }
                self.sendEvent(withName: "onTurnOffHistoricalUpload", body: body)
            }
        }
    }

    @objc func handleStatsUpdated(_ note: Notification) {
        DDLogVerbose("trace")

        guard isObserving else {
            return
        }

        DispatchQueue.main.async {
            let userInfo = note.userInfo!
            let mode = userInfo["mode"] as! TPUploader.Mode
            let type = userInfo["type"] as! String
            DDLogInfo("Type: \(type), Mode: \(mode)")

            var body: Any? = nil
            
            if mode == TPUploader.Mode.HistoricalAll {
                body = self.createBodyForHistoricalStats()
            } else {
                body = self.createBodyForCurrentStats()
            }

            self.sendEvent(withName: "onUploadStatsUpdated", body: body)
        }
    }
    
    func createBodyForHistoricalStats() -> Any? {
        let isUploadingHistorical = self.uploader.isUploadInProgressForMode(TPUploader.Mode.HistoricalAll)
        let progress = self.uploader.uploaderProgress()
        return [
            "type": "historical",
            "isUploadingHistorical": isUploadingHistorical,
            "historicalUploadCurrentDay": progress.currentDayHistorical,
            "historicalUploadTotalDays": progress.totalDaysHistorical,
        ]
    }

    func createBodyForCurrentStats() -> Any? {
        return [
            "type": "current",
            "lastCurrentUploadUiDescription": lastCurrentUploadUiDescription()
        ]
    }
    
    private func lastCurrentUploadUiDescription() -> String {
        var description = "No data available to upload"
        let progress = self.uploader.uploaderProgress()
        if let lastSuccessfulUpload = progress.lastSuccessfulCurrentUploadTime/*, let lastType = self.lastCurrentUploadType()*/
        {
            let lastUploadTimeAgoInWords = lastSuccessfulUpload.timeAgoInWords(Date())
            description = String(format: "Last reading %@", lastUploadTimeAgoInWords)
        }
        return description
    }
    
    private func lastCurrentUploadType() -> String? {
        var lastType: String?
        var lastUploadTime: Date?
        let currentStats = self.uploader.currentUploadStats()
        for stat in currentStats {
            if stat.hasSuccessfullyUploaded {
                if lastType == nil || lastUploadTime == nil {
                    lastUploadTime = stat.lastSuccessfulUploadTime
                    lastType = stat.typeName
                } else {
                    if stat.lastSuccessfulUploadTime != nil, stat.lastSuccessfulUploadTime!.compare(lastUploadTime!) == .orderedDescending {
                        lastUploadTime = stat.lastSuccessfulUploadTime
                        lastType = stat.typeName
                    }
                }
                DDLogInfo("Mode: \(stat.mode.rawValue)")
                DDLogInfo("Type: \(stat.typeName)")
                DDLogInfo("Last successful upload time: \(String(describing: stat.lastSuccessfulUploadTime))")
                DDLogInfo("")
            }
        }
        return lastType
    }
}