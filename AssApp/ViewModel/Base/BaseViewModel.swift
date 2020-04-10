//
//  BaseViewModel.swift
//  Ass
//
//  Created by Jakub Olejník on 23/11/2018.
//

import Foundation

/// Base class for all view models contained in app.
class BaseViewModel: NSObject {
    
    static var logEnabled: Bool = true
    
    override init() {
        super.init()
        
        if BaseViewModel.logEnabled {
            NSLog("🧠 👶 \(self)")
        }
    }
    
    deinit {
        if BaseViewModel.logEnabled {
            NSLog("🧠 ⚰️ \(self)")
        }
    }
}
