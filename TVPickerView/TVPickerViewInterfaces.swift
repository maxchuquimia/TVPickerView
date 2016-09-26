//
//  TVPickerViewInterfaces.swift
//  TVPickerView
//
//  Created by Max Chuquimia on 25/10/2015.
//  Copyright © 2015 Chuquimian Productions. All rights reserved.
//

import UIKit

public protocol TVPickerInterface {
    
    /// An object that listens to custom focus changes of the picker
    weak var focusDelegate: TVPickerViewFocusDelegate? { get set }
    
    /// The data source for the picker
    weak var dataSource: TVPickerViewDataSource? { get set }
    
    weak var delegate: TVPickerViewDelegate? { get set }
    
    /// `true` if the picker is focussed for user data selection
    var deepFocus: Bool { get }
    
    /// The index shown on the picker
    var selectedIndex: Int { get }
    
    /*!
    Reload the contents of the picker. If the visible index before reload is not available after reload, the picker will reset to index zero
    */
    func reloadData()
    
    /*!
    Scroll the picker to a particular index. **This may not work on the simulator!**
    */
    func scrollToIndex(_ idx: Int)
}

public protocol TVPickerViewFocusDelegate: class {
    
    /*!
    Called when the user presses on the picker. This is called within an animation block, so any UI changes made will be animated.
    
    - parameter picker:      the picker
    - parameter isDeepFocus: `true` if the picker is becoming the first responder
    */
    func pickerView(_ picker: TVPickerView, deepFocusStateChanged isDeepFocus: Bool)
}

public protocol TVPickerViewDelegate: class {
    
    /*!
    Called when the picker's index changes definitively. Not sure of a real-world use case for listening to this - instead, take a look at `TVPickerViewFocusDelegate`
    
    - parameter picker: the picker
    - parameter index:  the index
    */
    func pickerView(_ picker: TVPickerView, didChangeToIndex index: Int)
}

public protocol TVPickerViewDataSource: class {
    
    /*!
    Returns the number of view in the picker
    
    - parameter picker: the picker
    
    - returns: the number of views in the picker (unsigned)
    */
    func numberOfViewsInPickerView(_ picker: TVPickerView) -> Int
    
    /*!
    Returns the view for a particular index in the picker
    
    - parameter picker: the picker
    - parameter idx:    the index that will become visible in the near future
    
    - returns: a view to load into the picker for the given index (unsigned)
    */
    func pickerView(_ picker: TVPickerView, viewForIndex idx: Int, reusingView view: UIView?) -> UIView
}
