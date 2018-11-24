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
            willChangeValue(for: \URLRequestOperation.isFinished)
        }
        didSet {
            didChangeValue(for: \URLRequestOperation.isFinished)
        }
    }
    
    override var isExecuting: Bool { return _isExecuting }
    private var _isExecuting = false {
        willSet {
            willChangeValue(for: \.isExecuting)
        }
        didSet {
            didChangeValue(for: \.isExecuting)
        }
    }
    
    let urlRequest: URLRequest
    var result: Result<Data?, RequestError>?
    
    var progressBlock: ProgressBlock?
    var startBlock = { }
    
    private var requestTask: URLSessionTask?
    private var sentProgressObservation: NSKeyValueObservation?
    private var receivedProgressObservation: NSKeyValueObservation?
    
    // MARK: - Initializers
    
    init(request urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
    
    // MARK: - Operation override
    
    override func start() {
        requestTask = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
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
    
    // MARK: - Private helpers
    
    private func observeTask() {
        sentProgressObservation = requestTask?.observe(\.countOfBytesSent) { [weak self] _, _ in
            self?.taskChanged()
        }
        receivedProgressObservation = requestTask?.observe(\.countOfBytesReceived) { [weak self] _, _ in
            self?.taskChanged()
        }
    }
    
    private func taskChanged() {
        guard let task = requestTask else { return }
        
        let progress = Double(task.countOfBytesSent + task.countOfBytesReceived) / Double(task.countOfBytesExpectedToSend + task.countOfBytesExpectedToReceive)
        progressBlock?(progress)
    }
}
