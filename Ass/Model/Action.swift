//
//  Action.swift
//  Ass
//
//  Created by Jakub Olejník on 24/11/2018.
//

import Foundation

private let defaultQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.underlyingQueue = DispatchQueue.global(qos: .background)
    queue.maxConcurrentOperationCount = 1
    return queue
}()

final class Action<OperationType: Operation> {
    var operation: OperationType
    
    var isExecuting: Bool { return operation.isExecuting }
    
    // MARK: Initializers
    
    init(operation: OperationType) {
        self.operation = operation
    }
    
    // MARK: - Public interface
    
    func start(on queue: OperationQueue = defaultQueue) {
        queue.addOperation(operation)
    }
}
