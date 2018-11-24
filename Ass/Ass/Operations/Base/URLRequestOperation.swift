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
//            willChangeValue(for: \URLRequestOperation.isFinished)
        }
        didSet {
            didChangeValue(forKey: "isFinished")
//            didChangeValue(for: \URLRequestOperation.isFinished)
        }
    }
    
    override var isExecuting: Bool { return _isExecuting }
    private var _isExecuting = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
//            willChangeValue(for: \.isExecuting)
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
//            didChangeValue(for: \.isExecuting)
        }
    }
    
    let urlRequest: URLRequest
    var result: Result<Data?, RequestError>?
    
    var progressBlock: ProgressBlock?
    var startBlock = { }
    
    private lazy var session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    private var requestTask: URLSessionTask?
    
    // MARK: - Initializers
    
    init(request urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
    
    // MARK: - Operation override
    
    override func start() {
        requestTask = session.dataTask(with: urlRequest) { [weak self] data, response, error in
            self?._isExecuting = false
            
            switch (data, error) {
            case (let data?, _): self?.result = Result.success(data)
            case (_, let error?): self?.result = Result.failure(.network(error))
            case (.none, .none): self?.result = Result.failure(.noData)
            }
            
            self?._isFinished = true
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
        _isFinished = true
    }
}

extension URLRequestOperation: URLSessionDelegate, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard totalBytesExpectedToSend > 0 else { return }

        progressBlock?(Double(totalBytesSent) / Double(totalBytesExpectedToSend))
    }
}
