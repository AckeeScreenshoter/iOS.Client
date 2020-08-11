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
    
    func createUploadOperation(media: Media, appInfo: [String: String], baseURL: URL?, authorization: String?) -> UploadMultipartDataOperation?
}

struct ScreenshotAPIService: ScreenshotAPIServicing {
        
    func createUploadOperation(
        media: Media,
        appInfo: [String: String],
        baseURL: URL?,
        authorization: String?
    ) -> UploadMultipartDataOperation? {
        guard
            let baseURL = baseURL,
            let authorization = authorization
            else { return nil }
        
        return UploadMultipartDataOperation(media: media, appInfo: appInfo, baseURL: baseURL, authorization: authorization)
    }
}
