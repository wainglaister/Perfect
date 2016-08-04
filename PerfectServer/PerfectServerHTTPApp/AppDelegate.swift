//
//  AppDelegate.swift
//  PerfectServerHTTPApp
//
//  Created by Kyle Jessup on 2015-10-25.
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

import Foundation
import Cocoa
import PerfectLib

let KEY_SERVER_PORT = "server.port"
let KEY_SERVER_ADDRESS = "server.address"
let KEY_SERVER_ROOT = "server.root"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	static var sharedInstance: AppDelegate {
		return NSApplication.sharedApplication().delegate as! AppDelegate
	}
	
	var httpServer: HTTPServer?
	let serverDispatchQueue = dispatch_queue_create("HTTP Server Accept", DISPATCH_QUEUE_SERIAL)
	
	var serverPort: UInt16 = 9876 {
		didSet {
			NSUserDefaults.standardUserDefaults().setValue(Int(self.serverPort), forKey: KEY_SERVER_PORT)
			NSUserDefaults.standardUserDefaults().synchronize()
		}
	}
	var serverAddress: String = "0.0.0.0" {
		didSet {
			NSUserDefaults.standardUserDefaults().setValue(self.serverAddress, forKey: KEY_SERVER_ADDRESS)
			NSUserDefaults.standardUserDefaults().synchronize()
		}
	}
	var documentRoot: String = "./webroot/" {
		didSet {
			NSUserDefaults.standardUserDefaults().setValue(self.documentRoot, forKey: KEY_SERVER_ROOT)
			NSUserDefaults.standardUserDefaults().synchronize()
		}
	}
	
	override init() {
		let r = UInt16(NSUserDefaults.standardUserDefaults().integerForKey(KEY_SERVER_PORT))
		if r == 0 {
			self.serverPort = 9876
		} else {
			self.serverPort = r
		}
		self.serverAddress = NSUserDefaults.standardUserDefaults().stringForKey(KEY_SERVER_ADDRESS) ?? "0.0.0.0"
		self.documentRoot = NSUserDefaults.standardUserDefaults().stringForKey(KEY_SERVER_ROOT) ?? "./webroot/"
	}
	
	func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        let ls = PerfectServer.staticPerfectServer
        ls.updateHomePath(NSBundle.mainBundle().bundleURL.URLByDeletingLastPathComponent!.path! + "/")
        
        self.logOut(ls.homeDir())
        let fm = NSFileManager()
        fm.changeCurrentDirectoryPath(ls.homeDir())
        self.logOut(fm.currentDirectoryPath)
        self.logOut("\(NSProcessInfo.processInfo().arguments)")
        self.logOut("\(NSProcessInfo.processInfo().environment)")
        self.logOut(NSBundle.mainBundle().bundlePath)
        
		ls.initializeServices()
		
		do {
			try self.startServer()
		} catch {
			self.logOut("\(error)")
		}
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}
	
	@IBAction
	func startServer(sender: AnyObject) {
        self.logOut("Start server")
		do { try self.startServer() } catch { self.logOut("\(error)") }
	}
	
	@IBAction
	func stopServer(sender: AnyObject) {
		self.stopServer()
	}
	
	func serverIsRunning() -> Bool {
		guard let _ = self.httpServer else {
			return false
		}
//		let tcp = NetTCP()
//		defer {
//			tcp.close()
//		}
//		
//		do {
//			try tcp.bind(s.serverPort, address: s.serverAddress)
//			return false
//		} catch {
//			
//		}
		return true
	}
	
	func startServer() throws {
		try self.startServer(serverPort, address: serverAddress, documentRoot: documentRoot)
	}
	
	func startServer(port: UInt16, address: String, documentRoot: String) throws {
		guard nil == self.httpServer else {
			self.logOut("Server already running")
			return
		}
		dispatch_async(self.serverDispatchQueue) { [unowned self] in
			do {
				try Dir(documentRoot).create()
				self.httpServer = HTTPServer(documentRoot: documentRoot)
                
                let sslCert = documentRoot + "fullchain.cer"
                let sslKey = documentRoot + "private.key"
                
                if Dir(sslCert).exists() && Dir(sslKey).exists() {
                    try self.httpServer!.start(port, bindAddress: address)
                } else {
                    try self.httpServer!.start(port, sslCert: sslCert, sslKey: sslKey, dhParams: nil, bindAddress: address)
                }
			} catch let e {
				self.logOut("Exception in server run loop \(e) \(address):\(port)")
			}
			self.logOut("Exiting server run loop")
		}
	}

	func stopServer() {
		if let _ = self.httpServer {
			self.httpServer!.stop()
			self.httpServer = nil
		}
	}
    
    func logOut(log: String) {
        print(log)
        
        let basePath = PerfectServer.staticPerfectServer.homeDir()
        let fileName = "App.txt"
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

