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
    @IBOutlet weak var createPanel: NSPanel!
    @IBOutlet weak var createButton: NSButton!
    @IBOutlet weak var createName: NSTextField!
    @IBOutlet weak var createDuration: NSTextField!


    let STATE_CSV = "database.txt"


    let statusBar = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var internalClock : Int = 0
    var currentTimer : (String, String)?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusMenu()

        createButton.action = #selector(handleCreate(_:))
    }

    func setupStatusMenu() {
        statusBar.title = "00:00"

        let menu = NSMenu()
        menu.autoenablesItems = true

        let addItem = NSMenuItem()
        addItem.title = "Add"
        addItem.action = #selector(showCreateModal(_:))
        menu.addItem(addItem)

        menu.addItem(NSMenuItem.separator())

        let entries = getCSVRows(destinationFile: STATE_CSV)

        for (index, element) in entries.enumerated() {
            let menuItem = NSMenuItem()
            menuItem.title = element.0
            menuItem.action = #selector(handleItemClick(_:))
            menu.addItem(menuItem)
        }

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem()
        quitItem.title = "Quit"
        quitItem.action = #selector(quit(_:))
        menu.addItem(quitItem)

        statusBar.menu = menu
    }

    @objc func handleItemClick(_ obj: NSMenuItem) -> Void {

        let entries = getCSVRows(destinationFile: STATE_CSV)
        let title =  obj.title

        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.rightMouseUp{
            removeEntryFromDatabase(name: title, destinationFile: STATE_CSV)
            setupStatusMenu()
            return
        }


        let match = entries.filter {  $0.0 == title }
        if (match[0] != nil) {
            currentTimer = match[0]
        }

        start(obj)
    }

    @objc func handleCreate(_ obj: NSMenuItem) {
        let entry = pair2String(title: createName.stringValue, value: createDuration.stringValue)
        appendLineToCSV(entry: entry, destinationFile: STATE_CSV)

        createPanel.close()
        setupStatusMenu()
    }

    @objc func showCreateModal(_ obj: NSMenuItem) {
        createName.stringValue = ""
        createDuration.stringValue = ""
        createPanel.orderFrontRegardless()
    }

    @objc func start(_ obj: NSMenuItem) {
        if (internalClock > 0) {
            internalClock = 0
            return
        }

        let date = Date().addingTimeInterval(1)
        let timer = Timer(fireAt: date, interval: 1, target: self, selector: #selector(incrementTimer(_:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoop.Mode.default)
    }

    @objc func incrementTimer(_ obj: NSMenuItem) {
        internalClock = internalClock + 1

        var seconds = internalClock
        if currentTimer != nil {
            let duration = Int(currentTimer!.1)! * 60
            seconds = duration - internalClock

            if seconds == 0  {
                var notification = NSUserNotification()
                notification.title = "Time expired"
                notification.informativeText = "The previst time is over"
                notification.soundName = NSUserNotificationDefaultSoundName
                NSUserNotificationCenter.default.deliver(notification)
            }
        }
        let (h,m) = secondsToHoursMinutesSeconds(seconds: seconds)

        var signal =  ""
        if (seconds < 0) {
            signal = "-"
        }
        statusBar.title = "\(signal)\(String(format: "%02d", abs(h))):\(String(format: "%02d", abs(m)))"
    }

    @objc func quit(_ obj: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }

    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60)
    }

}

