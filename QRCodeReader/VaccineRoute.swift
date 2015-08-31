//
//  ViewController.swift
//  test02
//
//  Created by Angelina Choi on 2015-01-30.
//  Copyright (c) 2015 Angelina Choi. All rights reserved.
//

import UIKit
import Foundation

class VaccineRoute: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource {

    @IBOutlet var routePicker: UIPickerView! // Blue Picker
    @IBOutlet var sitePicker: UIPickerView! // Red Picker
    @IBOutlet var siteTextField: UITextField!
    @IBOutlet var routeTextField: UITextField!
    @IBOutlet var vaccineButton: UIButton!
    
    let routeList = ["ID: Intradermal", "IM: Intramuscular", "IN: Intranasal", "PO: Oral", "SC: Subcutaneous"]
    let siteList = ["Anterolateral Thigh Lt", "Anterolateral Thigh Rt", "Arm Lt", "Arm Rt", "Deltoid Lt", "Deltoid Rt", "Forearm Lt", "Forearm Rt", "Gluteal Lt", "Gluteal Rt", "Inferior Deltoid Lt", "Inferior Deltoid Rt", "Mouth", "Naris Lt", "Naris Rt", "Other", "Superior Deltoid Lt", "Superior Deltoid Rt", "Unknown"]
    // List for all possible sites and routes for vaccinations
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        routePicker.hidden = true
        sitePicker.hidden = true
        
        routePicker.tag = 0
        sitePicker.tag = 1
        
        routePicker.delegate = self
        sitePicker.delegate = self
        
        routeTextField.delegate = self
        siteTextField.delegate = self
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "vaccine.jpg")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView.tag == 0 {
            return routeList[row]
        } else if pickerView.tag == 1 {
            return siteList[row]
        }
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            routeTextField.text = routeList[row]
            routePicker.hidden = true
        } else if pickerView.tag == 1 {
            siteTextField.text = siteList[row]
            sitePicker.hidden = true
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == siteTextField {
            sitePicker.hidden = false
            routePicker.hidden = true
        } else if textField == routeTextField {
            routePicker.hidden = false
            sitePicker.hidden = true
        }
        return false
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return routeList.count
        } else if pickerView.tag == 1 {
            return siteList.count
        }
        return 1
    }
    
    @IBAction func vaccineProceed(sender: AnyObject) {
        if siteTextField.text != "" && routeTextField.text != "" {
            let alert: UIAlertController = UIAlertController(title: "Confirm", message: "Route is \(routeTextField.text) and Site is \(siteTextField.text). Continue?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let alert: UIAlertController = UIAlertController(title: "Error", message: "All fields must be completed with valid data.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

