import Cocoa

func appendLineToCSV(entry: String, destinationFile: String) {
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = dir.appendingPathComponent(destinationFile)

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

func getCSVRows(destinationFile: String) -> [(String, String)] {
    var text = ""
    do {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(destinationFile)
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


func removeEntryFromDatabase(name: String, destinationFile: String) {
    let content  = getCSVRows(destinationFile: destinationFile)

    let matches = content.filter {  $0.0 != name }

    let lines = matches.map { pair2String(title: $0.0, value: $0.1) }
    let  finalContent = lines.joined(separator: "")

    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = dir.appendingPathComponent(destinationFile)

        do {
            try finalContent.write(to: fileURL, atomically: true, encoding: .utf8)

        } catch {
            print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
        }
    }
}

func pair2String(title: String, value: String) -> String {
    return "\(title),\(value)\n"
}
