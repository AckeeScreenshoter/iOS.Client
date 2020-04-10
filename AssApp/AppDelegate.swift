//
//  AppDelegate.swift
//  ass-app
//
//  Created by Vendula Švastalová on 26/03/2020.
//  Copyright © 2020 Vendula Švastalová. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    var screenShotViewModel: ScreenshotViewModel?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        let vm = ScreenshotViewModel(dependencies: dependencies)
        screenShotViewModel = vm
        
        let vc = ScreenshotViewController(viewModel: vm)
        window?.rootViewController = vc
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard
            var queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
            let mediaTypeString = queryItems.first(where: { $0.name == Constants.QueryItemKey.mediaType })?.value,
            let authorization = queryItems.first(where: { $0.name == Constants.QueryItemKey.authorization })?.value,
            let baseURL = queryItems.first(where: { $0.name == Constants.QueryItemKey.baseURL })?.value,
            let mediaType = MediaType(rawValue: mediaTypeString)
            else { return true }
            
        queryItems.removeAll {
            $0.name == Constants.QueryItemKey.authorization ||
            $0.name == Constants.QueryItemKey.baseURL ||
            $0.name == Constants.QueryItemKey.mediaType
        }
        
        screenShotViewModel?.mediaType = mediaType
        screenShotViewModel?.authorization = authorization
        screenShotViewModel?.baseURL = URL(string: baseURL)
        screenShotViewModel?.appInfo = Dictionary(queryItems.map { ($0.name, $0.value ?? "") }) { $1 }
        
        return true
    }
}

