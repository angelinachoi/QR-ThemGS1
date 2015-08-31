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
    @IBOutlet weak var phuPicker: UIPickerView! // variable for text fields and logo imageView
    let publicHealthUnitList = ["", "Grey Bruce", "Hamilton", "Toronto", "Niagara", "Peel"] // List of PHUs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputPHU.delegate = self
        phuPicker.delegate = self
        phuPicker.hidden = true // PHU pickerView is hidden.
        
        loginButton.layer.cornerRadius = 5.0
        loginButton.layer.borderWidth = 2.0
        loginViewSquare.layer.borderWidth = 3.0 // Prettify the borders of button and square for visual appeal
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "vaccine.jpg")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1 // returns number of columns in pickerView
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return publicHealthUnitList.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return publicHealthUnitList[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        inputPHU.text = publicHealthUnitList[row]
        // Colour of button and frame as well as logo depend on which PHU is selected.
        // Colours correspond to Logo of PHU's signature colours
        
        if inputPHU.text == "Grey Bruce" {
            customizeScreen(UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 48.0/255.0, alpha: 1.0).CGColor, buttonColor: UIColor(red: 171.0/255.0, green: 118.0/255.5, blue: 12.0/255.0, alpha: 1.0), loginSquareBorderColor: UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 48.0/255.0, alpha: 1.0).CGColor, buttonTextColor: UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 48.0/255.0, alpha: 1.0), loginLogoImage: UIImage(named: "Grey Bruce Logo.png")!)
            //UIColor(red: 171.0/255.0, green: 118.0/255.5, blue: 12.0/255.0, alpha: 1.0) caramel
            //UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 48.0/255.0, alpha: 1.0) green
        } else if inputPHU.text == "Hamilton" {
            customizeScreen(UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 145.0/255.0, alpha: 1.0).CGColor, buttonColor: UIColor(red: 254.0/255.0, green: 218.0/255.5, blue: 170.0/255.0, alpha: 1.0), loginSquareBorderColor: UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 145.0/255.0, alpha: 1.0).CGColor, buttonTextColor: UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 145.0/255.0, alpha: 1.0), loginLogoImage: UIImage(named: "Hamilton Logo.png")!)
            
            //UIColor(red: 254.0/255.0, green: 218.0/255.5, blue: 170.0/255.0, alpha: 1.0) peach
            //UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 145.0/255.0, alpha: 1.0) blue
        } else if inputPHU.text == "Toronto" {
            customizeScreen(UIColor.lightGrayColor().CGColor, buttonColor: UIColor.blackColor(), loginSquareBorderColor: UIColor.lightGrayColor().CGColor, buttonTextColor: UIColor.whiteColor(), loginLogoImage: UIImage(named: "Toronto Logo.png")!)
        } else if inputPHU.text == "Niagara" {
            customizeScreen(UIColor(red: 0.0/255.0, green: 82.0/255.5, blue: 99.0/255.0, alpha: 1.0).CGColor, buttonColor: UIColor(red: 141.0/255.0, green: 194.0/255.5, blue: 69.0/255.0, alpha: 1.0), loginSquareBorderColor: UIColor(red: 0.0/255.0, green: 82.0/255.5, blue: 99.0/255.0, alpha: 1.0).CGColor, buttonTextColor: UIColor(red: 0.0/255.0, green: 82.0/255.5, blue: 99.0/255.0, alpha: 1.0), loginLogoImage: UIImage(named: "Niagara Logo.png")!)
            
            //UIColor(red: 141.0/255.0, green: 194.0/255.5, blue: 69.0/255.0, alpha: 1.0) niagara green
            //UIColor(red: 0.0/255.0, green: 82.0/255.5, blue: 99.0/255.0, alpha: 1.0) niagara teal
        } else if inputPHU.text == "Peel" {
            customizeScreen(UIColor(red: 51.0/255.0, green: 102.0/255.5, blue: 153.0/255.0, alpha: 1.0).CGColor, buttonColor: UIColor(red: 104.0/255.0, green: 174.0/255.5, blue: 224.0/255.0, alpha: 1.0), loginSquareBorderColor: UIColor(red: 51.0/255.0, green: 102.0/255.5, blue: 153.0/255.0, alpha: 1.0).CGColor, buttonTextColor: UIColor(red: 51.0/255.0, green: 102.0/255.5, blue: 153.0/255.0, alpha: 1.0), loginLogoImage: UIImage(named: "Peel Logo.png")!)
        
        } else if inputPHU.text == "" { // If no PHU is selected, colours and logo are defaulted
            customizeScreen(UIColor.whiteColor().CGColor, buttonColor: UIColor.darkGrayColor(), loginSquareBorderColor: UIColor.whiteColor().CGColor, buttonTextColor: UIColor.whiteColor(), loginLogoImage: UIImage(named: "Ontario Logo.png")!)
        }
        phuPicker.hidden = true // After the PHU is selected, pickerView is hidden unless PHU text field is selected again.
    }
    
    func customizeScreen(buttonBorderColor: CGColor, buttonColor: UIColor,loginSquareBorderColor: CGColor, buttonTextColor: UIColor, loginLogoImage: UIImage) { // Function to customize screen to public health colours
        loginButton.backgroundColor = buttonColor // Set button background color
        loginButton.layer.borderColor = buttonBorderColor // Set button border color
        loginViewSquare.layer.borderColor = loginSquareBorderColor // Set border colour of small login square view
        loginButton.setTitleColor(buttonTextColor, forState: UIControlState.Normal) // Set button text color
        logoImage.image = loginLogoImage // Set logo depending on PHU chosen
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool { // When text field is edited, PHUpicker is hidden.
        self.view.endEditing(true)
        phuPicker.hidden = false
        return false
    }

    @IBAction func userLogIn(sender: AnyObject) { // User tries to log in
        //Check if user name and PIN are valid.
        //If not, send error message.
        if inputPHU.text == "" || inputUsername.text == "" || inputPassword.text == "" { // Ensures all fields are filled before transitioning to the next screen.
            let PHUalert: UIAlertController = UIAlertController(title: "Error", message: "Please fill all the fields.", preferredStyle: UIAlertControllerStyle.Alert)
            PHUalert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(PHUalert, animated: true, completion: nil)
            // Message box alerts user that all fields need to be filled before transitioning.
            
        } else {
            /*
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
            */
            // Above part is coding to verfiy username and password by submitting it to the server. Still in development.
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(inputPHU.text, forKey: "selectedPublicHealthUnit")
            userDefaults.setObject(inputUsername.text, forKey: "providerUsername")
            userDefaults.setObject("345345345345", forKey: "providerID") // Carry PHU values in the form of strings to other screens. Provider ID is dummy data. Implements for ID still in development.
            userDefaults.synchronize() // Carry Public Health Unit information
            
            self.performSegueWithIdentifier("loginToWelcomeScreen", sender: self) // Go to Welcome screen.
        }
    }
    
}