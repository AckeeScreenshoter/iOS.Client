//
//  ViewController.swift
//  AssExample
//
//  Created by Jakub Olejník on 23/11/2018.
//

import UIKit
import Ass

final class ViewController: BaseViewController, Debuggable {
 
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard case .motionShake = motion else { return }
        presentDebugController()
    }
    
    @IBAction func testAlertTapped(_ sender: UIButton) {
        let alertVC = UIAlertController(title: "Test alert", message: "Message", preferredStyle: .alert)
        let close = UIAlertAction(title: "Close", style: .default)
        alertVC.addAction(close)
        present(alertVC, animated: true)
    }
}
