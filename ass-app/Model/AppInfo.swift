//
//  AppInfo.swift
//  Ass
//
//  Created by Vendula Švastalová on 08/04/2020.
//  Copyright © 2020 Vendula Švastalová. All rights reserved.
//

import UIKit

public typealias CustomData = [String: String]

public struct AppInfo {
    public enum Info: String, CaseIterable {
        case platform
        case deviceMake
        case deviceModel
        case osVersion
        case bundleId
        case appVersion
        case buildNumber
        case appName
        case customData = ""
        
        var value: String {
            switch self {
            case .platform:         return AppInfo.default.platform
            case .deviceMake:       return AppInfo.default.deviceMake
            case .deviceModel:      return AppInfo.default.deviceMode
            case .osVersion:        return AppInfo.default.osVersion
            case .bundleId:         return AppInfo.default.bundleId
            case .appVersion:       return AppInfo.default.appVersion
            case .buildNumber:      return AppInfo.default.buildNumber
            case .appName:          return AppInfo.default.appName
            case .customData:       return AppInfo.default.customData.map { $0.key + "=" + $0.value }.joined(separator: "&")
            }
        }
    }
    
    static var `default`: AppInfo = AppInfo()
    
    public var platform: String          = "ios"
    public var deviceMake: String        = "Apple"
    public var deviceMode: String        = UIDevice.modelIdentifier + " (" + UIDevice.modelName + ")"
    public var osVersion: String         = UIDevice.current.systemVersion
    public var bundleId: String          = Bundle.main.bundleIdentifier ?? ""
    public var appVersion: String        = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? ""
    public var buildNumber: String       = (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? ""
    public var appName: String           = (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? ""
    /// Custom data that are appended to default information
    public var customData: CustomData    = [:]
    
    var toHeader: String {
        Info.allCases.map {
            // check made because of customData formatting
            $0.rawValue.isEmpty ? $0.value : $0.rawValue + "=" + $0.value
        }.joined(separator: "&")
    }
}
