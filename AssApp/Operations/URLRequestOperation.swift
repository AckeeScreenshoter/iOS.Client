//
//  URLRequestOperation.swift
//  Ass
//
//  Created by Jakub Olejník on 24/11/2018.
//

import Foundation

typealias ProgressBlock = (Double) -> ()

class URLRequestOperation: Operation {

    override var isFinished: Bool { return _isFinished }
    private var _isFinished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isExecuting: Bool { return _isExecuting }
    private var _isExecuting = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    var urlRequest: URLRequest?
    var result: Result<Data?, RequestError>?
    
    var progressBlock: ProgressBlock?
    var startBlock = { }
    
    private lazy var session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    private var requestTask: URLSessionTask?
    
    // MARK: - Operation override
    
    override func start() {
        guard let urlRequest = urlRequest else { return }
        requestTask = session.uploadTask(with: urlRequest, from: urlRequest.httpBody) { [weak self] data, response, error in
            self?._isExecuting = false
            
            switch (data, error) {
            case (let data?, _): self?.result = Result.success(data)
            case (_, let error?): self?.result = Result.failure(.network(error))
            case (.none, .none): self?.result = Result.failure(.noData)
            }
            
            DispatchQueue.main.async { [weak self] in
                self?._isFinished = true
            }
        }
        
        
        super.start()
    }
    
    override func main() {
        startBlock()
        _isExecuting = true
        requestTask?.resume()
    }
    
    override func cancel() {
        super.cancel()
        
        _isExecuting = false
        requestTask?.cancel()
        requestTask = nil
        DispatchQueue.main.async { [weak self] in
            self?._isFinished = true
        }
    }
}

extension URLRequestOperation: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard dataTask.countOfBytesExpectedToReceive > 0 else { return }
        
        progressBlock?(Double(dataTask.countOfBytesReceived) / Double(dataTask.countOfBytesExpectedToReceive))
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard totalBytesExpectedToSend > 0 else { return }

        progressBlock?(Double(totalBytesSent) / Double(totalBytesExpectedToSend))
    }
}
