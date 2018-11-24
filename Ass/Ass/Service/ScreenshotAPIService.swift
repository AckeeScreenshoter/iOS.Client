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

struct APIService {
    func upload(screenshot: UIImage, appInfo: AppInfo, completion: @escaping (Result<Void, RequestError>) -> Void) {
    }
}
