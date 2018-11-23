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
        case deviceMake
        case deviceModel
        case osVersion
        case bundleID
        case appName
        case date
        case customData
    }
    
    static var customData = CustomData()
    
    static var `default`: AppInfo {
        let osVersion = UIDevice.current.systemVersion
        let device = UIDevice.modelIdentifier + " (" + UIDevice.modelName + ")"
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let appName = (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? ""
        
        return AppInfo(deviceModel: device, osVersion: osVersion, bundleID: bundleID, appName: appName, customData: customData)
    }
    
    let platform = "ios"
    let deviceMake = "Apple"
    let deviceModel: String
    let osVersion: String
    let bundleID: String
    let appName: String
    let date = Date()
    let customData: CustomData
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(platform, forKey: .platform)
        try container.encode(deviceMake, forKey: .deviceMake)
        try container.encode(deviceModel, forKey: .deviceModel)
        try container.encode(osVersion, forKey: .osVersion)
        try container.encode(bundleID, forKey: .bundleID)
        try container.encode(appName, forKey: .appName)
        try container.encode(date.timeIntervalSince1970, forKey: .date)
        
        if !customData.isEmpty {
            try container.encode(customData, forKey: .customData)
        }
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

extension AppInfo: CustomStringConvertible {
    var description: String {
        return keyValueItems.map { $0 + " " + $1 }.joined(separator: ",")
    }
}

extension AppInfo {
    var keyValueItems: [(key: String, value: String)] {
        return [
            ("Device", deviceModel),
            ("OS version", osVersion),
            ("App name", appName),
            ("Bundle ID", bundleID),
        ] + customData
    }
}
