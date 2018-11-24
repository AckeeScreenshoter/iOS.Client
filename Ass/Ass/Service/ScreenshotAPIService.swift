//
//  ScreenshotAPIService.swift
//  Ass
//
//  Created by Jakub Olejník on 24/11/2018.
//

import Foundation

enum RequestError: Error {
    case network(Error)
    case noData
}

protocol HasScreenshotAPI {
    var screenshotAPI: ScreenshotAPIServicing { get }
}

protocol ScreenshotAPIServicing {
    func upload(screenshot: UIImage, appInfo: AppInfo) -> UploadScreenshotOperation
}

struct ScreenshotAPIService: ScreenshotAPIServicing {
    func upload(screenshot: UIImage, appInfo: AppInfo) -> UploadScreenshotOperation  {
        return UploadScreenshotOperation(screenshot: screenshot, appInfo: appInfo)
    }
}
