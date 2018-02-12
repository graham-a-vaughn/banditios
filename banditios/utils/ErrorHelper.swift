//
//  ErrorHelper.swift
//  banditios
//
//  Created by Graham Vaughn on 2/10/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation

class ErrorHelper {
    func handleError(_ error: Error) {
        if error is PersistenceError {
            handlePersistenceError(error as! PersistenceError)
        } else {
            print(error)
        }
    }
    
    func handlePersistenceError(_ error: PersistenceError) {
        switch error {
        case .castFailed(let message):
            print("\(message)")
        case .loadFailed(let message):
            print("\(message)")
        case .saveFailed(let message):
            print("\(message)")
        }
    }
}
