//
//  ColorUtils.swift
//  banditios
//
//  Created by Graham Vaughn on 2/27/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import UIKit

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
