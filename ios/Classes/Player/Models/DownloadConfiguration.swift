//
//  DownloadConfiguration.swift
//  udevs_video_player
//
//  Created by Udevs on 23/11/22.
//

import Foundation

struct DownloadConfiguration {
    var url: String
    var percent: Int
    var state: Int
    
    init(url: String, percent: Int, state: Int) {
        self.url = url
        self.percent = percent
        self.state = state
    }
    
    static let STATE_QUEUED = 0
    static let STATE_STOPPED = 1
    static let STATE_DOWNLOADING = 2
    static let STATE_COMPLETED = 3
    static let STATE_FAILED = 4
    static let STATE_REMOVING = 5
    static let STATE_RESTARTING = 7
    
    static func fromMap(map : [String:Any]) -> DownloadConfiguration {
        return DownloadConfiguration(url: map["url"] as! String, percent: map["percent"] as! Int, state: 0)
    }
    
    func fromString() -> String {
        do {
            let data1 = try JSONSerialization.data(withJSONObject: ["url": url, "percent":percent, "state" : state], options: JSONSerialization.WritingOptions.prettyPrinted)
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) ?? ""
            return convertedString
        } catch _ {
            return ""
        }
    }
}
