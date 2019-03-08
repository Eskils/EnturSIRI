//
//  ViewController.swift
//  EnturSIRI
//
//  Created by Eskil Sviggum on 08/01/2019.
//  Copyright © 2019 SIGABRT. All rights reserved.
//
//Rutedata frå Entur.

import UIKit
import Intents
import MapKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StartEnd.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celle = TableView.dequeueReusableCell(withIdentifier: "Celle1")!
        let Title = celle.contentView.viewWithTag(16) as! UILabel
        let Detail = celle.contentView.viewWithTag(32) as! UILabel
        Title.text! = StartEnd[indexPath.row]
        Detail.text! = FraTil
        return celle
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
   
    
    
    var StartEnd:Array<String> = []
    var FraTil = ""
    var LastIndexes: [IndexPath] = []
    var SkalBrukeBrukarPosisjon = false
    let LocationManager = CLLocationManager()
    var NoverandePlass:String? = nil
    let plasssokurl = "https://api.entur.org/api/geocoder/1.1/reverse?point.lat={{LATITUDE}}&point.lon={{LONGDITUDE}}&lang=en&size=1&layers=address"
   
    @IBOutlet var TilTextField: UITextField!
    @IBOutlet var FraTextField: UITextField!
    @IBOutlet var TableView: UITableView!
    
    var modalActivityIndicator : UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        modalActivityIndicator = sb.instantiateViewController(withIdentifier: "ModalLoader")
        
        INPreferences.requestSiriAuthorization { (status) in
            print(status)
            //INVocabulary.shared().setVocabularyStrings([""], of: .)
        }
        
        self.LocationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.LocationManager.requestWhenInUseAuthorization()
        
        TilTextField.layer.cornerRadius = 8
        FraTextField.layer.cornerRadius = 8
        
        TableView.delegate = self
        TableView.dataSource = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.endedit))
        
        view.addGestureRecognizer(tap)
        TableView.addGestureRecognizer(tap)
    }
    func UpCaseFirstLetterIn(string: String) -> String {
        let FirstLetter = "\(string[string.startIndex])".uppercased()
        var str = string
        print(FirstLetter)
        str.remove(at: string.startIndex)
        let streturn = "\(FirstLetter)\(str)"
        return streturn
    }
    
    @IBAction func Search(_ sender: Any) {
        let fratxt = FraTextField.text ?? ""
        let tiltxt = TilTextField.text ?? ""
        if fratxt.replacingOccurrences(of: " ", with: "") != "" && tiltxt.replacingOccurrences(of: " ", with: "") != "" {
            let textfield = sender as! UITextField
            let fra = fratxt.lowercased()
            let til = tiltxt.lowercased()
            searchBarSearchButtonClicked(UpCaseFirstLetterIn(string: fra), til: UpCaseFirstLetterIn(string: til))
        }
    }
    func searchBarSearchButtonClicked(_ fra: String, til: String) {
        
        self.present(modalActivityIndicator!, animated: true, completion: nil)
        
        
        var intent: NextBusIntent? = nil
        var intentUtanFra: NextBusUtanFraIntent? = nil
        if SkalBrukeBrukarPosisjon {
            intentUtanFra = NextBusUtanFraIntent()
            
            intentUtanFra!.suggestedInvocationPhrase = "When is the next bus to \(til)?"
        
            intentUtanFra!.til = til
        }else {
            intent = NextBusIntent()
            
            intent!.suggestedInvocationPhrase = "When is the next bus from \(fra) to \(til)?"
            intent!.fra = fra
            intent!.til = til
            
        }
        var intentTilBruk: INIntent = INIntent()
        if intent != nil {
            intentTilBruk = intent!
        }else if intentUtanFra != nil{
            intentTilBruk = intentUtanFra!
        }

        
        
        
            EnturAPIFetch().finnBusstiderFra(fra, til: til, completion: { (data) in
                DispatchQueue.main.async {
                    
                    self.modalActivityIndicator?.dismiss(animated: true, completion: nil)
                    
                    if let JSONDict = data {
                        print(JSONDict)
                        let NSJSONDict = NSDictionary(dictionary: JSONDict)
                        
                        let patterns = NSJSONDict.value(forKeyPath: "data.trip.tripPatterns") as! NSArray
                        
                        print(patterns)
                        
                        
                        var Indexes: [IndexPath] = []
                        self.StartEnd.removeAll()
                        
                        patterns.enumerated().forEach({ (arg0) in
                            let (i, pattern) = arg0
                            
                            let start = ((patterns[i]) as AnyObject).value(forKey: "startTime")
                            let slutt = ((patterns[i]) as AnyObject).value(forKey: "endTime")
                            let buss = ("\(start ?? "")","\(slutt ?? "")")
                            let datoformat = DateFormatter()
                            datoformat.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                            let bussStartDate = datoformat.date(from: buss.0)
                            let bussSluttDate = datoformat.date(from: buss.1)
                            let bussStart = self.faaFatIString(from: bussStartDate, medDag: true) ?? "-"
                            let bussSlutt = self.faaFatIString(from: bussSluttDate, medDag: false) ?? "-"
                            let fulltid = "\(bussStart) - \(bussSlutt)"
                            self.StartEnd.append(fulltid)
                            Indexes.append(IndexPath(row: i, section: 0))
                            print(fulltid)
                        })
                        self.FraTil = "\(fra) - \(til)"
                        
                        self.TableView.beginUpdates()
                        self.TableView.deleteRows(at: self.LastIndexes, with: .middle)
                        self.TableView.insertRows(at: Indexes, with: .middle)
                        self.TableView.endUpdates()
                        
                        self.LastIndexes = Indexes
                        
                        if self.StartEnd.isEmpty {
                            let al = UIAlertController(title: "Hmmm,", message: "Fann ikkje nokon bussruter", preferredStyle: .alert)
                            al.addAction(UIAlertAction(title: "Oki", style: .default, handler: nil))
                            self.present(al, animated: true, completion: nil)
                        }else {
                            let interaksjon = INInteraction(intent: intentTilBruk, response: nil)
                            interaksjon.donate(completion: { (error) in
                                guard error == nil else {
                                    print("ERRORDONATINGINTENT: \(error!)")
                                    return
                                }
                                print("HARDONERTINTENT VELLUKKA")
                            })
                        }
                        
                    }else {
                        self.SynVarslingMedTittel("Hmmm,", "Det ser ut som at reisa ikkje finnest.")
                        
                    }
                }
            })
        
        
    
    }
    let Dagar = ["Sun", "Mån", "Tys", "Ons", "Tor", "Fre", "Lau"]
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
    
    
    func SynVarslingMedTittel(_ Tittel: String,_ melding:String){
        let alert = UIAlertController(title: Tittel, message: melding, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Oki", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func SettFraTilPosisjon(_ sender: Any) {
        self.present(modalActivityIndicator!, animated: true, completion: nil)
        let location = LocationManager.location!
        
        let geocoder = CLGeocoder()
        
        print(location)
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            self.modalActivityIndicator?.dismiss(animated: true, completion: nil)
            if error == nil {
                
                guard let placeMark = placemarks?.first else { return }
                
                var plass = ""
                
                print(placeMark)
                
                if let locality = placeMark.locality {
                    print(locality)
                    plass = locality
                    
                }
                
                if let navn = placeMark.name {
                    print(navn)
                    plass = navn
                }
                
                if let city = placeMark.subThoroughfare {
                    print(city)
                    plass = city
                }
                

                
                if let street = placeMark.thoroughfare {
                    print(street)
                    plass = street
                }
                
                
                
                self.FraTextField.text = "\(plass)"
                self.SkalBrukeBrukarPosisjon = true
                

            }else{
                let al = UIAlertController(title: "Hmm,", message: "Fann ikkje noko plass", preferredStyle: .alert)
                al.addAction(UIAlertAction(title: "Oki", style: .default, handler: nil))
                self.present(al, animated: true, completion: nil)
            }
        }
        
    }
    
    
    @objc func endedit() {
            TilTextField.endEditing(true)
            FraTextField.endEditing(true)
        
        
    }
    


}

