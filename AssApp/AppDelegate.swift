//
//  AppDelegate.swift
//  ass-app
//
//  Created by Vendula Švastalová on 26/03/2020.
//  Copyright © 2020 Vendula Švastalová. All rights reserved.
//

import UIKit
import FirebaseCrashlytics
import FirebaseCore
import AssCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    var screenShotViewModel: ScreenshotViewModel?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureCrashlytics()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        // The app was not launched by opening url
        if launchOptions == nil {
            let vc = EmptyViewController()
            window?.rootViewController = vc
        } else {
            setupScreenshotVC(in: window)
        }
        
        showAnimatedSplashScreen()
        
        return true
    }
    
    private func showAnimatedSplashScreen() {
        let splashScreen = SplashScreen()
        splashScreen.animateAfterLaunch(in: window?.rootViewController?.view)
    }
    
    private func setupScreenshotVC(in window: UIWindow?) {
        let vm = ScreenshotViewModel(dependencies: dependencies)
        screenShotViewModel = vm
        
        let vc = ScreenshotViewController(viewModel: vm)
        window?.rootViewController = vc
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // The app is already launched but not through url from opening app.
        // EmptyViewController is currently the root so ScreenshotViewController has to be set as the root
        if screenShotViewModel == nil {
            setupScreenshotVC(in: window)
        }
        
        guard
            var queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
            let mediaString = queryItems.first(where: { $0.name == Constants.QueryItemKey.media })?.value,
            let authorization = queryItems.first(where: { $0.name == Constants.QueryItemKey.authorization })?.value,
            let baseURL = queryItems.first(where: { $0.name == Constants.QueryItemKey.baseURL })?.value,
            let scheme = queryItems.first(where: { $0.name == Constants.QueryItemKey.scheme })?.value,
            let media = Media(string: mediaString)
            else { return false }
            
        queryItems.removeAll {
            $0.name == Constants.QueryItemKey.authorization ||
            $0.name == Constants.QueryItemKey.baseURL ||
            $0.name == Constants.QueryItemKey.media
        }
        
        screenShotViewModel?.media = media
        screenShotViewModel?.authorization = authorization
        screenShotViewModel?.scheme = scheme
        screenShotViewModel?.baseURL = URL(string: baseURL)
        screenShotViewModel?.appInfo = Dictionary(queryItems.map { ($0.name, $0.value ?? "") }) { $1 }
 
        return true
    }
    
    private func configureCrashlytics() {
        FirebaseApp.configure()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        registerDefaultsFromSettingsBundle()
    }
    
    private func registerDefaultsFromSettingsBundle() {
        guard
            let settingsBundleURL = Bundle.main.url(forResource: "Settings", withExtension: "bundle"),
            let settingsData = try? Data(contentsOf: settingsBundleURL.appendingPathComponent("Root.plist")),
            let settingsPlist = try? PropertyListSerialization.propertyList(
                from: settingsData,
                options: [],
                format: nil) as? [String: Any],
            let settingsPreferences = settingsPlist["PreferenceSpecifiers"] as? [[String: Any]] else {
                return
        }

        var defaultsToRegister = [String: Any]()

        settingsPreferences.forEach { preference in
            if let key = preference["Key"] as? String {
                defaultsToRegister[key] = preference["DefaultValue"]
            }
        }

        UserDefaults.standard.register(defaults: defaultsToRegister)
    }
}

