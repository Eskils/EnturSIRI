//
//  NextBusHandler.swift
//  EnturSIRIIntent
//
//  Created by Eskil Sviggum on 13/01/2019.
//  Copyright © 2019 SIGABRT. All rights reserved.
//

import UIKit
import os.log
import Intents

class NextBusHandler: NSObject, NextBusIntentHandling {
    
    func resolveFra(for intent: NextBusIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        os_log("Handter Fra!")
    }
    
    func resolveTil(for intent: NextBusIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        os_log("Handterer Til!")
    }
    

    func handle(intent: NextBusIntent, completion: @escaping (NextBusIntentResponse) -> Void) {
        let NB = intent
        os_log("Handterer NextBus")
        DispatchQueue.main.async {
            os_log("Handterer NextBus222")
            var bussar: [(String,String)] = []
            EnturAPIFetch().finnBusstiderFra(NB.fra!, til: NB.til!) { (dict) in
                if let JSONDict = dict {
                    print(JSONDict)
                    let NSJSONDict = NSDictionary(dictionary: JSONDict)
                    
                    let patterns = NSJSONDict.value(forKeyPath: "data.trip.tripPatterns") as! NSArray
                    
                    print(patterns)
                    
                    
                    
                    patterns.enumerated().forEach({ (arg0) in
                        let (i, _) = arg0
                        
                        let start = ((patterns[i]) as AnyObject).value(forKey: "startTime")
                        let slutt = ((patterns[i]) as AnyObject).value(forKey: "endTime")
                        bussar.append(("\(start!)","\(slutt!)"))
                    })
                    /*let interaksjon = INInteraction(intent: intent, response: nil)
                     interaksjon.donate(completion: { (error) in
                     print(error)
                     })*/
                    let buss = bussar[0]
                    let datoformat = DateFormatter()
                    datoformat.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                    let bussStartDate = datoformat.date(from: buss.0)
                    let bussSluttDate = datoformat.date(from: buss.1)
                    let bussStart = self.faaFatIString(from: bussStartDate) ?? "-"
                    let bussSlutt = self.faaFatIString(from: bussSluttDate) ?? "-"
                        
                    
                    
                    NSLog("\(NB.til, NB.fra, bussStart, bussSlutt)")
                    completion(NextBusIntentResponse.success(fra: NB.fra!, startTime: bussStart, til: NB.til!, endTime: bussSlutt))
                    
                    
                }else {
                    
                    completion(NextBusIntentResponse(code: .failure, userActivity: nil))
                    
                }
            }
            
        }
    }
    
    func faaFatIString(from: Date?) -> String?{
        if let dato = from {
        let cal = Calendar(identifier: .gregorian)
        let hour = cal.component(.hour, from: dato)
        let minute = cal.component(.minute, from: dato)
        let hm = "\(hour):\(minute)"
        
        let datoformat = DateFormatter()
        datoformat.dateFormat = "HH:mm"
        let date = datoformat.date(from: hm)
            
            let dateStr = "\(cal.component(.hour, from: date ?? Date())):\(cal.component(.minute, from: date ?? Date()))"
        
        return "\(dateStr)"
        }else{
            return nil//"\(Date())"
        }
    }
    
}
