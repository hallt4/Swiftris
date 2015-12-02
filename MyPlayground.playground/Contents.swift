//
//  GameScene.swift
//  Swiftris
//
//  Created by Tyler Hall on 11/17/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

import SpriteKit

//600 millisec interval
let TickLengthLevelOne = NSTimeInterval(600)

    var tickLengthMillis = TickLengthLevelOne
    var lastTick = NSDate()
    
    
        var stuff = lastTick.timeIntervalSinceNow
        let timePassed = stuff * -1000
        if timePassed > tickLengthMillis {
            print("here")
            lastTick = NSDate()
        }

    
   