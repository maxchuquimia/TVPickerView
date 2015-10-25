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
    func setupForPicker(picker: TVPickerView) -> Self {
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        
        let size = CGSizeMake(CGRectGetWidth(picker.bounds) / 2.0, CGRectGetHeight(picker.bounds))
        frame = CGRectMake(0, 0, size.width, size.height)
        
        return self
    }
    
    /*!
    Change the x position of the view, and apply any effects
    
    - parameter x:  the actual center x position of the view
    - parameter dx: the distance from the normal position to the offset position, from 0 to 1
    */
    func setX(x: CGFloat, _ dx: CGFloat) {
        center.x = x
        let scaleAmount = (1 - max(dx, 0.65)) + 0.65
        layer.transform = CATransform3DMakeScale(1.0 * scaleAmount, 1.0 * scaleAmount, 1.0)
    }

    func sizeToView(v: UIView) {
        frame = v.bounds
        autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }
}
