//
//  JSONConvertable.swift
//  banditios
//
//  Created by Graham Vaughn on 2/4/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol JSONConvertable {
    
    func toJSON() -> JSON
}
