//
//  LogManager.swift
//  PerfectLib
//
//  Created by Kyle Jessup on 7/21/15.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//
#if os(Linux)
    import SwiftGlibc
    import LinuxBridge
#else
    import Darwin
#endif

/// Placeholder functions for logging system
public struct Log:SysLogProtocol {
	
	
}

public protocol LogProtocol {
    static func currLog() -> String
    
    static func perfectSyslog(priority p: Int32, _ msg: String, _ args: CVarArg...)
    
    static func info(message msg: CustomStringConvertible)
    
    static func warning(message msg: CustomStringConvertible, _ args: CVarArg...)
    
    static func error(message msg: CustomStringConvertible, _ args: CVarArg...)
    
    static func critical(message msg: CustomStringConvertible, _ args: CVarArg...)
    
    @noreturn
    static func terminal(message msg: CustomStringConvertible, _ args: CVarArg...)
}

public protocol SysLogProtocol: LogProtocol {
    
}

public extension SysLogProtocol {
    
    static func currLog() -> String { return "syslog" }
    
    static func perfectSyslog(priority p: Int32, _ msg: String, _ args: CVarArg...) {
        withVaList(args) { vsyslog(p, msg, $0) }
        print("\(p): \(msg)")
    }
    
    static func info(message msg: CustomStringConvertible) {
        perfectSyslog(priority: LOG_INFO, msg.description)
    }
    
    static func info(message msg: String) {
        self.info(message: msg.utf8)
    }
    
    static func warning(message msg: CustomStringConvertible, _ args: CVarArg...) {
        perfectSyslog(priority: LOG_WARNING, msg.description)
    }
    
    static func warning(message msg: String, _ args: CVarArg...) {
        self.warning(message: msg.utf8)
    }
    
    static func error(message msg: CustomStringConvertible, _ args: CVarArg...) {
        perfectSyslog(priority: LOG_ERR, msg.description)
    }
    
    static func error(message msg: String, _ args: CVarArg...) {
        self.error(message: msg.utf8)
    }
    
    /*
     static func error(message msg: String, _ args: CVarArg...) {
     perfectSyslog(priority: LOG_ERR, msg)
     }
     */
    static func critical(message msg: CustomStringConvertible, _ args: CVarArg...) {
        perfectSyslog(priority: LOG_CRIT, msg.description)
    }
    
    static func critical(message msg: String, _ args: CVarArg...) {
        self.critical(message: msg.utf8)
    }
    
    @noreturn
    static func terminal(message msg: CustomStringConvertible, _ args: CVarArg...) {
        perfectSyslog(priority: LOG_EMERG, msg.description)
        fatalError(msg.description)
    }
    
    static func terminal(message msg: String, _ args: CVarArg...) {
        self.terminal(message: msg.utf8)
    }
    
}

public protocol PrintLogProtocol: LogProtocol {
    
}

public extension PrintLogProtocol {
    
    static func currLog() -> String { return "printlog" }
    
    static func perfectPrintLog(priority p: Int32, _ msg: String, _ args: CVarArg...) {
        print("\(p): \(msg)")
    }
    
    static func info(message msg: CustomStringConvertible) {
        perfectPrintLog(priority: LOG_INFO, msg.description)
    }
    
    static func info(message msg: String) {
        self.info(message: msg.utf8)
    }
    
    static func warning(message msg: CustomStringConvertible, _ args: CVarArg...) {
        perfectPrintLog(priority: LOG_WARNING, msg.description)
    }
    
    static func warning(message msg: String) {
        self.warning(message: msg.utf8)
    }
    
    static func error(message msg: CustomStringConvertible, _ args: CVarArg...) {
        perfectPrintLog(priority: LOG_ERR, msg.description)
    }

    static func error(message msg: String) {
        self.error(message: msg.utf8)
    }
    
    static func critical(message msg: CustomStringConvertible, _ args: CVarArg...) {
        perfectPrintLog(priority: LOG_CRIT, msg.description)
    }
    
    static func critical(message msg: String) {
        self.critical(message: msg.utf8)
    }
    
    @noreturn
    static func terminal(message msg: CustomStringConvertible, _ args: CVarArg...) {
        perfectPrintLog(priority: LOG_EMERG, msg.description)
        fatalError(msg.description)
    }

    static func terminal(message msg: String) {
        self.terminal(message: msg.utf8)
    }
    
}
