//
//  NextBusUtenTilHandler.swift
//  EnturSIRIIntent
//
//  Created by Eskil Sviggum on 08/03/2019.
//  Copyright © 2019 SIGABRT. All rights reserved.
//

import UIKit
import os.log
import CoreLocation
import MapKit

class NextBusUtanFraHandler: NSObject, NextBusUtanFraIntentHandling{
    
    func handle(intent: NextBusUtanFraIntent, completion: @escaping (NextBusUtanFraIntentResponse) -> Void) {
        let NB = intent
        DispatchQueue.main.async {
            
            self.LocationManager = CLLocationManager()
            self.FinnNoverandePosisjon(completion: { (fraa) in

            var bussar: [(String,String)] = []
            EnturAPIFetch().finnBusstiderFra(fraa, til: NB.til!) { (dict) in
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
                    if bussar.isEmpty {
                       completion(NextBusUtanFraIntentResponse(code: .failure, userActivity: nil))
                    }
                    let buss = bussar[0]
                    let datoformat = DateFormatter()
                    datoformat.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                    let bussStartDate = datoformat.date(from: buss.0)
                    let bussSluttDate = datoformat.date(from: buss.1)
                    let bussStart = self.faaFatIString(from: bussStartDate) ?? "-"
                    let bussSlutt = self.faaFatIString(from: bussSluttDate) ?? "-"
                    
                    
                    
                    completion(NextBusUtanFraIntentResponse.success(fra: fraa, startTime: bussStart, til: NB.til!, endTime: bussSlutt))
                    
                    
                }else {
                    
                    completion(NextBusUtanFraIntentResponse(code: .failure, userActivity: nil))
                    
                }
            }
                })
            
        }
    }
    
    
    var LocationManager: CLLocationManager?
    
    func FinnNoverandePosisjon(completion: @escaping (_ plass: String) -> Void) {
        NSLog("Gaor da te hellvette so gaor da te helvette.")
        let location = LocationManager!.location!
        NSLog("location: %@", location)
        
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            NSLog("placemarks: %@", placemarks!)
            if error == nil {
                
                guard let placeMark = placemarks?.first else { return }
                
                var plass = ""
                
                if let locality = placeMark.locality {
                    NSLog(locality)
                    plass = locality
                    
                }
                
                /*if let city = placeMark.subAdministrativeArea {
                 NSLog(city)
                    plass = city
                    
                }*/
                
                if let street = placeMark.thoroughfare {
                    NSLog(street)
                    plass = street
                }
                
                NSLog("plaaasss: %@", plass)
                
                completion(plass)
                
                
            }else{
                os_log("Fann ingen posisjon...")
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

