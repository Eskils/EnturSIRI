//
//  Hjelpefunksjonar.swift
//  EnturSIRI
//
//  Created by Eskil Sviggum on 13/10/2019.
//  Copyright © 2019 SIGABRT. All rights reserved.
//

import UIKit

let YES = true
let NO = false

@IBDesignable class textFieldPadding: UITextField {
    @IBInspectable var padding: CGFloat = 0
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.inset(by: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
    }
    
}

extension UIView {
    func rundAv(hjorner: UIRectCorner, radius: CGFloat) {
        
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: hjorner, cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         self.layer.mask = mask
        
    }
}
