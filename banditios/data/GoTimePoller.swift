//
//  GoTimePoller.swift
//  banditios
//
//  Created by Graham Vaughn on 2/11/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt

class GoTimePoller {
    
    private let persistenceManager = PersistenceManager()
    private let errorHandler = ErrorHelper()
    
    init() {
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            guard let strongSelf = self else { return }
            
            do {
                let goTimes = try strongSelf.persistenceManager.loadGoTimeGroups()
            } catch {
                print("Error loading go times in poller, continuing ...")
                strongSelf.errorHandler.handleError(error)
            }
            
        }
    }
    
    
}
