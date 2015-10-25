//
//  ViewController.swift
//  TVPickerView
//
//  Created by Max Chuquimia on 21/10/2015.
//  Copyright © 2015 Chuquimian Productions. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var picker: TVPickerView!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var selectedLabel: UILabel!
    @IBOutlet weak var liveView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        picker.focusDelegate = self
        picker.dataSource = self
        picker.delegate = self
        picker.reloadData()
    }
    
    let colors: [UIColor] = [
        .blackColor(),
        .darkGrayColor(),
        .lightGrayColor(),
        .grayColor(),
        .redColor(),
        .greenColor(),
        .blueColor(),
        .cyanColor(),
        .yellowColor(),
        .magentaColor(),
        .orangeColor(),
        .purpleColor(),
        .brownColor(),
        .blackColor(),
        .darkGrayColor(),
        .lightGrayColor(),
        .grayColor(),
        .redColor(),
        .greenColor(),
        .blueColor(),
        .cyanColor(),
        .yellowColor(),
        .magentaColor(),
        .orangeColor(),
        .purpleColor(),
        .brownColor(),
        .blackColor(),
        .darkGrayColor(),
        .lightGrayColor(),
        .grayColor(),
        .redColor(),
        .greenColor(),
        .blueColor(),
        .cyanColor(),
        .yellowColor(),
        .magentaColor(),
        .orangeColor(),
        .purpleColor(),
        .brownColor(),
        .blackColor(),
        .darkGrayColor(),
        .lightGrayColor(),
        .grayColor(),
        .redColor(),
        .greenColor(),
        .blueColor(),
        .cyanColor(),
        .yellowColor(),
        .magentaColor(),
        .orangeColor(),
        .purpleColor(),
        .brownColor(),
    ]
}

extension ViewController {
 
    
    @IBAction func topButtonTapped(sender: AnyObject) {
        print("This button is here so that the picker is not in focus by default #justdemothings")
    }
    
    @IBAction func firstButtonTapped(sender: AnyObject) {
        picker.scrollToIndex(0)
    }
    
    @IBAction func midButtonTapped(sender: AnyObject) {
        picker.scrollToIndex(colors.count / 2)
    }
    
    @IBAction func lastButtonTapped(sender: AnyObject) {
        picker.scrollToIndex(colors.count - 1)
    }
}

extension ViewController: TVPickerViewFocusDelegate {
    
    func pickerView(picker: TVPickerView, deepFocusStateChanged isDeepFocus: Bool) {

        if !isDeepFocus {
            selectedLabel.text = "User exited picker at index:\n\(picker.selectedIndex)"
            selectedView.backgroundColor = colors[picker.selectedIndex]
        }
    }
}

extension ViewController: TVPickerViewDataSource {
   
    func numberOfViewsInPickerView(picker: TVPickerView) -> Int {
        return colors.count
    }
    
    func pickerView(picker: TVPickerView, viewForIndex idx: Int, reusingView view: UIView?) -> UIView {
        
        var sview = view as? UILabel
        
        if sview == nil {
            sview = UILabel()
            sview!.textColor = .whiteColor()
            sview!.font = .systemFontOfSize(30)
            sview!.textAlignment = .Center
        }
        
        sview!.backgroundColor = colors[idx]
        sview!.text = " \(idx)"
        
        return sview!
    }
}

extension ViewController: TVPickerViewDelegate {
    func pickerView(picker: TVPickerView, didChangeToIndex index: Int) {
        liveView.backgroundColor = colors[index]
    }
}
