//
//  IHRSubmit.swift
//  QRCodeReader
//
//  Created by Angelina Choi on 2015-01-14.
//  Copyright (c) 2015 Angelina Choi. All rights reserved.
//

import UIKit
import Foundation
import MessageUI

class IHRSubmit: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var translatedQRCode: UITextView!
    @IBOutlet weak var labelFirstName: UILabel!
    @IBOutlet weak var labelLastName: UILabel!
    @IBOutlet weak var labelInitial: UILabel!
    @IBOutlet weak var labelGender: UILabel!
    @IBOutlet weak var labelHCN: UILabel!
    @IBOutlet weak var labelDOB: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var labelProvince: UILabel!
    @IBOutlet weak var labelPublicHealthUnit: UILabel!
 
    override func shouldAutorotate() -> Bool {
        return false // Device orientation is portrait only.
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceFlipped", name: UIDeviceOrientationDidChangeNotification, object: nil)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "vaccine.jpg")!)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        translatedQRCode.text = userDefaults.stringForKey("QRTRANSLATED")
        labelFirstName.text = userDefaults.stringForKey("patientFName")
        labelLastName.text = userDefaults.stringForKey("patientLName")
        labelInitial.text = userDefaults.stringForKey("patientInit")
        labelGender.text = userDefaults.stringForKey("patientGend")
        labelHCN.text = userDefaults.stringForKey("patientHCN")
        labelDOB.text = userDefaults.stringForKey("patientDOB")
        labelEmail.text = userDefaults.stringForKey("patientMail")
        labelProvince.text = userDefaults.stringForKey("patientPro")
        labelPublicHealthUnit.text = userDefaults.stringForKey("patientPHU")

// carry info from previous screen


    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deviceFlipped() {
        switch UIDevice.currentDevice().orientation {
        case .FaceDown:
            self.performSegueWithIdentifier("submitToLogin", sender: self)
            println("face down")
        default:
            println("Device is not face down")
        }
    }

    @IBAction func cancelAll(sender: UIButton) { // If user wants to botch everything, return to main screen
        
        let screenAlert: UIAlertController = UIAlertController(title: "Confirm Data", message: "Once you go to the Main Screen, all information will be cleared. Continue?", preferredStyle: UIAlertControllerStyle.Alert)
        screenAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
            self.performSegueWithIdentifier("cancelBackToMain", sender: self)
        }))
        screenAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(screenAlert, animated: true, completion: nil)
    }
    
    @IBAction func submitInfo(sender: UIButton) {
        if translatedQRCode.text != "" {
            //self.postParameters("http://pportal.mybluemix.net/IHRreader") // Send data to server

            self.postJSON("http://libertyjavaopal.mybluemix.net/rest/api/client")
            
            let alert: UIAlertController = UIAlertController(title: "Success", message: "Information was successfully submitted.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                // Additional option to send digital receipt to patients via Email
                let emailOptional: UIAlertController = UIAlertController(title: "Digital Receipt", message: "Would you like to send this information through email as a digital receipt?", preferredStyle: UIAlertControllerStyle.Alert)
                emailOptional.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                    self.sendEmail() // Function to send email to patient's email address
                    self.performSegueWithIdentifier("cancelBackToMain", sender: self)
                    
                    
                }))
                emailOptional.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                    self.performSegueWithIdentifier("cancelBackToMain", sender: self)
                }))
                self.presentViewController(emailOptional, animated: true, completion: nil)
                // If no digital receipt required, that's that.
            }))
            self.presentViewController(alert, animated: true, completion: nil) // Alert message to indicate that data was successfully sent
        } else {
            let alert: UIAlertController = UIAlertController(title: "Error", message: "No valid QR Code has been translated.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func retrieveJsonFromData(data: NSData) -> NSDictionary {
        
        /* Now try to deserialize the JSON object into a dictionary */
        var error: NSError?
        
        let jsonObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
            options: .AllowFragments,
            error: &error)
        
        if  error == nil {
            
            println("Successfully deserialized...")
            
            if jsonObject is NSDictionary{
                let deserializedDictionary = jsonObject as NSDictionary
                println("Deserialized JSON Dictionary = \(deserializedDictionary)")
                return deserializedDictionary
            }
            else {
                /* Some other object was returned. We don't know how to
                deal with this situation because the deserializer only
                returns dictionaries or arrays */
            }
        }
        else if error != nil{
            println("An error happened while deserializing the JSON data.")
        }
        return NSDictionary()
    }
    
    func sendEmail() { // Function to send email for digital receipt
        var picker: MFMailComposeViewController = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setSubject("Digital Receipt of Patient: \(String(labelFirstName.text!)) \(String(labelLastName.text!))") // Subject of Email
        // Body of Email, outlining the information of patient and vaccinations administered
        let emailMessageBodyPart1 = "Medical Receipt of Patient \(String(labelFirstName.text!)) \(String(labelLastName.text!))\nFirst Name: \(String(labelFirstName.text!))\rLast Name: \(String(labelLastName.text!))\nInitial: \(String(labelInitial.text!))\n\rGender: \(String(labelGender.text!))\r"
        let emailMessageBodyPart2 = "\rHealth Card Number: \(String(labelHCN.text!))\nDate of Birth: \(String(labelDOB.text!))\nProvince: \(String(labelProvince.text!))\nPublic Health Unit: \(String(labelPublicHealthUnit.text!))\n Vaccination information would go here, still in process.\nSincerely, your health person"
        let emailBody = emailMessageBodyPart1 + emailMessageBodyPart2
        picker.setMessageBody(emailBody, isHTML: true)
        picker.setToRecipients(["\(String(labelEmail.text!))"])
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    //MFMailComposeViewControllerDelegate
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        switch result.value {
        case MFMailComposeResultCancelled.value:
            NSLog("Mail cancelled")
        case MFMailComposeResultSaved.value:
            NSLog("Mail saved")
        case MFMailComposeResultSent.value:
            NSLog("Mail sent")
        case MFMailComposeResultFailed.value:
            NSLog("Mail sent failure: %@", [error.localizedDescription])
        default:
            break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("cancelBackToMain", sender: self)
    }
    
    func postJSON(url: String) { // Send POST requesnt using JSON transmission
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        let timeFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        timeFormatter.dateFormat = "HH:mm"
        var dateinformat: String = dateFormatter.stringFromDate(date)
        var timeinformat: String = timeFormatter.stringFromDate(date)
        
        let vaccineJSON = (translatedQRCode.text as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        let vaccineDict: NSDictionary = retrieveJsonFromData(vaccineJSON!)
        
        let agent = vaccineDict["vaccine"]?.valueForKey("agent") as String!
        let lotNumber = vaccineDict["vaccine"]?.valueForKey("lotNumber") as String!
        let manufacturer = vaccineDict["vaccine"]?.valueForKey("manufacturer") as String!
        let gtin = vaccineDict["vaccine"]?.valueForKey("gtin") as String!
        println(agent)
        var patientParams = ["firstname": "\(String(labelFirstName.text!))",
            "lastname": "\(String(labelLastName.text!))",
            "initials": "\(String(labelInitial.text!))",
            "middlename": "",
            "gender": "\(String(labelGender.text!))",
            "hcn": "\(String(labelHCN.text!))",
            "dob": "\(String(labelDOB.text!))",
            "email": "\(String(labelEmail.text!))",
            "phu":"\(String(labelPublicHealthUnit.text!))"] as Dictionary
        
        var vaccineParams = [ "dateAdministered": dateinformat,
            "timeAdministered": timeinformat,
            "agent": agent,
            "lotNumber": lotNumber,
            "manufacture": manufacturer,
            "gtin": gtin
        ] as Dictionary
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let selectedPHU = userDefaults.stringForKey("selectedPublicHealthUnit")
        let providerUsername = userDefaults.stringForKey("providerUsername")
        
        var providerParams = ["providerUserName": providerUsername,
            "providerID": "3489578390",
            "selectedPHU": selectedPHU]
        
        
        var mainParams:[NSString : AnyObject] = ["application": "QR-ME v1.0",
            "timestamp": timeinformat,
            "date": dateinformat,
            "patient": patientParams,
            "vaccine": vaccineParams
            ]
        var err: NSError?
        
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(mainParams, options: nil, error: &err)
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
    }
    
    func postParameters(url: String) { // Send POST request using parameters
        
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST" // Confirm type of request: POST
        
        let qrCodeID: Int = 1234567890 // QR Code ID not in yet. Using dummy ID for now.
        var bodyData = "First+Name=\(String(labelFirstName.text!))&Last+Name=\(String(labelLastName.text!))&Initial=\(String(labelInitial.text!))&Gender=\(labelGender.text)&Date+Of+Birth=\(labelDOB.text)&Health+Card_Number=\(labelHCN.text)&Email=\(labelEmail.text)&Province=\(labelProvince.text)&Public+Health+Unit=\(labelPublicHealthUnit.text)&QR+Code+ID=\(qrCodeID)" // data of the fields to put in request.
        
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("text/html", forHTTPHeaderField: "Accept")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
            {
                (response: NSURLResponse!, data: NSData!, error: NSError!) in
                println(NSString(data: data, encoding: NSUTF8StringEncoding))
            
            }}

}

class myCustomButton: UIButton {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = UIColor.blueColor().CGColor
        self.layer.borderWidth = 1.5
    }
}