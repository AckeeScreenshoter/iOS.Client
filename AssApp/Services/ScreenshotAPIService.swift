//
//  ScreenshotAPIService.swift
//  Ass
//
//  Created by Jakub Olejník on 24/11/2018.
//

import UIKit

enum RequestError: Error {
    case network(Error)
    case noData
}

protocol HasScreenshotAPI {
    var screenshotAPI: ScreenshotAPIServicing { get }
}

protocol ScreenshotAPIServicing {
    
    func createUploadOperation(screenshot: UIImage?, recordURL: URL?, appInfo: [String: String], baseURL: URL?, authorization: String?) -> UploadMultipartDataOperation?
}

struct ScreenshotAPIService: ScreenshotAPIServicing {
        
    func createUploadOperation(
        screenshot: UIImage? = nil,
        recordURL: URL? = nil,
        appInfo: [String: String],
        baseURL: URL?,
        authorization: String?
    ) -> UploadMultipartDataOperation? {
        guard
            let baseURL = baseURL,
            let authorization = authorization
            else { return nil }
        
        
        if let screenshot = screenshot {
            return UploadMultipartDataOperation(screenshot: screenshot, appInfo: appInfo, baseURL: baseURL, authorization: authorization)
        }
        
        if let recordURL = recordURL {
            return UploadMultipartDataOperation(recordURL: recordURL, appInfo: appInfo, baseURL: baseURL, authorization: authorization)
        }
        
        return nil
    }
}
