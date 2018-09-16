//
//  AppDelegate.swift
//  timeAware
//
//  Created by Jean Machado on 16.09.18.
//  Copyright © 2018 Jean Machado. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusBar = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var currentClock : Int = 0;

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBar.title = "00:00"


        let menu = NSMenu()
        menu.autoenablesItems = true


        let startItem = NSMenuItem()
        startItem.title = "Start"
        startItem.action = #selector(start(_:))
        menu.insertItem(startItem, at: 0)


        let quitItem = NSMenuItem()
        quitItem.title = "Quit"
        quitItem.action = #selector(quit(_:))
        menu.insertItem(quitItem, at: 1)


        statusBar.menu = menu
    }

    @objc func start(_ obj: NSMenuItem) {
        if (currentClock > 0) {
            currentClock = 0
            return
        }


        let date = Date().addingTimeInterval(1)
        let timer = Timer(fireAt: date, interval: 1, target: self, selector: #selector(incrementTimer(_:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)

    }

    @objc func incrementTimer(_ obj: NSMenuItem) {
        currentClock = currentClock + 1
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: currentClock)
        if (h > 0) {
            statusBar.title = "\(String(format: "%02d", h)):\(String(format: "%02d", m)):\(String(format: "%02d", s))"
        } else {
            statusBar.title = "\(String(format: "%02d", m)):\(String(format: "%02d", s))"
        }
    }


    @objc func quit(_ obj: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }

    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}

