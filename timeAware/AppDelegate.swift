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
        menu.insertItem(startItem, at: 0)


        let addItem = NSMenuItem()
        addItem.title = "Add"
        addItem.action = #selector(showCreateModal(_:))
        menu.insertItem(addItem, at: 1)


        let entries = getDatabaseRows()

        var outIndex = 2
        for (index, element) in entries.enumerated() {
            outIndex = outIndex + 1
            let menuItem = NSMenuItem()
            menuItem.title = element.0
            menuItem.action = #selector(handleStart(_:))
            menu.addItem(menuItem)
        }

        let quitItem = NSMenuItem()
        quitItem.title = "Quit"
        quitItem.action = #selector(quit(_:))
        menu.addItem(quitItem)

        statusBar.menu = menu
    }

    @objc func handleStart(_ obj: NSMenuItem) -> Void {
        let title =  obj.title

        let entries = getDatabaseRows()

        let match = entries.filter {  $0.0 == title }

        if (match[0] != nil) {
            currentTimer = match[0]
        }

        NSLog(match[0].1)
        start(obj)
    }

    @objc func handleCreate(_ obj: NSMenuItem) {
         NSLog("handle create");

        let entry = "\(createName.stringValue),\(createDuration.stringValue)\n"
        writeEntryToDatabase(entry: entry)

        createPanel.close()
        setupStatusMenu()
    }

    @objc func showCreateModal(_ obj: NSMenuItem) {
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

