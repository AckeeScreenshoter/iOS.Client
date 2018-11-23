//
//  AppInfo.swift
//  Ass
//
//  Created by Jakub Olejník on 23/11/2018.
//

import Foundation

struct AppInfo: Encodable {
    enum CodingKeys: String, CodingKey {
        case platform
        case osVersion
        case bundleID
        case appName
        case date
        case customData
    }
    
    let platform = "ios"
    let osVersion: String
    let bundleID: String
    let appName: String
    let date = Date()
    let customData: [String: Encodable]
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let customDataData = try JSONSerialization.data(withJSONObject: customData, options: .prettyPrinted)
        
        try container.encode(platform, forKey: .platform)
        try container.encode(osVersion, forKey: .osVersion)
        try container.encode(bundleID, forKey: .bundleID)
        try container.encode(appName, forKey: .appName)
        try container.encode(date.timeIntervalSince1970, forKey: .date)
        try container.encode(customDataData, forKey: .customData)
    }
}
