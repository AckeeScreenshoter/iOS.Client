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
        guard let screenshotViewController = createScreenshotViewController() else { return }
        present(screenshotViewController, animated: true, completion: nil)
    }

    private func createScreenshotViewController() -> ScreenshotViewController? {
        // TODO: Error handling
        guard let window = UIApplication.shared.keyWindow else { return nil }
        let layer = window.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        guard let screenshot = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        let screenshotViewModel = ScreenshotViewModel(dependencies: Dependency(), screenshot: screenshot)
        let screenshotViewController = ScreenshotViewController(viewModel: screenshotViewModel)
        return screenshotViewController
    }

    private func defaultGestureRecognizer() -> UIGestureRecognizer {
        // TODO: Swipe gesture recognzer?
        // Use 2 touches in simulator to be able to use "Alt + tap" gesture
        #if targetEnvironment(simulator)
        let touches = 2
        #else
        let touches = 3
        #endif

        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .up
        gesture.numberOfTouchesRequired = touches
        return gesture
    }
}

struct Dependency: HasNoDependency {

}
