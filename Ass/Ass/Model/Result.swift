//
//  Result.swift
//  Ass
//
//  Created by Jakub Olejník on 24/11/2018.
//

import Foundation

// Lightweight version of https://github.com/antitypical/Result
enum Result<Value, Error: Swift.Error> {
    case success(Value)
    case failure(Error)
}

extension Result {
    /// Returns a new Result by mapping `Success`es’ values using `transform`, or re-wrapping `Failure`s’ errors.
    public func map<U>(_ transform: (Value) -> U) -> Result<U, Error> {
        return flatMap { .success(transform($0)) }
    }
    
    /// Returns the result of applying `transform` to `Success`es’ values, or re-wrapping `Failure`’s errors.
    public func flatMap<U>(_ transform: (Value) -> Result<U, Error>) -> Result<U, Error> {
        switch self {
        case let .success(value): return transform(value)
        case let .failure(error): return .failure(error)
        }
    }
}
