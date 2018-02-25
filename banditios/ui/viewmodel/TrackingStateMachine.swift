//
//  TrackingStateMachine.swift
//  banditios
//
//  Created by Graham Vaughn on 2/14/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation

enum TrackingState {
    case ready
    case tracking
    case paused
    case resumed
    case stopped
    case saved
}

struct TrackingStateModel {
    let goTime: GoTime?
    let goTimeGroup: GoTimeGroup?
    let state: TrackingState
}

struct TrackingStateMachine {
    let state: TrackingState
    let destinations: [TrackingState]
}


