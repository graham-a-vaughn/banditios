//
//  ColorUtils.swift
//  banditios
//
//  Created by Graham Vaughn on 2/27/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(r: UInt8, g: UInt8, b: UInt8, alpha: CGFloat) {
        let red: CGFloat = (CGFloat)(r)/255.0
        let green: CGFloat = (CGFloat)(g)/255.0
        let blue: CGFloat = (CGFloat)(b)/255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    convenience init(r: UInt8, g: UInt8, b: UInt8) {
        self.init(r: r, g: g, b: b, alpha: 1.0)
    }
    
    convenience init(fromHex rgbValue: UInt32) {
        self.init(fromHex: rgbValue, withAlpha: 1.0)
    }
    
    convenience init(fromHex rgbValue: UInt32, withAlpha alpha: CGFloat) {
        let red = (UInt8)((rgbValue & 0xFF0000) >> 16)
        let green = (UInt8)((rgbValue & 0x00FF00) >> 8)
        let blue = (UInt8)((rgbValue & 0x0000FF) >> 0)
        self.init(r: red, g: green, b: blue, alpha: alpha)
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
