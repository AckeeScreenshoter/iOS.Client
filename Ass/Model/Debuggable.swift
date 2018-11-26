//
//  Debuggable.swift
//  AssExample
//
//  Created by Marek Fořt on 11/23/18.
//

import UIKit

/// Conform to this protocol if you want present screenshot uploader
public protocol Debuggable: class { }

private enum Keys {
    static var wasSet = UInt8(0)
    static var window = UInt8(1)
}

public extension Debuggable {
    private var window: UIWindow? {
        get { return objc_getAssociatedObject(self, &Keys.window) as? UIWindow }
        set { objc_setAssociatedObject(self, &Keys.window, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var wasSet: Bool {
        get { return objc_getAssociatedObject(self, &Keys.wasSet) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &Keys.wasSet, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    public func presentDebugController() {
        guard self.window == nil, let screenshotViewController = createScreenshotViewController() else { return }
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.isHidden = false
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        self.window = window
        
        let navVC = UINavigationController(rootViewController: screenshotViewController)
        navVC.isToolbarHidden = false
        window.rootViewController?.present(navVC, animated: true, completion: nil)
    }

    private func createScreenshotViewController() -> ScreenshotViewController? {
        guard let screenshot = getScreenshot() else { return nil }
        let screenshotVM = ScreenshotViewModel(dependencies: dependencies, screenshot: screenshot)
        let screenshotVC = ScreenshotViewController(viewModel: screenshotVM)
        screenshotVC.closeCallback = { [weak self] in self?.window = nil }
        return screenshotVC
    }
    
    private func getScreenshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIApplication.shared.windows.forEach { $0.layer.render(in: context)}
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenshot
    }
}
