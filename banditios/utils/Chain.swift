//
//  Chain.swift
//  banditios
//
//  Created by Graham Vaughn on 1/20/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation

class ChainNode<E: ChainMutable> {
    var value: E
    var next: ChainNode<E>?
    
    init(_ value: E, next: ChainNode<E>?) {
        self.value = value
        self.next = next
    }
    
    func list(_ acc: [E]) -> [E] {
        var result: [E] = next?.list(acc) ?? acc
        result.append(value)
        return result
    }
}

class Chain<E: ChainMutable> {
    var head: ChainNode<E>?
    
    func list() -> [E] {
        let result: [E] = []
        return head?.list(result) ?? result
    }
    
    func add(_ value: E) {
        let node = ChainNode(value, next: head)
        chain(current: head, new: value)
        head = node
    }
    
    func added(_ value: E) -> Chain<E> {
        add(value)
        return self
    }
    
    func setValues(_ values: [E]) {
        for value in values {
            add(value)
        }
    }
    
    func peek() -> E? {
        return head?.value
    }
    
    func end() {
        head?.value.terminateSelf()
    }
    
    private func chain(current: ChainNode<E>?, new: E) {
        current?.value.acceptChain(other: new)
    }

}

protocol ChainMutable {
    
    func acceptChain(other: Self)
    
    func terminateSelf()
}
