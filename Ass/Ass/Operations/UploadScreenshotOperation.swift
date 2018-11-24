//
//  UploadScreenshotOperation.swift
//  Ass
//
//  Created by Jakub Olejník on 24/11/2018.
//

import UIKit

final class UploadScreenshotOperation: URLRequestOperation {
    
    let screenshot: UIImage
    let appInfo: AppInfo
    
    // MARK: - Initializers
    
    init(screenshot: UIImage, appInfo: AppInfo) {
        self.screenshot = screenshot
        self.appInfo = appInfo
        super.init(request: UploadScreenshotOperation.createRequest(for: screenshot, appInfo: appInfo))
    }
    
    // MARK: - Private helpers
    
    private static func createRequest(for screenshot: UIImage, appInfo: AppInfo) -> URLRequest {
        let url = URL(string: "https://requestbin.fullcontact.com/1aoiaq11")!
        let boundary = "cz.ackee.enterprise.ass"
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=" + boundary, forHTTPHeaderField: "Content-Type")
        
        let closeBoundaryData = ("--" + boundary + "--\r\n").data(using: .utf8)!
        
        let appInfoData = createMultipartItem(name: "metadata", boundary: boundary, object: appInfo)
        let screenshotData = createMultipartItem(name: "screenshot", boundary: boundary, image: screenshot, filename: "screenshot.jpg")
        
        request.httpBody = [appInfoData, "\r\n".data(using: .utf8), screenshotData, closeBoundaryData]
            .compactMap { $0 }
            .reduce(Data()) {
                var newData = $0
                newData.append($1)
                return newData
        }
        
        return request
    }
    
    private static func createMultipartItem(name: String, boundary: String, contentType: String, filename: String?, content: Data) -> Data {
        var body = ("--" + boundary + "\r\n").data(using: .utf8)!
        
        // Content-Disposition
        let contentDispositionItems = ["Content-Disposition: form-data", "name=\"" + name + "\"", filename.map { "filename=\"" + $0 + "\"" }]
        let contentDisposition = contentDispositionItems.compactMap { $0 }.joined(separator: "; ")
        body.appendString(contentDisposition + "\r\n")
        
        // Content-Type
        body.appendString("Content-Type: " + contentType + "\r\n\r\n")
        
        // Content
        body.append(content)
        body.appendString("\r\n")
        
        return body
    }
    
    private static func createMultipartItem<Object: Encodable>(name: String, boundary: String, object: Object) -> Data? {
        let jsonEncoder = JSONEncoder()
        
        guard let jsonData = try? jsonEncoder.encode(object) else { return nil }
        
        return createMultipartItem(name: name, boundary: boundary, contentType: "application/json", filename: nil, content: jsonData)
    }
    
    private static func createMultipartItem(name: String, boundary: String, image: UIImage, filename: String) -> Data? {
        guard let imageData = image.jpegData(compressionQuality: 1) else { return nil }
        return createMultipartItem(name: name, boundary: boundary, contentType: "image/jpeg", filename: filename, content: imageData)
    }
}
