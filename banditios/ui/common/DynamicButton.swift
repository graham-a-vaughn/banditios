//
//  DynamicButton.swift
//  banditios
//
//  Created by Graham Vaughn on 2/20/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxSwiftExt

class DynamicButton: NSObject {
    let name: String
    let location: ButtonLocation
    let button: UIButton
    
    var state: TrackingState?
    var dbx: ButtonExecutor?
    
    var constraints: [NSLayoutConstraint] = []
    var disposable: SerialDisposable = SerialDisposable()
    
    init(_ name: String, _ loc: ButtonLocation, _ button: UIButton) {
        self.name = name
        self.location = loc
        self.button = button
        super.init()
    }
}

class ColorHelper {
    
    func getColor(_ color: UIColor, alpha: CGFloat) -> UIColor {
        var usfr: CGFloat = 100
        var usfg: CGFloat = 101
        var usfb: CGFloat = 102
        var usa: CGFloat = 103
        color.getRed(&usfr, green: &usfg, blue: &usfb, alpha: &usa)
        
        return UIColor(red: usfr, green: usfg, blue: usfb, alpha: alpha)
    }
}
