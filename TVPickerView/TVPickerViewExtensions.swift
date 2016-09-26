//
//  TVPickerViewExtensions.swift
//  TVPickerView
//
//  Created by Max Chuquimia on 25/10/2015.
//  Copyright © 2015 Chuquimian Productions. All rights reserved.
//

import UIKit

extension UIView {
    
    /*!
    Setup a view so that it's ready to be positioned in a picker
    
    - parameter picker: the picker this view will appear in
    
    - returns: the receiver
    */
    func setupForPicker(_ picker: TVPickerView) -> Self {
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        let size = CGSize(width: picker.bounds.width / 2.0, height: picker.bounds.height)
        frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        return self
    }
    
    /*!
    Change the x position of the view, and apply any effects
    
    - parameter x:  the actual center x position of the view
    - parameter dx: the distance from the normal position to the offset position, from 0 to 1
    */
    func setX(_ x: CGFloat, _ dx: CGFloat) {
        center.x = x
        let scaleAmount = (1 - max(dx, 0.65)) + 0.65
        layer.transform = CATransform3DMakeScale(1.0 * scaleAmount, 1.0 * scaleAmount, 1.0)
    }

    func sizeToView(_ v: UIView) {
        frame = v.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
