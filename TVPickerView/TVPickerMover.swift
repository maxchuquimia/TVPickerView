//
//  TVPickerMover.swift
//  TVPickerView
//
//  Created by Max Chuquimia on 24/10/2015.
//  Copyright © 2015 Chuquimian Productions. All rights reserved.
//

import UIKit

typealias MoverBlock = ((CGFloat) -> Void)

//TODO: Curve this parabolically

class TVPickerMover: NSObject {
    
    fileprivate var timer: Timer?
    fileprivate var call: MoverBlock?
    fileprivate var completed: ()->() = { }
    fileprivate var stepDistance: CGFloat = 0.0
    fileprivate var steps = 25
    fileprivate var count = 0
    
    func startGenerating(time t: TimeInterval, totalDistance dx: CGFloat, call: @escaping MoverBlock, completed: @escaping ()->() = { } ) {
        
        stopGenerating()
        
        self.call = call
        self.stepDistance = dx / CGFloat(steps)
        self.count = 0
        self.completed = completed
        let time = t / Double(steps)
        
        self.timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(TVPickerMover.timerFired), userInfo: nil, repeats: true)
    }
    
    func stopGenerating() {
        timer?.invalidate()
        timer = nil
    }
    
    func timerFired() {
                
        call?(self.stepDistance)
        
        count = count + 1
        
        if count >= steps {
            stopGenerating()
            completed()
        }
    }
}
