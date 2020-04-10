//
//  UploadScreenshotOperation.swift
//  Ass
//
//  Created by Jakub Olejník on 24/11/2018.
//

import UIKit
import AVKit

// Rename to upload data
final class UploadMultipartDataOperation: URLRequestOperation {
    
    var screenshot: UIImage? {
        didSet {
            guard let screenshot = screenshot else { return }
            updateRequest()
        }
    }
    
    var recordURL: URL? {
        didSet {
            guard let recordURL = recordURL else { return }
            updateRequest()
        }
    }
    
    var appInfo: [String:String]? {
        didSet {
            updateRequest()
        }
    }
    
    var baseURL: URL? {
        didSet {
            updateRequest()
        }
    }
    
    var authorization: String? {
        didSet {
            updateRequest()
        }
    }
    
    private func updateRequest() {
        guard let appInfo = appInfo, let baseURL = baseURL, let authorization = authorization else { return }
        if let screenshot = screenshot {
            urlRequest = createRequest(screenshot: screenshot, appInfo: appInfo, baseURL: baseURL, authorization: authorization)
            return
        }
        
        if let recordURL = recordURL {
            urlRequest = createRequest(recordURL: recordURL, appInfo: appInfo, baseURL: baseURL, authorization: authorization)
            return
        }
    }
    
    // MARK: - Private helpers
    
    //TODO: create request for record
    func createRequest(screenshot: UIImage? = nil, recordURL: URL? = nil, appInfo: [String:String], baseURL: URL, authorization: String) -> URLRequest {
        let url = URL(string: "upload", relativeTo: baseURL)!
        let boundary = "cz.ackee.enterprise.ass"
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=" + boundary, forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + authorization, forHTTPHeaderField: "Authorization")
        
        let closeBoundaryData = ("--" + boundary + "--\r\n").data(using: .utf8)!
        
        let appInfoData = createMultipartItem(name: "metadata", boundary: boundary, object: appInfo)
        
        var mediaData: Data? = nil
        if let screenshot = screenshot {
            mediaData = createMultipartItem(name: "screenshot", boundary: boundary, image: screenshot, filename: "screenshot.jpg")
        } else if let recordURL = recordURL {
            mediaData = createMultipartItem(name: "record", boundary: boundary, recordURL: recordURL, filename: "record.mov")
        }
        
        request.httpBody = [appInfoData, "\r\n".data(using: .utf8), mediaData, closeBoundaryData]
            .compactMap { $0 }
            .reduce(Data()) {
                var newData = $0
                newData.append($1)
                return newData
        }
        return request
    }
    
    func createMultipartItem(name: String, boundary: String, contentType: String, filename: String?, content: Data) -> Data {
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
    
    func createMultipartItem<Object: Encodable>(name: String, boundary: String, object: Object) -> Data? {
        let jsonEncoder = JSONEncoder()
        
        guard let jsonData = try? jsonEncoder.encode(object) else { return nil }
        print("jsonData \(jsonData)")
        
        return createMultipartItem(name: name, boundary: boundary, contentType: "application/json", filename: nil, content: jsonData)
    }
    
    func createMultipartItem(name: String, boundary: String, recordURL: URL, filename: String) -> Data? {
        guard let recordData = try? Data(contentsOf: recordURL, options: .alwaysMapped) else { return nil }
        return createMultipartItem(name: name, boundary: boundary, contentType: "video/mov", filename: filename, content: recordData)
    }
    
    func createMultipartItem(name: String, boundary: String, image: UIImage, filename: String) -> Data? {
        guard let imageData = image.jpegData(compressionQuality: 1) else { return nil }
        return createMultipartItem(name: name, boundary: boundary, contentType: "image/jpeg", filename: filename, content: imageData)
    }
}
