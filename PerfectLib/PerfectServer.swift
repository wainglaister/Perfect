//
//  Perfect.swift
//  PerfectLib
//
//  Created by Kyle Jessup on 7/5/15.
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

/// Standard directory for server-side SQLite support databases
public let serverSQLiteDBs = "SQLiteDBs/"
/// Directory for server-size modules. Modules in this directory are loaded at server startup.
public var serverPerfectLibraries = "PerfectLibraries/"

/// Provides access to various system level features for the process.
/// A static instance of this class is created at startup and all access to this object go through the `PerfectServer.staticPerfectServer` static property.
public class PerfectServer {
    
    /// Provides access to the singleton PerfectServer instance.
    public static let staticPerfectServer = PerfectServer()
    var homePath: String
    
    internal init() {
        self.homePath = "./"
    }
    
    public func updateHomePath(homePath: String) {
        self.homePath = homePath
    }
    
    /// Performs any boot-strap level initialization such as creating databases or loading dynamic frameworks.
    /// Should only be called once befor starting FastCGI server
    public func initializeServices() {
        do {
            try SessionManager.initializeSessionsDatabase()
        } catch let e {
            self.logOut("Exception while initializing SQLite sessions database \(e)")
        }
        
        let dl = DynamicLoader()
        var baseDir : Dir
        if serverPerfectLibraries.hasPrefix("/") || serverPerfectLibraries.hasPrefix("~/") || serverPerfectLibraries.hasPrefix("./") {
            baseDir = Dir(serverPerfectLibraries)
        } else {
            baseDir = Dir(homeDir() + serverPerfectLibraries)
        }
        
        var realPath = baseDir.realPath()
        
        if !realPath.hasSuffix("/") {
            realPath += "/"
        }
        
        self.logOut("Load libs from: \(realPath)");
        do {
            try baseDir.forEachEntry { (name: String) -> () in
                if name.hasSuffix(".framework") || name.hasSuffix(".framework/") {
                    let fileName = realPath + name
                    if dl.loadFramework(fileName) {
                        self.logOut("Loaded "+fileName)
                    } else {
                        self.logOut("FAILED to load "+fileName)
                    }
                } else if name.hasSuffix(".so") || name.hasSuffix(".dylib") {
                    let fileName = realPath + name
                    if dl.loadLibrary(fileName) {
                        self.logOut("Loaded "+fileName)
                    } else {
                        self.logOut("FAILED to load "+fileName)
                    }
                }
            }
        } catch {
            self.logOut("Exception \(error)")
        }
    }
    
    /// The directory containing all configuration and runtime data for the current server process.
    /// Not to be confused with the web server directory which only exists during an individual web request and in the mind of the web server itself.
    public func homeDir() -> String {
        return homePath
    }
    
    func logOut(log: String) {
        print(log)
        
        let basePath = homeDir()
        let fileName = "PerfectServer.txt"
        let file = File(basePath + fileName)
        defer {
            file.close()
        }
        do {
            try file.openAppend()
            try file.writeString(log + "\n")
        } catch {
            print("\(error)")
        }
    }
}





