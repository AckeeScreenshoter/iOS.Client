//
//  Debuggable.swift
//  AssExample
//
//  Created by Marek Fořt on 11/23/18.
//

import UIKit

protocol Debuggable {
    func setup()
    func presentDebugController()
}

extension UIViewController: Debuggable {
    func setup() {
        // TODO: Handle "double set-up"
        let gestureRecognizer = defaultGestureRecognizer()
        gestureRecognizer.addTarget(self, action: #selector(debugGestureMade))
        view.addGestureRecognizer(gestureRecognizer)
    }

    @objc func debugGestureMade() {
        presentDebugController()
    }

    func presentDebugController() {
        // TODO: Present debug view controller
    }

    private func defaultGestureRecognizer() -> UIGestureRecognizer {
        // TODO: Swipe gesture recognzer?
        // Use 2 touches in simulator to be able to use "Alt + tap" gesture
        #if targetEnvironment(simulator)
        let touches = 2
        #else
        let touches = 3
        #endif

        let gesture = UITapGestureRecognizer()
        gesture.numberOfTouchesRequired = touches
        return gesture
    }
}
