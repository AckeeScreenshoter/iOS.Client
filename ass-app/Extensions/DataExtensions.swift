//
//  DataExtensions.swift
//  Ass
//
//  Created by Jakub Olejník on 24/11/2018.
//

import Foundation

extension Data {
    mutating func appendString(_ string: String) {
        append(string.data(using: .utf8)!)
    }
}
