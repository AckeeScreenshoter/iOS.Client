//
//  Debuggable.swift
//  AssExample
//
//  Created by Marek Fořt on 11/23/18.
//

import UIKit

/// Conform to this protocol if you want present screenshot uploader
public protocol Debuggable: class {
    /// Setup screenshot uploader presentation with given gesture
    ///
    /// Gesture recognizer is action is added automatically to view hierarchy,
    /// also recognizer actions is added automatically
    func setupAss(gesture: UIGestureRecognizer?)
}

public extension Debuggable {
    /// Setup screenshot uploader presentation with default swipe up gesture
    ///
    /// On simulator use 2 finger swipe bottom to up, on device use 3 fingers
    func setupAss() {
        setupAss(gesture: nil)
    }
}

private enum Keys {
    static var wasSet = UInt8(0)
}

public extension Debuggable where Self: UIViewController {
    private var wasSet: Bool {
        get { return objc_getAssociatedObject(self, &Keys.wasSet) as? Bool ?? false }
        set { return objc_setAssociatedObject(self, &Keys.wasSet, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func setupAss(gesture: UIGestureRecognizer?) {
        guard !wasSet else { return }
        wasSet = true
        
        let gestureRecognizer = gesture ?? defaultGestureRecognizer()
        gestureRecognizer.onAction { [weak self] _ in self?.debugGestureMade() }
        view.addGestureRecognizer(gestureRecognizer)
    }

    private func debugGestureMade() {
        presentDebugController()
    }

    private func presentDebugController() {
        guard let screenshotViewController = createScreenshotViewController() else { return }
        
        let navVC = UINavigationController(rootViewController: screenshotViewController)
        navVC.isToolbarHidden = false
        present(navVC, animated: true, completion: nil)
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
        let screenshotViewModel = ScreenshotViewModel(dependencies: dependencies, screenshot: screenshot)
        let screenshotViewController = ScreenshotViewController(viewModel: screenshotViewModel)
        return screenshotViewController
    }

    private func defaultGestureRecognizer() -> UIGestureRecognizer {
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
