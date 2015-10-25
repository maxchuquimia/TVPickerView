//
//  TVPickerMover.swift
//  TVPickerView
//
//  Created by Max Chuquimia on 24/10/2015.
//  Copyright © 2015 Chuquimian Productions. All rights reserved.
//

import UIKit

typealias MoverBlock = (CGFloat -> Void)

//TODO: Curve this parabolically

class TVPickerMover: NSObject {
    
    private var timer: NSTimer?
    private var call: MoverBlock?
    private var completed: dispatch_block_t?
    private var stepDistance: CGFloat = 0.0
    private var steps = 25
    private var count = 0
    
    func startGenerating(time t: NSTimeInterval, totalDistance dx: CGFloat, call: MoverBlock, completed: dispatch_block_t? = nil) {
        
        stopGenerating()
        
        self.call = call
        self.stepDistance = dx / CGFloat(steps)
        self.count = 0
        self.completed = completed
        let time = t / Double(steps)
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: "timerFired", userInfo: nil, repeats: true)
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
            completed?()
        }
    }
}
