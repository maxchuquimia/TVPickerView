//
//  TVPickerView.swift
//  TVPickerView
//
//  Created by Max Chuquimia on 21/10/2015.
//  Copyright © 2015 Chuquimian Productions. All rights reserved.
//

import UIKit
import QuartzCore

//MARK: TVPickerView Class

@objc public class TVPickerView: UIView, TVPickerInterface {
    
    weak public var focusDelegate: TVPickerViewFocusDelegate?
    weak public var dataSource: TVPickerViewDataSource?
    weak public var delegate: TVPickerViewDelegate?
    
    static private let AnimationInterval: NSTimeInterval = 0.1
    static private let SwipeMultiplier: CGFloat = 0.5
    static private let MaxDrawn = 4
    
    private let mover = TVPickerMover()
    private let contentView = UIView()
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private(set) public var deepFocus = false {
        didSet {
            UIView.animateWithDuration(TVPickerView.AnimationInterval, animations: deepFocus ? bringIntoDeepFocus : bringOutOfDeepFocus)
            
            if deepFocus {
                becomeFirstResponder()
            }
            else {
                resignFirstResponder()
            }
        }
    }
    
    private var currentIndex: Int = 0 {
        didSet {
            if currentIndex != oldValue {
                delegate?.pickerView(self, didChangeToIndex: currentIndex)
            }
        }
    }
    
    public var selectedIndex: Int {
        return currentIndex
    }
    
    private var itemCount: Int = 0
    private var indexesAndViews = [Int: UIView]()
    
    public func reloadData() {
        
        guard let dataSource = dataSource else {
            return
        }
        
        layoutMargins = UIEdgeInsetsZero
        
        itemCount = dataSource.numberOfViewsInPickerView(self)
        
        loadFromIndex(0)
                
        if currentIndex < itemCount - 1 {
            scrollToIndex(currentIndex, animated: false)
        }
        else {
            scrollToIndex(0, animated: false)
        }
    }
    
    private func loadFromIndex(index: Int) {
        
        guard let dataSource = dataSource else {
            return
        }
        
        indexesAndViews.values.forEach({$0.removeFromSuperview()})
        indexesAndViews.removeAll()
        
        var nIndex = index + 1
        
        if nIndex == itemCount {
            nIndex = itemCount - 1
        }
        
        if nIndex >= (itemCount - TVPickerView.MaxDrawn) {
            nIndex = nIndex - TVPickerView.MaxDrawn
        }
        
        if nIndex < 0 {
            nIndex = 0
        }
        
        for idx in nIndex..<min(TVPickerView.MaxDrawn + nIndex, itemCount) {
            let v =  dataSource.pickerView(self, viewForIndex: idx, reusingView: nil)
            contentView.addSubview(v.setupForPicker(self))
            indexesAndViews[idx] = v
            v.setX(xPositionForIndex(idx), 1)
        }
        
        iterate(0)
        scrollToNearestIndex(0.0)

        //Waiting fixes everything
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.internalScrollToIndex(index, animated: true, multiplier: 2.0, speed: 0.1)
        }
    }
}

extension TVPickerView {
    
    private func setup() {
        
        visualEffectView.sizeToView(self)
        visualEffectView.clipsToBounds = true
        addSubview(visualEffectView)
        
        contentView.sizeToView(self)
        contentView.backgroundColor = .clearColor()
        addSubview(contentView)
        
        backgroundColor = .clearColor()
        
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSizeMake(0, 10)
        layer.cornerRadius = 7.0
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 7.0
        visualEffectView.layer.cornerRadius = 7.0
        
        bringOutOfFocus()
    }
}

//MARK: Focus Control

extension TVPickerView {
    
    override public func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
    
        if context.nextFocusedView == self {
            UIView.animateWithDuration(TVPickerView.AnimationInterval, animations: bringIntoFocus)
        }
        else if context.previouslyFocusedView == self {
            UIView.animateWithDuration(TVPickerView.AnimationInterval, animations: bringOutOfFocus)
        }
    }
    
    override public func shouldUpdateFocusInContext(context: UIFocusUpdateContext) -> Bool {
        return !deepFocus
    }
    
    private func bringIntoFocus() {
        layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0)
        layer.shadowRadius = 7.0
        layer.shadowOpacity = 0.2
        contentView.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
    }
    
    private func bringOutOfFocus() {
        layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        layer.shadowRadius = 0.0
        layer.shadowOpacity = 0.0
        contentView.backgroundColor = .clearColor()
    }
    
    private func bringIntoDeepFocus() {
        layer.transform = CATransform3DMakeScale(1.4, 1.4, 1.0)
        layer.shadowRadius = 15.0
        layer.shadowOpacity = 0.7
        contentView.backgroundColor = .whiteColor()
        focusDelegate?.pickerView(self, deepFocusStateChanged: true)
    }
    
    private func bringOutOfDeepFocus() {
        bringIntoFocus()
        focusDelegate?.pickerView(self, deepFocusStateChanged: false)
    }
    
    override public func canBecomeFocused() -> Bool {
        return true
    }
    
    override public func canBecomeFirstResponder() -> Bool {
        return true
    }
}

//MARK: Touch Control 

extension TVPickerView: UIGestureRecognizerDelegate {
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        if !deepFocus {
            return
        }
        
        mover.stopGenerating()
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
    
        if !deepFocus {
            return
        }
        
        guard let touch = touches.first else {
            return
        }
        
        let lastLocation = touch.previousLocationInView(self)
        let thisLocation = touch.locationInView(self)
        
        let dx = thisLocation.x - lastLocation.x
        
        iterate(dx)
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        if !deepFocus {
            return
        }
        
