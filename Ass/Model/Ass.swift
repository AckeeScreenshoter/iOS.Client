//
//  Ass.swift
//  Ass
//
//  Created by Jakub Olejník on 24/11/2018.
//

import Foundation

/// Enum for setting shared configuration
public enum Ass {
    /// Authorization header for communication with API
    public static var authorization: String?
    
    /// BaseURL for sending data
    public static var baseURL: URL?
    
    /// Custom data that are appended to default information
    public static var customData = CustomData()
    
    internal static var missingFields: [String] {
        if baseURL == nil { return ["baseURL"] }
        return []
    }
}
