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
    var currentClock : Int = 0;

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusMenu()

        createButton.action = #selector(handleCreate(_:))

    }
    func setupStatusMenu() {
        statusBar.title = "00:00"

        let menu = NSMenu()
        menu.autoenablesItems = true


        let startItem = NSMenuItem()
        startItem.title = "Start"
        startItem.action = #selector(start(_:))
        menu.insertItem(startItem, at: 0)


        let addItem = NSMenuItem()
        addItem.title = "Add"
        addItem.action = #selector(showCreateModal(_:))
        menu.insertItem(addItem, at: 1)


        let content = getDatabaseContent()
        let entries = content.components(separatedBy: "\n")

        var outIndex = 2
        for (index, element) in entries.enumerated() {
            if element == "" {
                break
            }
            outIndex = outIndex  + index
            let columns = element.components(separatedBy: ",")
            let menuItem = NSMenuItem()
            menuItem.title = columns[0]
            menu.insertItem(menuItem, at: outIndex)
        }

        let quitItem = NSMenuItem()
        quitItem.title = "Quit"
        quitItem.action = #selector(quit(_:))
        menu.insertItem(quitItem, at: outIndex + 1)

        statusBar.menu = menu
    }


    @objc func handleCreate(_ obj: NSMenuItem) {
         NSLog("handle create");

        let entry = "\(createName.stringValue),\(createDuration.stringValue)\n"
        writeEntryToDatabase(entry: entry)

        setupStatusMenu()
        createPanel.close()
    }


    @objc func showCreateModal(_ obj: NSMenuItem) {
        createPanel.orderFrontRegardless()
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

    func getDatabaseContent() -> String {
        var text = ""
        do {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = dir.appendingPathComponent(databaseFile)
                text = try String(contentsOf: fileURL, encoding: .utf8)
            }
        } catch {
            print("error:", error)
        }

        return text
    }

}