        scrollToNearestIndex(0.3)
    }
    
    override public func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        super.pressesBegan(presses, withEvent: event)
        
        guard let press = presses.first else {
            return
        }
        
        if press.type == .Select {
            let changedValue = !deepFocus
            
            if !changedValue {
                scrollToNearestIndex(0.3, uncancellable: true)
            }
            
            deepFocus = changedValue
        }
        
        if !deepFocus {
            return
        }
            
        switch press.type {
            
        case .UpArrow, .RightArrow:
            iterateForwards()
        case .DownArrow, .LeftArrow:
            iterateBackwards()
        default:
            break
        }
    }
}

//MARK: Iteration

extension TVPickerView {
    
    func iterate(dx: CGFloat) {
        
        for (_, v) in indexesAndViews {
            
            let newViewX = dx * TVPickerView.SwipeMultiplier + CGFloat(v.center.x)
            
            let containerCenter = CGPointMake(bounds.width / 2.0, bounds.height / 2.0)
            let vdx = min(fabs(containerCenter.x - newViewX) / containerCenter.x, 1.0)

            v.setX(newViewX, vdx)
        }
        
        calculate()
    }
    
    func iterateForwards() {
        
        if currentIndex >= (itemCount - 1) {
            return
        }
        
        internalScrollToIndex(currentIndex + 1, animated: true, multiplier: 1.0, speed: 0.1)
    }
    
    func iterateBackwards() {
        
        if currentIndex == 0 {
            return
        }
        
        internalScrollToIndex(currentIndex - 1, animated: true, multiplier: 1.0, speed: 0.1)
    }
    
    private func scrollToNearestIndex(speed: NSTimeInterval, uncancellable: Bool = false) {
        
        let (locatedIndex, offset) = nearestViewToCenter()
 
        if uncancellable  {
            self.currentIndex = locatedIndex
        }
        
        mover.startGenerating(time: speed, totalDistance: offset * 2.0, call: iterate, completed:  {
            //Don't want to tell the delegate until now because the user could cancel the animation
            self.currentIndex = locatedIndex
        })
    }
    
    private func nearestViewToCenter() -> (index: Int, distance: CGFloat) {
        let targetX = bounds.width / 2.0
        var locatedIndex = 0
        var smallestDistance = CGFloat.max
        var offset: CGFloat = 0.0
        for (idx, v) in indexesAndViews {
            let x = v.center.x
            
            let dx = fabs(targetX - x)
            
            if dx < smallestDistance {
                locatedIndex = idx
                smallestDistance = dx
                offset = targetX - x
            }
            
            if smallestDistance < v.frame.width / 2.0 {
                //No need to continue searching at this point
                break
            }
        }
        
        return (locatedIndex, offset)
    }
    
    public func scrollToIndex(idx: Int) {
        scrollToIndex(idx, animated: true)
    }
    
    //TODO: animated doesn't work. Fix it and make it public
    private func scrollToIndex(idx: Int, animated: Bool) {

        let di = abs(idx - currentIndex)
        var a = animated
        
        if di > 5 {
            a = false
        }
        
        internalScrollToIndex(idx, animated: a, multiplier: 2.0, speed: 0.2)
    }
    
    private func internalScrollToIndex(idx: Int, animated: Bool, multiplier: CGFloat, speed: NSTimeInterval) {
        
        if !animated {
            loadFromIndex(idx)
            return
        }
        
        let x = xPositionForIndex(idx)
        let distance = xPositionForIndex(currentIndex) - x
        let s = animated ? speed : 0.0
        mover.startGenerating(time: s, totalDistance: distance * multiplier, call: iterate, completed: {
            self.scrollToNearestIndex(s)
        })
    }
    
    private func xPositionForIndex(idx: Int) -> CGFloat {
        return ((CGFloat(idx) * frame.width) / CGFloat(2.0)) + frame.width / 2.0
    }
}

//MARK: - Lazy 

extension TVPickerView {

    private func calculate() {
        
        guard let dataSource = dataSource else {
            return
        }
        
        let indexesDrawn: [Int] = indexesAndViews.keys.map {$0}.sort(<)
        
        if indexesDrawn.count < TVPickerView.MaxDrawn {
        
            //No laziness here!
            return
        }
        
        let (locatedIndex, _) = nearestViewToCenter()
        
        if locatedIndex == 0 || locatedIndex == (itemCount - 1) {
            //TODO: maybe add looping? Nah.
            return
        }
        
        guard let n = indexesDrawn.indexOf(locatedIndex) else {
            return
        }
        
        //Add / Reuse a view if required
        var newIdx: Int?
        var reuseIndex = 0
        var xPosition: CGFloat = 0.0
        
        let locatedView = indexesAndViews[locatedIndex]!
        
        if n == 0 {
            newIdx = locatedIndex - 1
            reuseIndex = indexesDrawn[TVPickerView.MaxDrawn - 1]
            xPosition = locatedView.center.x - locatedView.bounds.width
        }
        else if n == (TVPickerView.MaxDrawn - 1) {
            newIdx = locatedIndex + 1
            reuseIndex = indexesDrawn[0]
            xPosition = locatedView.center.x + locatedView.bounds.width
        }
        
        guard let newIndex = newIdx else {
            return
        }
        
        let reusingView = indexesAndViews[reuseIndex]
        indexesAndViews.removeValueForKey(reuseIndex)
        
        let newView = dataSource.pickerView(self, viewForIndex: newIndex, reusingView: reusingView)
        indexesAndViews[newIndex] = newView
   
        if newView !== reusingView {
            reusingView?.removeFromSuperview()
            contentView.addSubview(newView.setupForPicker(self))
        }
        
        newView.setX(xPosition, 1.0)
    }
}
