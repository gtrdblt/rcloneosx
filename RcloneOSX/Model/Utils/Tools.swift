//
//  Tools.swift
//  rcloneOSX
//
//  Created by Thomas Evensen on 22.07.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable line_length

import Foundation

var globalMainQueue: DispatchQueue {
    return DispatchQueue.main
}

var globalBackgroundQueue: DispatchQueue {
    return DispatchQueue.global(qos: .background)
}
var globalUserInitiatedQueue: DispatchQueue {
    return DispatchQueue.global(qos: .userInitiated)
}
var globalUtilityQueue: DispatchQueue {
    return DispatchQueue.global(qos: .utility)
}
var globalUserInteractiveQueue: DispatchQueue {
    return DispatchQueue.global(qos: .userInteractive)
}
var globalDefaultQueue: DispatchQueue {
    return DispatchQueue.global(qos: .default)
}

// Used in mainTab to present info about process
enum DisplayProcessInfo {
    case estimating
    case executing
    case loggingrun
    case changeprofile
    case abort
    case blank
    case error
}

// Protocol for doing a refresh in main view after testing for connectivity
protocol Connections: class {
    func displayConnections()
}

protocol Setinfoaboutrclone: class {
    func setinfoaboutrclone()
}

final class Tools: SetConfigurations {

    private var indexBoolremoteserverOff: [Bool]?
    weak var testconnectionsDelegate: Connections?
    weak var newprofileDelegate: NewProfile?
    private var macSerialNumber: String?
    weak var verifyrcloneDelegate: Setinfoaboutrclone?

    // Setting date format
    func setDateformat() -> DateFormatter {
        let dateformatter = DateFormatter()
        // We are forcing en_US format of date strings
        dateformatter.locale = Locale(identifier: "en_US")
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .short
        dateformatter.dateFormat = "dd MMM yyyy HH:mm"
        return dateformatter
    }

    // Function to verify full rclonepath
    func verifyrclonepath() {
        let fileManager = FileManager.default
        let path: String?
        // If not in /usr/bin or /usr/local/bin
        // rclonePath is set if none of the above
        if let rclonePath = ViewControllerReference.shared.rclonePath {
            path = rclonePath + ViewControllerReference.shared.rclone
        } else if ViewControllerReference.shared.rcloneopt {
            path = "/usr/local/bin/" + ViewControllerReference.shared.rclone
        } else {
            path = "/usr/bin/" + ViewControllerReference.shared.rclone
        }
        guard ViewControllerReference.shared.rcloneopt == true else {
            ViewControllerReference.shared.norclone = false
            self.verifyrcloneDelegate?.setinfoaboutrclone()
            return
        }
        if fileManager.fileExists(atPath: path!) == false {
            ViewControllerReference.shared.norclone = true
        } else {
            ViewControllerReference.shared.norclone = false
        }
        self.verifyrcloneDelegate?.setinfoaboutrclone()
    }

    // Display the correct command to execute
    // Used for displaying the commands only
    func rclonepathtodisplay(index: Int, dryRun: Bool) -> String {
        var str: String?
        let config = self.configurations!.getargumentAllConfigurations()[index]
        if dryRun {
            str = self.rclonepath() + " "
            if let count = config.argdryRunDisplay?.count {
                for i in 0 ..< count {
                    str = str! + config.argdryRunDisplay![i]
                }
            }
        } else {
            str = self.rclonepath() + " "
            if let count = config.argDisplay?.count {
                for i in 0 ..< count {
                    str = str! + config.argDisplay![i]
                }
            }
        }
        return str!
    }

    /// Function returns the correct path for rclone
    /// according to configuration set by user or
    /// default value.
    /// - returns : full path of rclone command
    func rclonepath() -> String {
        if ViewControllerReference.shared.rcloneopt {
            if ViewControllerReference.shared.rclonePath == nil {
                return ViewControllerReference.shared.usrlocalbinrclone
            } else {
                return ViewControllerReference.shared.rclonePath! + ViewControllerReference.shared.rclone
            }
        } else {
            return ViewControllerReference.shared.usrbinrclone
        }
    }

