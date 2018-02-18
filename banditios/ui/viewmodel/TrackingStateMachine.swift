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
}

struct TrackingStateModel {
    let goTime: GoTime?
    let goTimeGroup: GoTimeGroup?
    let state: TrackingState
}

class TrackingStateTransitioner {
    let goTimeGroup: GoTimeGroup
    let typeConfig: GoTimeTypeConfig
    
    init(_ goTimeGroup: GoTimeGroup, _ typeConfig: GoTimeTypeConfig) {
        self.goTimeGroup = goTimeGroup
        self.typeConfig = typeConfig
    }
    
    func transition(_ state: TrackingState) {
        switch state {
        case .tracking:
            let goTime = GoTime(start: Date.now, type: typeConfig.nextType(goTimeGroup.current()?.type))
            goTimeGroup.add(goTime)
        //case .paused:
            
        default:
            goTimeGroup.stop()
        }
    }
}

struct TrackingStateMachine {
    let state: TrackingState
    let destinations: [TrackingState]
}

class TrackingStateManager {
    let stateMachines = [
        TrackingStateMachine(state: .ready, destinations: [.tracking]),
        TrackingStateMachine(state: .tracking, destinations: [.tracking, .paused]),
        TrackingStateMachine(state: .paused, destinations: [.resumed, .tracking, .stopped]),
        TrackingStateMachine(state: .resumed, destinations: [.tracking]),
        TrackingStateMachine(state: .stopped, destinations: [.ready])
    ]
    private var map: [TrackingState: TrackingStateMachine] = [:]
    private var current: TrackingState = .ready
    
    init() {
        for sm in stateMachines {
            map[sm.state] = sm
        }
    }
    
    func destinations() -> [TrackingState] {
        return map[current]!.destinations
    }
        
        /**
        [TrackingState: TrackingStateMachine] = [
        .ready: TrackingStateMachine(state: .ready, destinations: [.tracking]),
        .tracking: c
        .paused: TrackingStateMachine(state: .paused, destinations: [.resumed, .tracking]),
        .res
    ] **/
}
