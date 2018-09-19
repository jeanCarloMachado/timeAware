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

    let databaseFile = "database.txt"

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


        let startItem = NSMenuItem()
        startItem.title = "Just Start"
        startItem.action = #selector(startClick(_:))
        menu.addItem(startItem)


        let addItem = NSMenuItem()
        addItem.title = "Add"
        addItem.action = #selector(showCreateModal(_:))
        menu.addItem(addItem)


        menu.addItem(NSMenuItem.separator())

        let entries = getDatabaseRows()

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

        let entries = getDatabaseRows()
        let title =  obj.title

        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.rightMouseUp{
            removeEntryFromDatabase(name: title)
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
         NSLog("handle create");

        let entry = pair2String(title: createName.stringValue,value: createDuration.stringValue)
        writeEntryToDatabase(entry: entry)

        createPanel.close()
        setupStatusMenu()

    }

    @objc func showCreateModal(_ obj: NSMenuItem) {
        createName.stringValue = ""
        createDuration.stringValue = ""
        createPanel.orderFrontRegardless()
    }

    @objc func startClick(_ obj: NSMenuItem) {
        currentTimer = nil
        start(obj)
    }

    @objc func start(_ obj: NSMenuItem) {
        if (internalClock > 0) {
            internalClock = 0
            return
        }

        let date = Date().addingTimeInterval(1)
        let timer = Timer(fireAt: date, interval: 1, target: self, selector: #selector(incrementTimer(_:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
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

        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: seconds)
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

    func pair2String(title: String, value: String) -> String {
        return "\(title),\(value)\n"
    }

    func removeEntryFromDatabase(name: String) {
        let content  = getDatabaseRows()

        let matches = content.filter {  $0.0 != name }

        let lines = matches.map { pair2String(title: $0.0, value: $0.1) }
        let  finalContent = lines.joined(separator: "")


        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(databaseFile)

            do {
                try finalContent.write(to: fileURL, atomically: true, encoding: .utf8)

            } catch {
                print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
            }
        }
    }


    func writeEntryToDatabase(entry: String) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(databaseFile)

            do {
                let fileHandle = try FileHandle(forWritingTo: fileURL)
                fileHandle.seekToEndOfFile()
                fileHandle.write(entry.data(using: .utf8)!)
                fileHandle.closeFile()

            } catch {
                print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
            }
        }
    }

    func getDatabaseRows() -> [(String, String)] {
        var text = ""
        do {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = dir.appendingPathComponent(databaseFile)
                text = try String(contentsOf: fileURL, encoding: .utf8)
            }
        } catch {
            print("error:", error)
        }

        let list = text.components(separatedBy: "\n")

        var result : [(String, String)] = [];
        for (index, element) in list.enumerated() {
            if element == "" {
                continue
            }
            let pair = element.components(separatedBy: ",")

            result.append((pair[0], pair[1]))
        }

        return result
    }

}

