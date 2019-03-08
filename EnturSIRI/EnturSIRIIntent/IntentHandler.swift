//
//  IntentHandler.swift
//  EnturSIRIIntent
//
//  Created by Eskil Sviggum on 09/01/2019.
//  Copyright © 2019 SIGABRT. All rights reserved.
//

import Intents
import os.log

class IntentHandler: INExtension  {
    
    override func handler(for intent: INIntent) -> Any? {
        NSLog("ValdInt::%@", intent)
        
        
        guard intent is NextBusIntent else {

            return NextBusUtanFraHandler()
        }
        

        return NextBusHandler()
    }
}
