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

protocol ScreenshotAPIServicing {
    func upload(screenshot: UIImage, appInfo: AppInfo, progress: ProgressBlock?, completion: @escaping (Result<Void, RequestError>) -> Void)
}

struct ScreenshotAPISercice: ScreenshotAPIServicing {
    private let operationQueue = OperationQueue()
    
    func upload(screenshot: UIImage, appInfo: AppInfo, progress: ProgressBlock?, completion: @escaping (Result<Void, RequestError>) -> Void) {
        let uploadOperation = UploadScreenshotOperation(screenshot: screenshot, appInfo: appInfo)
        
        uploadOperation.completionBlock = { [weak uploadOperation] in
            let result = uploadOperation?.result ?? .failure(.noData)
            completion(result.map { _ in })
        }
        
        operationQueue.addOperation(uploadOperation)
    }
}
