//
//  SettingsManager.swift
//  coloringbook
//
//  Created by AMAN JAIN on 11/30/16.
//  Copyright © 2025 Aman. All rights reserved.
//

import Foundation
import UIKit

class SettingsManager {
    
    static let sharedInstance = SettingsManager()
    
    var soundEffects = false
    var smartBorders = true
    var undoSwipe = false

    var waitForTransition = false
    
    private init() {}
}

