//
//  AppInfo.swift
//  Ass
//
//  Created by Jakub Olejník on 23/11/2018.
//

import UIKit

public typealias CustomData = [String: String]

struct AppInfo: Encodable {
    enum CodingKeys: String, CodingKey {
        case platform
        case deviceMake
        case deviceModel
        case osVersion
        case bundleID
        case appVersion
        case buildNumber
        case appName
        case note
        case customData
    }
    
    static var `default`: AppInfo {
        return AppInfo(note: nil, customData: Ass.customData)
    }
    
    let platform = "ios"
    let deviceMake = "Apple"
    let deviceModel = UIDevice.modelIdentifier + " (" + UIDevice.modelName + ")"
    let osVersion = UIDevice.current.systemVersion
    let bundleID = Bundle.main.bundleIdentifier ?? ""
    let appVersion = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? ""
    let buildNumber = (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String).map { Int($0)! }
    let appName = (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? ""
    let note: String?
    let customData: CustomData
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(platform, forKey: .platform)
        try container.encode(deviceMake, forKey: .deviceMake)
        try container.encode(deviceModel, forKey: .deviceModel)
        try container.encode(osVersion, forKey: .osVersion)
        try container.encode(bundleID, forKey: .bundleID)
        try container.encode(appVersion, forKey: .appVersion)
        try container.encode(buildNumber, forKey: .buildNumber)
        try container.encode(appName, forKey: .appName)
        try container.encodeIfPresent(note, forKey: .note)
        
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
            ("App version", appVersion),
            ("Build", buildNumber.map { String($0) } ?? ""),
            ("Bundle ID", bundleID),
        ] + customData
    }
}
