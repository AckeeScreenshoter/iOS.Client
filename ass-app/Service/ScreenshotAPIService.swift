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
    var uploadOperation: UploadMultipartDataOperation { get }
}

struct ScreenshotAPIService: ScreenshotAPIServicing {
    var uploadOperation: UploadMultipartDataOperation {
        UploadMultipartDataOperation()
    }
}
