//
//  NextBusesHandler.swift
//  EnturSIRIIntent
//
//  Created by Eskil Sviggum on 13/10/2019.
//  Copyright © 2019 SIGABRT. All rights reserved.
//

import UIKit
import os.log
import Intents

class NextBusesHandler: NSObject, NextBusesIntentHandling {
    
    

    func handle(intent: NextBusesIntent, completion: @escaping (NextBusesIntentResponse) -> Void) {
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
                    
                    var tider: [String] = []
                    
                    let datoformat = DateFormatter()
                    datoformat.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

                    for buss in bussar {
                        let bussStartDate = datoformat.date(from: buss.0)
                        let bussSluttDate = datoformat.date(from: buss.1)
                        let bussStart = self.faaFatIString(from: bussStartDate, medDag: true) ?? "-"
                        let bussSlutt = self.faaFatIString(from: bussSluttDate, medDag: false) ?? "-"
                        let tid = "\(bussStart)-\(bussSlutt)\n"
                        tider.append(tid)
                    }
                        
                    completion(NextBusesIntentResponse.success(fra: NB.fra!, til: NB.til!, tider: tider))
                    
                    
                }else {
                    
                    completion(NextBusesIntentResponse(code: .failure, userActivity: nil))
                    
                }
            }
            
        }
    }
    
    let Dagar = ["Sundag", "Måndag", "Tysdag", "Onsdag", "Torsdag", "Fredag", "Laurdag"]
    func faaFatIString(from: Date?, medDag:Bool) -> String?{
        if let dato = from {
            print(dato)
            let cal = Calendar(identifier: .gregorian)
            let hour = cal.component(.hour, from: dato)
            let minute = cal.component(.minute, from: dato)
            let hm = "\(hour):\(minute)"
            
            let idagint = cal.component(.weekday, from: Date())
            let dagint = cal.component(.weekday, from: dato)
            var dag = Dagar[dagint - 1]
            
            if idagint == dagint {
                dag = "Idag"
            }
            
            let datoformat = DateFormatter()
            datoformat.dateFormat = "HH:mm"
            let date = datoformat.date(from: hm)
            
            var dateStr:String
            if medDag{
             dateStr = "\(dag) \(cal.component(.hour, from: date ?? Date())):\(cal.component(.minute, from: date ?? Date()))"
            } else {
                dateStr = "\(cal.component(.hour, from: date ?? Date())):\(cal.component(.minute, from: date ?? Date()))"
            }
            
            return "\(dateStr)"
        }else{
            return nil//"\(Date())"
        }
    }
    
}

