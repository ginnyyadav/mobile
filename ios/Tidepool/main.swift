/*
 * Copyright (c) 2016, Tidepool Project
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

import UIKit
import CocoaLumberjack

class App: UIApplication {
    override init() {
        // setenv("CFNETWORK_DIAGNOSTICS", "3", 1) // NOTE: - don't check in or distribute TestFlight builds with this enabled!
        
        // Set up Xcode and system logging
        DDTTYLogger.sharedInstance.logFormatter = LogFormatter()
        DDLog.add(DDTTYLogger.sharedInstance)
        
        //Only needed if no file logging is set (below)...
        //DDASLLogger.sharedInstance.logFormatter = LogFormatter()
        //DDLog.add(DDASLLogger.sharedInstance)

        // Set up file logging
        fileLogger = DDFileLogger()
        fileLogger.logFormatter = LogFormatter()
        fileLogger.rollingFrequency = TimeInterval(60 * 60 * 4); // 4 hours
        fileLogger.maximumFileSize = 0 // no max file size, just use 4 hour rolling logs
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7 * 24 / 4;  // 7 days
        // Add file logger
        DDLog.add(fileLogger);
        
        // Set up log level
        defaultDebugLevel = DDLogLevel.verbose
        let loggingEnabledObject = UserDefaults.standard.object(forKey: "LoggingEnabled")
        if loggingEnabledObject == nil || !(loggingEnabledObject! as AnyObject).boolValue {
            defaultDebugLevel = DDLogLevel.off
        }
#if DEBUG
        defaultDebugLevel = DDLogLevel.verbose
#endif

        DDLogVerbose("trace")
    }
}


_ = UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, NSStringFromClass(App.self), NSStringFromClass(TPAppDelegate.self))
