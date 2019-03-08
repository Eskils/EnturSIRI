//
//  LoadingModal.swift
//  EnturSIRI
//
//  Created by Eskil Sviggum on 09/03/2019.
//  Copyright © 2019 SIGABRT. All rights reserved.
//

import UIKit

class LoadingModal: UIViewController {

    @IBOutlet var topview: UIView!
    @IBOutlet var ActivityView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let topsiz = topview.frame.width
        topview.layer.cornerRadius = topsiz / 6
        
        topview.layer.shadowColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        topview.layer.shadowRadius = 2
        topview.layer.shadowOpacity = 0.6
    }
    


}
