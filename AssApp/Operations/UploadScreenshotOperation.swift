//
//  UploadScreenshotOperation.swift
//  Ass
//
//  Created by Jakub Olejník on 24/11/2018.
//

import UIKit
import AVKit
import AssCore

final class UploadMultipartDataOperation: URLRequestOperation {
    
    init(media: Media, appInfo: [String: String], baseURL: URL, authorization: String) {
        super.init()
        
        switch media {
        case let .screenshot(asset):
            urlRequest = createRequest(screenshot: asset?.image, appInfo: appInfo, baseURL: baseURL, authorization: authorization)
        case let .record(_, url):
            urlRequest = createRequest(recordURL: url, appInfo: appInfo, baseURL: baseURL, authorization: authorization)
        }
    }
    
    
    // MARK: - Private helpers
    
    //TODO: create request for record
    func createRequest(screenshot: UIImage? = nil, recordURL: URL? = nil, appInfo: [String:String], baseURL: URL, authorization: String) -> URLRequest {
        let url = URL(string: "upload", relativeTo: baseURL)!
        let boundary = "cz.ackee.enterprise.ass"
        var request = URLRequest(url: url)
        var appInfo = appInfo
        
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=" + boundary, forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + authorization, forHTTPHeaderField: "Authorization")
        
        let closeBoundaryData = ("--" + boundary + "--\r\n").data(using: .utf8)!
        
        var mediaData: Data? = nil
        if let screenshot = screenshot {
            appInfo["type"] = ContentType.image.rawValue
            mediaData = createMultipartItem(name: "screenshot", boundary: boundary, image: screenshot, filename: "screenshot.jpg")
        } else if let recordURL = recordURL {
            appInfo["type"] = ContentType.video.rawValue
            mediaData = createMultipartItem(name: "record", boundary: boundary, recordURL: recordURL, filename: "record.mp4")
        }
        
        let appInfoData = createMultipartItem(name: "metadata", boundary: boundary, object: appInfo)
        
        request.httpBody = [appInfoData, "\r\n".data(using: .utf8), mediaData, closeBoundaryData]
            .compactMap { $0 }
            .reduce(Data()) {
                var newData = $0
                newData.append($1)
                return newData
        }
        
        print(request)
        return request
    }
    
    func createMultipartItem<Object: Encodable>(name: String, boundary: String, object: Object) -> Data? {
        let jsonEncoder = JSONEncoder()
        
        guard let jsonData = try? jsonEncoder.encode(object) else { return nil }
        
        return createMultipartItem(name: name, boundary: boundary, filename: nil, contentType: .json, content: jsonData)
    }
    
    func createMultipartItem(name: String, boundary: String, filename: String?, contentType: ContentType, content: Data) -> Data {
        var body = ("--" + boundary + "\r\n").data(using: .utf8)!
        
        // Content-Disposition
        let name = "name=\"" + name + "\""
        let filename = filename.map { "filename=\"" + $0 + "\"" }
        let contentDispositionItems = ["Content-Disposition: form-data", name, filename]
        
        let contentDisposition = contentDispositionItems.compactMap { $0 }.joined(separator: "; ")
        body.appendString(contentDisposition + "\r\n")
        
        // Content-Type
        body.appendString("Content-Type: " + contentType.type + "\r\n\r\n")
        
        // Content
        body.append(content)
        body.appendString("\r\n")
        
        return body
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
        case .video: return "video/mp4"
        case .image: return "image/jpeg"
        case .json: return "application/json"
        }
    }
}
