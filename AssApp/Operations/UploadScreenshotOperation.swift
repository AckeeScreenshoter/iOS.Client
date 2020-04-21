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
            guard let _ = screenshot else { return }
            updateRequest()
        }
    }
    
    var recordURL: URL? {
        didSet {
            guard let _ = recordURL else { return }
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
    
    func createMultipartItem(name: String, boundary: String, filename: String?, contentType: ContentType, content: Data) -> Data {
        var body = ("--" + boundary + "\r\n").data(using: .utf8)!
        
        // Content-Disposition
        let name = "name=\"" + name + "\""
        let filename = filename.map { "filename=\"" + $0 + "\"" }
        let type = (contentType == .json ? nil : contentType.rawValue).map { "type=\"" + $0 + "\"" }
            //contentType.rawValue.map { $0 == ContentType.json.rawValue ? nil : contentType }
        let contentDispositionItems = ["Content-Disposition: form-data", name, filename, type]
        
        let contentDisposition = contentDispositionItems.compactMap { $0 }.joined(separator: "; ")
        body.appendString(contentDisposition + "\r\n")
        
        // Content-Type
        body.appendString("Content-Type: " + contentType.type + "\r\n\r\n")
        
        // Content
        body.append(content)
        body.appendString("\r\n")
        
        return body
    }
    
    func createMultipartItem<Object: Encodable>(name: String, boundary: String, object: Object) -> Data? {
        let jsonEncoder = JSONEncoder()
        
        guard let jsonData = try? jsonEncoder.encode(object) else { return nil }
        print("jsonData \(jsonData)")
        
        return createMultipartItem(name: name, boundary: boundary, filename: nil, contentType: .json, content: jsonData)
    }
    
    func createMultipartItem(name: String, boundary: String, recordURL: URL? = nil, image: UIImage? = nil, filename: String) -> Data? {
        
        if let imageData = image?.jpegData(compressionQuality: 1) {
            return createMultipartItem(name: name, boundary: boundary, filename: filename, contentType: .image, content: imageData)
        }
        
        if let recordURL = recordURL, let recordData = try? Data(contentsOf: recordURL, options: .alwaysMapped) {
            return createMultipartItem(name: name, boundary: boundary, filename: filename, contentType: .video, content: recordData)
        }
        
        return nil
    }
}

enum ContentType: String {
    case video
    case image
    case json
    
    var type: String {
        switch self {
        case .video: return "video/mov"
        case .image: return "image/jpeg"
        case .json: return "application/json"
        }
    }
}
