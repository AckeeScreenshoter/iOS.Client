//
//  Ass.swift
//  Ass
//
//  Created by Jakub Olejník on 24/11/2018.
//

import UIKit

///// Enum for setting shared configuration
//public enum Ass {
//    /// Authorization header for communication with API
//    public static var authorization: String?
//
//    /// BaseURL for sending data
//    public static var baseURL: URL?
//
//    /// Custom data that are appended to default information
//    public static var customData = CustomData()
//
//    internal static var missingFields: [String] {
//        if baseURL == nil { return ["baseURL"] }
//        return []
//    }
//}

public class Ass: NSObject {
    
    public static let shared = Ass()
    
    /// Authorization header for communication with API
    public var authorization: String?
    
    /// BaseURL for sending data
    public var baseURL: URL?
    
    public let appInfo: AppInfo = AppInfo.default
    
    public var enable: Bool = false {
        didSet {
            print("enable \(enable)")
            if enable && !oldValue {
                print("adding ovserver")
                addObservers()
            } else if !enable && oldValue {
                print("removing observer")
                removeObservers()
            }
        }
    }
    
    /// Observes for `.userDidTakeScreenshotNotification`
    private var screenshotObserver: NSObjectProtocol?
    
    /// Keypath for `UIScreen observer`
    private let capturedKeyPath = "captured"
    
    /// Indicates whether the screen is currently being captured
    private var isBeingCaptured = false
    
    private func addObservers() {
        UIScreen.main.addObserver(self, forKeyPath: capturedKeyPath, options: .new, context: nil)
    
        let screenshotObserver = NotificationCenter.default.addObserver(forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: OperationQueue.main) { [weak self] notification in
            guard let self = self else { return }
            print("creating url for screenshot")
            let string = self.createDeeplink(for: .screenshot)
            print("string \(string)")
            let url = URL(string: string)!
            print("url for screenshot \(url)")
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        self.screenshotObserver = screenshotObserver
    }
    
    private func removeObservers() {
        UIScreen.main.removeObserver(self, forKeyPath: capturedKeyPath, context: nil)
        guard let observer = screenshotObserver else { return }
        NotificationCenter.default.removeObserver(observer, name: UIApplication.userDidTakeScreenshotNotification, object: nil)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == capturedKeyPath) {
            if #available(iOS 11.0, *) {
                let isCaptured = UIScreen.main.isCaptured
                if !isCaptured && isBeingCaptured {
                    isBeingCaptured = isCaptured
                    print("creating url for record")
                    let url = URL(string: createDeeplink(for: .recording))!
                    print("url for record \(url)")
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    return
                }

                isBeingCaptured = isCaptured
            }
        }
    }
    
    private func createDeeplink(for mediaType: MediaType) -> String {
        let mediaTypeString = mediaType.rawValue
        print("medita type string \(mediaTypeString)")
        let appInfoString = appInfo.toHeader
        print("app info string \(appInfoString)")
        return "ass-app://ass.com?mediaType=" + mediaTypeString + "&" + appInfoString
    }
}

