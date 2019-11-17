//
//  IntentViewController.swift
//  EnturSIRIIntentUI
//
//  Created by Eskil Sviggum on 09/01/2019.
//  Copyright © 2019 SIGABRT. All rights reserved.
//

import IntentsUI

class IntentViewController: UIViewController, INUIHostedViewControlling {
    
    @IBOutlet var Laabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    // MARK: - INUIHostedViewControlling
    
    
    func configure(with interaction: INInteraction, context: INUIHostedViewContext, completion: @escaping (CGSize) -> Void) {
        
            let intent = interaction.intent as! NextBusIntentResponse
            self.Laabel.text = "Next bus leaves from \(intent.fra) at \(intent.startTime) and arrives in \(intent.til) at \(intent.endTime)"
            
        
        
        completion(self.desiredSize)
    }
    
    var desiredSize: CGSize {
        return self.extensionContext!.hostedViewMaximumAllowedSize
    }
    
}
