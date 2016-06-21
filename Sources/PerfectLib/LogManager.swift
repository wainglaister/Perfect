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


protocol LogProtocol {
    
    static func perfectSyslog(priority p: Int32, _ msg: String, _ args: CVarArg...)
    
    static func info(message msg: Any...)
    
    static func warning(message msg: CustomStringConvertible, _ args: CVarArg...)
    
    static func error(message msg: CustomStringConvertible, _ args: CVarArg...)
    
    static func critical(message msg: CustomStringConvertible, _ args: CVarArg...)
    
    @noreturn
    static func terminal(message msg: CustomStringConvertible, _ args: CVarArg...)
}

protocol SysLogProtocol: LogProtocol {
    
}

extension SysLogProtocol {
    
    static func currLog() -> String { return "syslog" }
    
    static func perfectSyslog(priority p: Int32, _ msg: String, _ args: CVarArg...) {
        withVaList(args) { vsyslog(p, msg, $0) }
    }
    
    static func info(message msg: Any...) {
        perfectSyslog(priority: LOG_INFO, msg.description)
    }
    
    static func warning(message msg: CustomStringConvertible, _ args: CVarArg...) {
        perfectSyslog(priority: LOG_WARNING, msg.description)
    }
    
    static func error(message msg: CustomStringConvertible, _ args: CVarArg...) {
        perfectSyslog(priority: LOG_ERR, msg.description)
    }
    /*
     static func error(message msg: String, _ args: CVarArg...) {
     perfectSyslog(priority: LOG_ERR, msg)
     }
     */
    static func critical(message msg: CustomStringConvertible, _ args: CVarArg...) {
        perfectSyslog(priority: LOG_CRIT, msg.description)
    }
    @noreturn
    static func terminal(message msg: CustomStringConvertible, _ args: CVarArg...) {
        perfectSyslog(priority: LOG_EMERG, msg.description)
        fatalError(msg.description)
    }
}

protocol PrintLogProtocol: LogProtocol {
    
}

extension PrintLogProtocol {
    
    static func perfectPrintLog(priority p: Int32, _ msg: String, _ args: CVarArg...) {
        withVaList(args) { vsyslog(p, msg, $0) }
    }
    
    static func info(message msg: Any...) {
        perfectPrintLog(priority: LOG_INFO, msg.description)
    }
    
    static func warning(message msg: CustomStringConvertible, _ args: CVarArg...) {
        perfectPrintLog(priority: LOG_WARNING, msg.description)
    }
    
    static func error(message msg: CustomStringConvertible, _ args: CVarArg...) {
        perfectPrintLog(priority: LOG_ERR, msg.description)
    }
    /*
     static func error(message msg: String, _ args: CVarArg...) {
     perfectSyslog(priority: LOG_ERR, msg)
     }
     */
    static func critical(message msg: CustomStringConvertible, _ args: CVarArg...) {
        perfectPrintLog(priority: LOG_CRIT, msg.description)
    }
    @noreturn
    static func terminal(message msg: CustomStringConvertible, _ args: CVarArg...) {
        perfectPrintLog(priority: LOG_EMERG, msg.description)
        fatalError(msg.description)
    }
}
