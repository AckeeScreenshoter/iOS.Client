//
//  Result.swift
//  Ass
//
//  Created by Jakub Olejník on 24/11/2018.
//

import Foundation

enum Result<Value, Error: Swift.Error> {
    case success(Value)
    case failure(Error)
}
