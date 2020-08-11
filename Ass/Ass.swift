//
//  Ass.swift
//  Ass
//
//  Created by Vendula Švastalová on 26/03/2018.
//

import UIKit

public class Ass: NSObject {
    
    public static let shared = Ass()
    
    /// Authorization header for communication with API
    public var authorization: String?
    
    /// BaseURL for sending data
    public var baseURL: URL?
    
    /// Information about the application, device and  custom user defined information
    ///
    /// Information about the device and application all have default values.
    /// All the information can be changed if needed.
    public var appInfo: AppInfo = AppInfo.default
    
    /// Needs to be set to `true` in order for Screenshotter actions to be detected.
    public var isEnabled: Bool = false {
        didSet(wasEnabled) {
            if isEnabled && !wasEnabled {
                addObservers()
            } else if !isEnabled && wasEnabled {
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
    
    /// URL scheme defined in Project Settings - Info
    private var scheme: String? {
        guard
            let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: AnyObject]],
            let urlType = urlTypes.first(where: { return ($0["CFBundleURLName"] as? String) == "AckeeScreenshotter" }),
            let scheme = (urlType["CFBundleURLSchemes"] as? [String])?.first
            else { return nil }
                
        return scheme
    }
    
    /// Adds observer to UIScreen for detecting video capturing
    /// Adds observer for `.userDidTakeScreenshotNotification` to the `NotificationCentre`
    private func addObservers() {
        UIScreen.main.addObserver(self, forKeyPath: capturedKeyPath, options: .new, context: nil)
    
        let screenshotObserver = NotificationCenter.default.addObserver(forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: OperationQueue.main) { [weak self] notification in
            guard let self = self else { return }
            guard let url = self.createDeeplink(for: .screenshot(nil)) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        self.screenshotObserver = screenshotObserver
    }
    
    /// Removes observer from UIScreen to stop detecting video capturing
    /// Removes notification for `.userDidTakeScreenshotNotification`
    private func removeObservers() {
        UIScreen.main.removeObserver(self, forKeyPath: capturedKeyPath, context: nil)
        
        guard let observer = screenshotObserver else { return }
        NotificationCenter.default.removeObserver(observer, name: UIApplication.userDidTakeScreenshotNotification, object: nil)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == capturedKeyPath) {
            if #available(iOS 11.0, *) {
                let isCaptured = UIScreen.main.isCaptured
                if !isCaptured && isBeingCaptured { // currently is not being captured but was
                    isBeingCaptured = isCaptured
                    ShowTime.isEnabled = false
                    guard let url = self.createDeeplink(for: .record(nil)) else { return }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    return
                } else if isCaptured && !isBeingCaptured { // currently is being captured bu was not
                    ShowTime.isEnabled = true
                }

                isBeingCaptured = isCaptured
            }
        }
    }
    
    /// Creates deeplink for opening Ass application
    ///
    /// Takes all the data that are currently stored in Ass and adds them to the URL as `[URLQueryItems]`
    private func createDeeplink(for media: Media) -> URL? {
        guard let baseURL = baseURL, let authorization = authorization else { return nil }
        let mediaQueryItem = URLQueryItem(name: Constants.QueryItemKey.media, value: media.id)
        let baseURLQueryItem = URLQueryItem(name: Constants.QueryItemKey.baseURL, value: baseURL.absoluteString)
        let authorizationQueryItem = URLQueryItem(name: Constants.QueryItemKey.authorization, value: authorization)
        let schemeQueryItem = URLQueryItem(name: Constants.QueryItemKey.scheme, value: scheme)
        var urlComponents = URLComponents(string: "")
        urlComponents?.queryItems = appInfo.queryItems + [mediaQueryItem, baseURLQueryItem, authorizationQueryItem, schemeQueryItem]
        urlComponents?.scheme = Constants.URLComponent.scheme
        urlComponents?.host = Constants.URLComponent.host
        return urlComponents?.url
    }
}

