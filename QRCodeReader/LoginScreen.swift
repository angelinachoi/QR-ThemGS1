//
//  LoginScreen.swift
//  QRCodeReader
//
//  Created by Angelina Choi on 2015-02-05.
//  Copyright (c) 2015 Angelina Choi. All rights reserved.
//

import UIKit
import Foundation

class LoginScreen: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var inputUsername: UITextField!
    @IBOutlet weak var inputPassword: UITextField!
    @IBOutlet weak var inputPHU: UITextField!
    
    @IBOutlet weak var loginViewSquare: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var phuPicker: UIPickerView!
    let publicHealthUnitList = ["", "Grey Bruce", "Hamilton", "Toronto"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputPHU.delegate = self
        phuPicker.delegate = self
        phuPicker.hidden = true
        loginButton.layer.cornerRadius = 5.0
        loginButton.layer.borderWidth = 2.0
        loginViewSquare.layer.borderWidth = 3.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return publicHealthUnitList.count
    }
    
    func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String! {
        return publicHealthUnitList[row]
    }
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        inputPHU.text = publicHealthUnitList[row]
        if inputPHU.text == "Grey Bruce" {
            customizeScreen(UIColor(red: 171.0/255.0, green: 118.0/255.5, blue: 12.0/255.0, alpha: 1.0), buttonBorderColor: UIColor(red: 171.0/255.0, green: 118.0/255.5, blue: 12.0/255.0, alpha: 1.0).CGColor, buttonColor: UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 48.0/255.0, alpha: 1.0), loginSquareBorderColor: UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 48.0/255.0, alpha: 1.0).CGColor, buttonTextColor: UIColor(red: 171.0/255.0, green: 118.0/255.5, blue: 12.0/255.0, alpha: 1.0), loginLogoImage: UIImage(named: "PublicHealthGreyBruce.jpg")!)
        } else if inputPHU.text == "Hamilton" {
            customizeScreen(UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 145.0/255.0, alpha: 1.0), buttonBorderColor: UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 145.0/255.0, alpha: 1.0).CGColor, buttonColor: UIColor(red: 254.0/255.0, green: 218.0/255.5, blue: 170.0/255.0, alpha: 1.0), loginSquareBorderColor: UIColor(red: 254.0/255.0, green: 218.0/255.5, blue: 170.0/255.0, alpha: 1.0).CGColor, buttonTextColor: UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 145.0/255.0, alpha: 1.0), loginLogoImage: UIImage(named: "PublicHealthHamilton.jpg")!)
        } else if inputPHU.text == "Toronto" {
            customizeScreen(UIColor(red: 0.0/255.0, green: 0.0/255.5, blue: 0.0/255.0, alpha: 1.0), buttonBorderColor: UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).CGColor, buttonColor: UIColor(red: 0.0/255.0, green: 0.0/255.5, blue: 0.0/255.0, alpha: 1.0), loginSquareBorderColor: UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).CGColor, buttonTextColor: UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0), loginLogoImage: UIImage(named: "PublicHealthToronto.jpg")!)
        } else if inputPHU.text == "" {
            customizeScreen(UIColor.lightGrayColor(), buttonBorderColor: UIColor.whiteColor().CGColor, buttonColor: UIColor.darkGrayColor(), loginSquareBorderColor: UIColor.whiteColor().CGColor, buttonTextColor: UIColor.whiteColor(), loginLogoImage: UIImage(named: "blue logo.png")!)
        }
        phuPicker.hidden = true
    }
    
    func customizeScreen(viewBackgroundColor: UIColor, buttonBorderColor: CGColor, buttonColor: UIColor,loginSquareBorderColor: CGColor, buttonTextColor: UIColor, loginLogoImage: UIImage) { // Function to customize screen to public health colours
        self.view.backgroundColor = viewBackgroundColor // Set background color
        loginButton.backgroundColor = buttonColor // Set button background color
        loginButton.layer.borderColor = buttonBorderColor // Set button border color
        loginViewSquare.layer.borderColor = loginSquareBorderColor // Set border colour of small login square view
        loginButton.setTitleColor(buttonTextColor, forState: UIControlState.Normal) // Set button text color
        logoImage.image = loginLogoImage // Set logo depending on PHU chosen
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        phuPicker.hidden = false
        return false
    }

    @IBAction func userLogIn(sender: AnyObject) { // User tries to log in
        //Check if user name and PIN are valid.
        //If not, send error message.
        if inputPHU.text == "" || inputUsername.text == "" || inputPassword.text == "" {
            let PHUalert: UIAlertController = UIAlertController(title: "Error", message: "Please fill all the fields.", preferredStyle: UIAlertControllerStyle.Alert)
            PHUalert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(PHUalert, animated: true, completion: nil)
        } else {
            var request = NSMutableURLRequest(URL: NSURL(string: "http://libertyjavaopal.mybluemix.net/rest/api/client")!)
            var session = NSURLSession.sharedSession()
            request.HTTPMethod = "POST"
            
            var params = ["Username": "\(String(inputUsername.text!))", "Password": "\(String(inputPassword.text!))", "PHU": "\(String(inputPHU.text!))"] as Dictionary
            var err: NSError?
            
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                println("Response: \(response)")
                var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Body: \(strData)")
                var err: NSError?
                var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err)
                
                if (err != nil) { // Did the JSONOBjectData constructor return an error?
                    println(err!.localizedDescription)
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: '\(jsonStr)'")
                }
                else { // The JSONObjectWithData constructor didn't return an error.
                    // Should still check to ensure that json has a value using optional binding.
                    if let parseJSON: AnyObject = json {
                        // The parsedJSON is here, let's get the value for success out of it.
                        var success = parseJSON["success"] as? Int
                        println("Success: \(success)")
                    }
                    else {
                        // json object was nil, something went wrong. Maybe server isn't running?
                        let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                        println("Error could not parse JSON: \(jsonStr)")
                    }
                }
            })
            task.resume()
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(inputPHU.text, forKey: "selectedPublicHealthUnit")
            userDefaults.setObject(inputUsername.text, forKey: "providerUsername")
            userDefaults.synchronize() // Carry Public Health Unit information
            
            userDefaults.synchronize()
            self.performSegueWithIdentifier("loginToWelcomeScreen", sender: self) // Go to Welcome screen.
        }
    }
    
}