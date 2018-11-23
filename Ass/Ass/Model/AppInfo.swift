//
//  AppInfo.swift
//  Ass
//
//  Created by Jakub Olejník on 23/11/2018.
//

import UIKit

typealias CustomData = [String: String]

struct AppInfo: Encodable {
    enum CodingKeys: String, CodingKey {
        case platform
        case device
        case osVersion
        case bundleID
        case appName
        case date
        case customData
    }
    
    static var customData = CustomData()
    
    static var `default`: AppInfo {
        let osVersion = UIDevice.current.systemVersion
        let device = UIDevice.current.model + " (" + UIDevice.current.localizedModel + ")"
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let appName = (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? ""
        
        return AppInfo(device: device, osVersion: osVersion, bundleID: bundleID, appName: appName, customData: customData)
    }
    
    let platform = "ios"
    let device: String
    let osVersion: String
    let bundleID: String
    let appName: String
    let date = Date()
    let customData: CustomData
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let customDataData = try JSONSerialization.data(withJSONObject: customData, options: .prettyPrinted)
        
        try container.encode(platform, forKey: .platform)
        try container.encode(device, forKey: .device)
        try container.encode(osVersion, forKey: .osVersion)
        try container.encode(bundleID, forKey: .bundleID)
        try container.encode(appName, forKey: .appName)
        try container.encode(date.timeIntervalSince1970, forKey: .date)
        try container.encode(customDataData, forKey: .customData)
    }
}

extension AppInfo: Equatable {
    static func==(lhs: AppInfo, rhs: AppInfo) -> Bool {
        let encoder = JSONEncoder()
        
        do {
            let lhsEncoded = try encoder.encode(lhs)
            let rhsEncoded = try encoder.encode(rhs)
            return lhsEncoded == rhsEncoded
        }
        catch {
            return false
        }
    }
}

extension AppInfo {
    var keyValueItems: [(key: String, value: String)] {
        return [
            ("Device", device),
            ("OS version", osVersion),
            ("App name", appName),
            ("Bundle ID", bundleID),
        ] + customData
    }
}
