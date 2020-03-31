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
    func upload() -> UploadMultipartDataOperation
}

struct ScreenshotAPIService: ScreenshotAPIServicing {
    func upload() -> UploadMultipartDataOperation  {
        return UploadMultipartDataOperation()
    }
}
