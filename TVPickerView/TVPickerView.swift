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

@objc open class TVPickerView: UIView, TVPickerInterface {
    
    weak open var focusDelegate: TVPickerViewFocusDelegate?
    weak open var dataSource: TVPickerViewDataSource?
    weak open var delegate: TVPickerViewDelegate?
    
    static fileprivate let AnimationInterval: TimeInterval = 0.1
    static fileprivate let SwipeMultiplier: CGFloat = 0.5
    static fileprivate let MaxDrawn = 4
    
    fileprivate let mover = TVPickerMover()
    fileprivate let contentView = UIView()
    fileprivate let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate(set) open var deepFocus = false {
        didSet {
            UIView.animate(withDuration: TVPickerView.AnimationInterval, animations: deepFocus ? bringIntoDeepFocus : bringOutOfDeepFocus)
            
            if deepFocus {
                becomeFirstResponder()
            }
            else {
                resignFirstResponder()
            }
        }
    }
    
    fileprivate var currentIndex: Int = 0 {
        didSet {
            if currentIndex != oldValue {
                delegate?.pickerView(self, didChangeToIndex: currentIndex)
            }
        }
    }
    
    open var selectedIndex: Int {
        return currentIndex
    }
    
    fileprivate var itemCount: Int = 0
    fileprivate var indexesAndViews = [Int: UIView]()
    
    open func reloadData() {
        
        guard let dataSource = dataSource else {
            return
        }
        
        layoutMargins = UIEdgeInsets.zero
        
        itemCount = dataSource.numberOfViewsInPickerView(self)
        
        loadFromIndex(0)
                
        if currentIndex < itemCount - 1 {
            scrollToIndex(currentIndex, animated: false)
        }
        else {
            scrollToIndex(0, animated: false)
        }
    }
    
    fileprivate func loadFromIndex(_ index: Int) {
        
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.internalScrollToIndex(index, animated: true, multiplier: 2.0, speed: 0.1)
        }
    }
}

extension TVPickerView {
    
    fileprivate func setup() {
        
        visualEffectView.sizeToView(self)
        visualEffectView.clipsToBounds = true
        addSubview(visualEffectView)
        
        contentView.sizeToView(self)
        contentView.backgroundColor = .clear
        addSubview(contentView)
        
        backgroundColor = .clear
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.cornerRadius = 7.0
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 7.0
        visualEffectView.layer.cornerRadius = 7.0
        
        bringOutOfFocus()
    }
}

//MARK: Focus Control

extension TVPickerView {
    
    override open func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
    
        if context.nextFocusedView == self {
            UIView.animate(withDuration: TVPickerView.AnimationInterval, animations: bringIntoFocus)
        }
        else if context.previouslyFocusedView == self {
            UIView.animate(withDuration: TVPickerView.AnimationInterval, animations: bringOutOfFocus)
        }
    }
    
    override open func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        return !deepFocus
    }
    
    fileprivate func bringIntoFocus() {
        layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0)
        layer.shadowRadius = 7.0
        layer.shadowOpacity = 0.2
        contentView.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
    }
    
    fileprivate func bringOutOfFocus() {
        layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        layer.shadowRadius = 0.0
        layer.shadowOpacity = 0.0
        contentView.backgroundColor = .clear
    }
    
    fileprivate func bringIntoDeepFocus() {
        layer.transform = CATransform3DMakeScale(1.4, 1.4, 1.0)
        layer.shadowRadius = 15.0
        layer.shadowOpacity = 0.7
        contentView.backgroundColor = .white
        focusDelegate?.pickerView(self, deepFocusStateChanged: true)
    }
    
    fileprivate func bringOutOfDeepFocus() {
        bringIntoFocus()
        focusDelegate?.pickerView(self, deepFocusStateChanged: false)
    }
    
    override open var canBecomeFocused : Bool {
        return true
    }
    
    override open var canBecomeFirstResponder : Bool {
        return true
    }
}

//MARK: Touch Control 

extension TVPickerView: UIGestureRecognizerDelegate {
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if !deepFocus {
            return
        }
        
        mover.stopGenerating()
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    
        if !deepFocus {
            return
        }
        
        guard let touch = touches.first else {
            return
        }
        
        let lastLocation = touch.previousLocation(in: self)
        let thisLocation = touch.location(in: self)
        
        let dx = thisLocation.x - lastLocation.x
        
        iterate(dx)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if !deepFocus {
            return
        }
        
        scrollToNearestIndex(0.3)
    }
    
    override open func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        
        guard let press = presses.first else {
            return
        }
        
        if press.type == .select {
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
            
        case .upArrow, .rightArrow:
            iterateForwards()
        case .downArrow, .leftArrow:
            iterateBackwards()
        default:
            break
        }
    }
}

//MARK: Iteration

extension TVPickerView {
    
    func iterate(_ dx: CGFloat) {
        
        for (_, v) in indexesAndViews {
            
            let newViewX = dx * TVPickerView.SwipeMultiplier + CGFloat(v.center.x)
            
            let containerCenter = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
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
    
    fileprivate func scrollToNearestIndex(_ speed: TimeInterval, uncancellable: Bool = false) {
        
        let (locatedIndex, offset) = nearestViewToCenter()
 
        if uncancellable  {
            self.currentIndex = locatedIndex
        }
        
        mover.startGenerating(time: speed, totalDistance: offset * 2.0, call: iterate, completed:  {
            //Don't want to tell the delegate until now because the user could cancel the animation
            self.currentIndex = locatedIndex
        })
    }
    
    fileprivate func nearestViewToCenter() -> (index: Int, distance: CGFloat) {
        let targetX = bounds.width / 2.0
        var locatedIndex = 0
        var smallestDistance = CGFloat.greatestFiniteMagnitude
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
    
    public func scrollToIndex(_ idx: Int) {
        scrollToIndex(idx, animated: true)
    }
    
    //TODO: animated doesn't work. Fix it and make it public
    fileprivate func scrollToIndex(_ idx: Int, animated: Bool) {

        let di = abs(idx - currentIndex)
        var a = animated
        
        if di > 5 {
            a = false
        }
        
        internalScrollToIndex(idx, animated: a, multiplier: 2.0, speed: 0.2)
    }
    
    fileprivate func internalScrollToIndex(_ idx: Int, animated: Bool, multiplier: CGFloat, speed: TimeInterval) {
        
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
    
    fileprivate func xPositionForIndex(_ idx: Int) -> CGFloat {
        return ((CGFloat(idx) * frame.width) / CGFloat(2.0)) + frame.width / 2.0
    }
}

//MARK: - Lazy 

extension TVPickerView {

    fileprivate func calculate() {
        
        guard let dataSource = dataSource else {
            return
        }
        
        let indexesDrawn: [Int] = indexesAndViews.keys.map {$0}.sorted(by: <)
        
        if indexesDrawn.count < TVPickerView.MaxDrawn {
        
            //No laziness here!
            return
        }
        
        let (locatedIndex, _) = nearestViewToCenter()
        
        if locatedIndex == 0 || locatedIndex == (itemCount - 1) {
            //TODO: maybe add looping? Nah.
            return
        }
        
        guard let n = indexesDrawn.index(of: locatedIndex) else {
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
        indexesAndViews.removeValue(forKey: reuseIndex)
        
        let newView = dataSource.pickerView(self, viewForIndex: newIndex, reusingView: reusingView)
        indexesAndViews[newIndex] = newView
   
        if newView !== reusingView {
            reusingView?.removeFromSuperview()
            contentView.addSubview(newView.setupForPicker(self))
        }
        
        newView.setX(xPosition, 1.0)
    }
}
