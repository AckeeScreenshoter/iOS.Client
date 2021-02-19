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
        public enum Section: String {
            case appInfo = "App"
            case deviceInfo = "Device"
            case customData = "Custom Data"
        }
        
        case platform
        case deviceMake
        case deviceModel
        case osVersion
        case bundleId
        case appVersion
        case buildNumber
        case appName
        case customData = ""
        
        public var value: String {
            switch self {
            case .platform:         return AppInfo.default.platform
            case .deviceMake:       return AppInfo.default.deviceMake
            case .deviceModel:      return AppInfo.default.deviceMode
            case .osVersion:        return AppInfo.default.osVersion
            case .bundleId:         return AppInfo.default.bundleId
            case .appVersion:       return AppInfo.default.appVersion
            case .buildNumber:      return AppInfo.default.buildNumber
            case .appName:          return AppInfo.default.appName
            case .customData:       return ""
            }
        }
        
        public var queryItems: [URLQueryItem] {
            switch self {
            case .customData:
                return AppInfo.default.customData.map { URLQueryItem(name: $0.key, value: $0.value) }
            default:
                return [URLQueryItem(name: self.rawValue, value: self.value)]
            }
        }
        
        public var section: Section {
            switch self {
            case .platform,
                 .deviceMake,
                 .deviceModel,
                 .osVersion:        return .deviceInfo
            case .appName,
                 .bundleId,
                 .appVersion,
                 .buildNumber:          return .appInfo
            default:                return .customData
            }
        }
    }
    
    public static var `default`: AppInfo = AppInfo()
    
    public var platform:    String        = "ios"
    public var deviceMake:  String        = "Apple"
    public var deviceMode:  String        = UIDevice.modelIdentifier + " (" + UIDevice.modelName + ")"
    public var osVersion:   String        = UIDevice.current.systemVersion
    public var bundleId:    String        = Bundle.main.bundleIdentifier ?? ""
    public var appVersion:  String        = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? ""
    public var buildNumber: String        = (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? ""
    public var appName:     String        = (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? ""
    /// Custom data that are appended to default information
    public var customData:  CustomData    = [:]
    
    public var queryItems: [URLQueryItem] {
        Info.allCases.flatMap { $0.queryItems }
    }
}
