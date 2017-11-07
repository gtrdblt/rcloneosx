//
//  rsyncProcessArguments.swift
//  Rsync
//
//  Created by Thomas Evensen on 08/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

class RsyncProcessArguments {
    
    private var arguments: Array<String>?
    var localCatalog: String?
    var offsiteCatalog: String?
    var offsiteUsername: String?
    var offsiteServer: String?
    var remoteargs: String?

    // Brute force, check every parameter, not special elegant, but it works

    private func setParameters1To14(_ config: Configuration, dryRun: Bool, forDisplay: Bool) {
        if config.parameter1 != nil {
            self.appendParameter(parameter: config.parameter1!, forDisplay: forDisplay)
        }
        if config.parameter2 != nil {
            self.appendParameter(parameter: config.parameter2!, forDisplay: forDisplay)
        }
        if config.parameter3 != nil {
            self.appendParameter(parameter: config.parameter3!, forDisplay: forDisplay)
        }
        if config.parameter4 != nil {
            self.appendParameter(parameter: config.parameter4!, forDisplay: forDisplay)
        }
        if config.parameter5 != nil {
            self.appendParameter(parameter: config.parameter5!, forDisplay: forDisplay)
        }
        if config.parameter6 != nil {
            self.appendParameter(parameter: config.parameter6!, forDisplay: forDisplay)
        }
        if config.parameter8 != nil {
            self.appendParameter(parameter: config.parameter8!, forDisplay: forDisplay)
        }
        if config.parameter9 != nil {
            self.appendParameter(parameter: config.parameter9!, forDisplay: forDisplay)
        }
        if config.parameter10 != nil {
            self.appendParameter(parameter: config.parameter10!, forDisplay: forDisplay)
        }
        if config.parameter11 != nil {
            self.appendParameter(parameter: config.parameter11!, forDisplay: forDisplay)
        }
        if config.parameter12 != nil {
            self.appendParameter(parameter: config.parameter12!, forDisplay: forDisplay)
        }
        if config.parameter13 != nil {
            self.appendParameter(parameter: config.parameter13!, forDisplay: forDisplay)
        }
        if config.parameter14 != nil {
            self.appendParameter(parameter: config.parameter14!, forDisplay: forDisplay)
        }
    }

    private func dryrunparameter(_ config: Configuration, forDisplay: Bool) {
        let dryrun: String = config.dryrun
        self.arguments!.append(dryrun)
        if forDisplay {self.arguments!.append(" ")}
    }

    // Check userselected parameter and append it
    // to arguments array passed to rsync or displayed
    // on screen.

    private func appendParameter (parameter: String, forDisplay: Bool) {
        if parameter.count > 1 {
            self.arguments!.append(parameter)
            if forDisplay {
                self.arguments!.append(" ")
            }
        }
    }

    /// Function for initialize arguments array. RsyncOSX computes four argumentstrings
    /// two arguments for dryrun, one for rsync and one for display
    /// two arguments for realrun, one for rsync and one for display
    /// which argument to compute is set in parameter to function
    /// - parameter config: structure (configuration) holding configuration for one task
    /// - parameter dryRun: true if compute dryrun arguments, false if compute arguments for real run
    /// - paramater forDisplay: true if for display, false if not
    /// - returns: Array of Strings
    func argumentsRsync (_ config: Configuration, dryRun: Bool, forDisplay: Bool) -> Array<String> {
        self.localCatalog = config.localCatalog
        self.offsiteCatalog = config.offsiteCatalog
        self.offsiteUsername = config.offsiteUsername
        self.offsiteServer = config.offsiteServer
        if self.offsiteServer!.isEmpty == false {
            self.remoteargs = self.offsiteServer! + ":" + self.offsiteCatalog!
        }
        self.setParameters1To14(config, dryRun: dryRun, forDisplay: forDisplay)
        self.argumentsforbackup(dryRun: dryRun, forDisplay: forDisplay)
        // Append --stats parameter to collect info about run
        if dryRun {
            self.dryrunparameter(config, forDisplay: forDisplay)
        }
        return self.arguments!
    }

    private func argumentsforbackup(dryRun: Bool, forDisplay: Bool) {
        // Backup
        self.arguments!.append(self.localCatalog!)
        if self.offsiteServer!.isEmpty {
            if forDisplay {self.arguments!.append(" ")}
            self.arguments!.append(self.offsiteCatalog!)
            if forDisplay {self.arguments!.append(" ")}
        } else {
            if forDisplay {self.arguments!.append(" ")}
            self.arguments!.append(remoteargs!)
            if forDisplay {self.arguments!.append(" ")}
        }
    }

    init () {
        self.arguments = nil
        self.arguments = Array<String>()
    }
}