    func norclone() {
        if let rclone = ViewControllerReference.shared.rclonePath {
            Alerts.showInfo("ERROR: no rclone in " + rclone)
        } else {
            Alerts.showInfo("ERROR: no rclone in /usr/local/bin")
        }
    }

    /// Function for computing MacSerialNumber
    func computemacSerialNumber() -> String {
        // Get the platform expert
        let platformExpert: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                                       IOServiceMatching("IOPlatformExpertDevice"))
        // Get the serial number as a CFString ( actually as Unmanaged<AnyObject>! )
        let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,
                                                                     kIOPlatformSerialNumberKey as CFString?,
                                                                     kCFAllocatorDefault, 0)
        // Release the platform expert (we're responsible)
        IOObjectRelease(platformExpert)
        // Take the unretained value of the unmanaged-any-object
        // (so we're not responsible for releasing it)
        // and pass it back as a String or, if it fails, an empty string
        // return (serialNumberAsCFString!.takeUnretainedValue() as? String) ?? ""
        return (serialNumberAsCFString!.takeRetainedValue() as? String) ?? ""
    }

    /// Function for returning the MacSerialNumber
    func getMacSerialNumber() -> String? {
        guard self.macSerialNumber != nil else {
            // Compute it, set it and return
            self.macSerialNumber = self.computemacSerialNumber()
            return self.macSerialNumber!
        }
        return self.macSerialNumber
    }

    // Calculate seconds from now to startdate
    private func seconds (_ startdate: Date, enddate: Date?) -> Double {
        if enddate == nil {
            return startdate.timeIntervalSinceNow
        } else {
            return enddate!.timeIntervalSince(startdate)
        }
    }

    // Calculation of time to a spesific date
    // Used in view of all tasks
    // Returns time in minutes
    func timeDoubleMinutes (_ startdate: Date, enddate: Date?) -> Double {
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        let (_, minf) = modf (seconds / 3600)
        let (min, _) = modf (60 * minf)
        return min
    }

    // Calculation of time to a spesific date
    // Used in view of all tasks
    // Returns time in seconds
    func timeDoubleSeconds (_ startdate: Date, enddate: Date?) -> Double {
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        return seconds
    }

    // Returns number of hours between start and stop date
    func timehourInt(_ startdate: Date, enddate: Date?) -> Int {
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        let (hr, _) = modf (seconds / 3600)
        return Int(hr)
    }

    // Calculation of time to a spesific date
    // Used in view of all tasks
    func timeString (_ startdate: Date, enddate: Date?) -> String {
        var result: String?
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        let (hr, minf) = modf (seconds / 3600)
        let (min, secf) = modf (60 * minf)
        // hr, min, 60 * secf
        if hr == 0 && min == 0 {
            result = String(format: "%.0f", 60 * secf) + " secs"
        } else if hr == 0 && min < 60 {
            result = String(format: "%.0f", min) + " mins " + String(format: "%.0f", 60 * secf) + " secs"
        } else if hr < 25 {
            result = String(format: "%.0f", hr) + " hours " + String(format: "%.0f", min) + " mins"
        } else {
            result = String(format: "%.0f", hr/24) + " days"
        }
        if secf <= 0 {
            result = " ... working ... "
        }
        return result!
    }

    // Calculation of time to a spesific date
    // Used in view of all tasks
    func timeString (_ seconds: Double) -> String {
        var result: String?
        let (hr, minf) = modf (seconds / 3600)
        let (min, secf) = modf (60 * minf)
        // hr, min, 60 * secf
        if hr == 0 && min == 0 {
            result = String(format: "%.0f", 60 * secf) + "s"
        } else if hr == 0 && min < 60 {
            result = String(format: "%.0f", min) + "m " + String(format: "%.0f", 60 * secf) + "s"
        } else if hr < 25 {
            result = String(format: "%.0f", hr) + "h " + String(format: "%.0f", min) + "m"
        } else {
            result = String(format: "%.0f", hr/24) + "d"
        }
        return result ?? ""
    }

    init() {
        self.verifyrcloneDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.newprofileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
}
