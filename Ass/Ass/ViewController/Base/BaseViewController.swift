//
//  BaseViewController.swift
//  Ass
//
//  Created by Jakub Olejník on 23/11/2018.
//

import UIKit

/// Base class for all view controllers contained in app.
class BaseViewController: UIViewController {
    static var logEnabled: Bool = true
    
    private var firstWillAppearOccured = false
    private var firstDidAppearOccured = false
    
    // MARK: Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        if BaseViewController.logEnabled {
            NSLog("📱 👶 \(self)")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: View life cycle
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !firstWillAppearOccured {
            viewWillFirstAppear(animated)
            firstWillAppearOccured = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !firstDidAppearOccured {
            viewDidFirstAppear(animated)
            firstDidAppearOccured = true
        }
    }
    
    /// Method is called when `viewWillAppear(_:)` is called for the first time
    func viewWillFirstAppear(_ animated: Bool) {
        
    }
    
    /// Method is called when `viewDidAppear(_:)` is called for the first time
    func viewDidFirstAppear(_ animated: Bool) {
        
    }
    
    deinit {
        if BaseViewController.logEnabled {
            NSLog("📱 ⚰️ \(self)")
        }
    }
}
