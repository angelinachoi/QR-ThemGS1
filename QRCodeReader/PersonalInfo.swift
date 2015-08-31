//
//  PersonalInfo.swift
//  QRCodeReader
//
//  Created by Angelina Choi on 2015-01-13.

import UIKit
import Foundation

class PersonalInfo: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var userFirstName: UITextField!
    @IBOutlet weak var userLastName: UITextField!
    @IBOutlet weak var userInitial: UITextField!
    @IBOutlet weak var userGender: UITextField!
    @IBOutlet weak var userDOB: UITextField!
    @IBOutlet weak var userHCN: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var personalInfoLabel: UILabel!
    
    @IBOutlet weak var userPublicHealthUnit: UITextField!
    @IBOutlet weak var userProvince: UITextField! // Variables for information text fields
    
    @IBOutlet weak var genderPicker: UIPickerView! = UIPickerView()
    @IBOutlet weak var provincePicker: UIPickerView! = UIPickerView()
    @IBOutlet weak var publicHealthUnitPicker: UIPickerView! = UIPickerView()
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    let nonCharacterSet: NSCharacterSet = NSCharacterSet(charactersInString: "1234567890_+=!@#$%^&*(),./;~`[]{}|<>?:")
    let hcnNumberSet: NSCharacterSet = NSCharacterSet(charactersInString: "1234567890")
    
    let genderList = ["","Male", "Female", "Other"]
    let provinceList = ["", "British Columbia", "Alberta", "Saskatchewan", "Manitoba", "Ontario", "Quebec", "New Brunswick", "Nova Scotia", "Prince Edward Island", "Newfoundland & Labrador"]
    let publicHealthUnitList = ["", "Grey Bruce", "Niagara", "Toronto", "Ottawa", "Waterloo"]
    
    //infoToLogin segue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceFlipped", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
            userFirstName.text = userDefaults.stringForKey("patientFName")
            userLastName.text = userDefaults.stringForKey("patientLName")
            userInitial.text = userDefaults.stringForKey("patientInit")
            userGender.text = userDefaults.stringForKey("patientGend")
            userHCN.text = userDefaults.stringForKey("patientHCN")
            userDOB.text = userDefaults.stringForKey("patientDOB")
            userEmail.text = userDefaults.stringForKey("patientMail")
            userProvince.text = userDefaults.stringForKey("patientPro")
            userPublicHealthUnit.text = userDefaults.stringForKey("patientPHU") // carry info from previous screen
        
        if userFirstName.text == userDefaults.stringForKey("patientFName") && userFirstName.text != "" {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(userFirstName.text, forKey: "fName")
            userDefaults.setObject(userLastName.text, forKey: "lName")
            userDefaults.setObject(userInitial.text, forKey: "init")
            userDefaults.setObject(userDOB.text, forKey: "doBirth")
            userDefaults.setObject(userGender.text, forKey: "gender")
            userDefaults.setObject(userHCN.text, forKey: "hcn")
            userDefaults.setObject(userProvince.text, forKey: "province")
            userDefaults.setObject(userPublicHealthUnit.text, forKey: "publicHealthUnit")
            userDefaults.synchronize()
        } // Receives data from previous screen if patient QR Code was scanned and accepted.

        userLastName.autocapitalizationType = UITextAutocapitalizationType.Words
        userFirstName.autocapitalizationType = UITextAutocapitalizationType.Words // Auto-capitalize

        customPHUScreen()
        genderPicker.hidden = true
        provincePicker.hidden = true
        publicHealthUnitPicker.hidden = true
        
        genderPicker.tag = 0
        provincePicker.tag = 1
        publicHealthUnitPicker.tag = 2 // Distinct tags for each pivkerview
        
        genderPicker.delegate = self
        provincePicker.delegate = self
        publicHealthUnitPicker.delegate = self
        
        userGender.delegate = self
        userProvince.delegate = self
        userPublicHealthUnit.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deviceFlipped() {
        switch UIDevice.currentDevice().orientation {
        case .FaceDown:
            self.performSegueWithIdentifier("infoToLogin", sender: self)
            println("face down")
        default:
            println("Device is not face down")

        }
    }
    
    func customPHUScreen() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var selectedPHU = userDefaults.stringForKey("selectedPublicHealthUnit")
        
        if selectedPHU == "Grey Bruce" {
            logoImage.image = UIImage(named: "PublicHealthGreyBruce.jpg")
            self.view.backgroundColor = UIColor(red: 171.0/255.0, green: 118.0/255.5, blue: 12.0/255.0, alpha: 1.0) //caramel
            personalInfoLabel.textColor = UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 48.0/255.0, alpha: 1.0) // green
            backButton.backgroundColor = UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 48.0/255.0, alpha: 1.0)
            backButton.layer.borderColor = UIColor.blackColor().CGColor
            backButton.setTitleColor(UIColor(red: 171.0/255.0, green: 118.0/255.5, blue: 12.0/255.0, alpha: 1.0), forState: UIControlState.Normal)
            submitButton.backgroundColor = UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 48.0/255.0, alpha: 1.0)
            submitButton.layer.borderColor = UIColor.blackColor().CGColor
            submitButton.setTitleColor(UIColor(red: 171.0/255.0, green: 118.0/255.5, blue: 12.0/255.0, alpha: 1.0), forState: UIControlState.Normal)

        } else if selectedPHU == "Hamilton" {
            logoImage.image = UIImage(named: "PublicHealthHamilton.jpg")
            self.view.backgroundColor = UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 145.0/255.0, alpha: 1.0) // blue
            personalInfoLabel.textColor = UIColor(red: 254.0/255.0, green: 218.0/255.5, blue: 170.0/255.0, alpha: 1.0) // peach
            backButton.backgroundColor = UIColor(red: 254.0/255.0, green: 218.0/255.5, blue: 170.0/255.0, alpha: 1.0)
            backButton.layer.borderColor = UIColor.blackColor().CGColor
            backButton.setTitleColor(UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 145.0/255.0, alpha: 1.0), forState: UIControlState.Normal)
            submitButton.backgroundColor = UIColor(red: 254.0/255.0, green: 218.0/255.5, blue: 170.0/255.0, alpha: 1.0)
            submitButton.layer.borderColor = UIColor.blackColor().CGColor
            submitButton.setTitleColor(UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 145.0/255.0, alpha: 1.0), forState: UIControlState.Normal)
        } else if selectedPHU == "Toronto" {
            logoImage.image = UIImage(named: "blue logo.png")
            self.view.backgroundColor = UIColor.darkGrayColor()
            personalInfoLabel.textColor = UIColor.lightGrayColor()
            
            backButton.backgroundColor = UIColor.blackColor()
            backButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            backButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
            submitButton.backgroundColor = UIColor.blackColor()
            submitButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            submitButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        }
    }
    
    func imageAnimation(selectedImage: UIImageView) {
        selectedImage.alpha = 0
        var shake: CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        var from_point:CGPoint = CGPointMake(selectedImage.center.x - 5, selectedImage.center.y)
        var from_value:NSValue = NSValue(CGPoint: from_point)
        
        var to_point:CGPoint = CGPointMake(selectedImage.center.x + 5, selectedImage.center.y)
        var to_value:NSValue = NSValue(CGPoint: to_point)
        
        shake.fromValue = from_value
        shake.toValue = to_value
        
        UIView.animateWithDuration(2.5, delay: 1.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 1.0, options: nil, animations: {
            selectedImage.layer.addAnimation(shake, forKey: "position")
            selectedImage.alpha = 1
            
            }, nil)
    }
    
    func isFieldFilled(userInput: String) -> Bool { // Province, PHU, Gender, DOB
        if userInput != "" {
            return true
        }
      return false
    }
    
    func isNameFieldValid(userinput: String) -> Bool { //First, Last, Initial
        if userinput != "" && userinput.rangeOfCharacterFromSet(nonCharacterSet) == nil {
            return true
        }
        return false
    }
    
    func isHCNValid(userHCNInput: String) -> Bool {
        if userHCNInput != "" && userHCNInput.rangeOfCharacterFromSet(hcnNumberSet) != nil {
            return true
        }
        return false
    }
    
    @IBAction func DOBField(sender: UITextField) {
        var datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.maximumDate = NSDate() // User date of birth cannot exceed current date.
        datePickerView.addTarget(self, action: Selector("handleDatePicker:"), forControlEvents: UIControlEvents.ValueChanged) // Use UIDatePicker to input date of birth of user information.
    }
   
    @IBAction func EndDOB(sender: AnyObject) {
        userDOB.resignFirstResponder()
        if userDOB.text != "" {
            println("Date of birth accepted.")
        }}
    
    func handleDatePicker(sender: UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        userDOB.text = dateFormatter.stringFromDate(sender.date)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(userDOB.text, forKey: "doBirth")
        userDefaults.synchronize()
        // This function formats the date into YYYY-MM-DD for proper format to be sent as a request to URL.
    }
    
    @IBAction func InitialValid(sender: AnyObject) {
        if countElements(userInitial.text) > 3 || userInitial.text.rangeOfCharacterFromSet(nonCharacterSet) != nil{
            let alert: UIAlertController = UIAlertController(title: "Error", message: "You inputted an invalid character for this field, Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            userInitial.text = userInitial.text.substringToIndex(advance(userInitial.text.startIndex, countElements(userInitial.text) - 1)) // If invalid character is inputted, the said character is automatically deleted. Initials can't be longer than several characters.
        } else if userInitial.text != "" {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(userInitial.text, forKey: "init")
            userDefaults.synchronize()
        }
    }
    
    @IBAction func FirstNameValid(sender: UITextField) {
        genderPicker.hidden = true // Ensures gender field only appears visible with the gender text field.
        provincePicker.hidden = true
        publicHealthUnitPicker.hidden = true
        if ((userFirstName.text).rangeOfCharacterFromSet(nonCharacterSet) != nil) {
            let alert: UIAlertController = UIAlertController(title: "Error", message: "You inputted an invalid character for this field, Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            userFirstName.text = userFirstName.text.substringToIndex(advance(userFirstName.text.startIndex, countElements(userFirstName.text) - 1)) // Ensures no invalid characters are inputted for the first name. If invalid character is inputted, the said character is automatically deleted.
        } else if userFirstName.text != "" {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(userFirstName.text, forKey: "fName")
            userDefaults.synchronize()
        }
    }
    
    @IBAction func LastNameValid(sender: UITextField) {
        genderPicker.hidden = true // Ensures gender field only appears visible with the gender text field.
        provincePicker.hidden = true
        publicHealthUnitPicker.hidden = true
        if ((userLastName.text).rangeOfCharacterFromSet(nonCharacterSet) != nil) {
            let alert: UIAlertController = UIAlertController(title: "Error", message: "You inputted an invalid character for this field, Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            userLastName.text = userLastName.text.substringToIndex(advance(userLastName.text.startIndex, countElements(userLastName.text) - 1)) // Ensures no invalid characters are inputted for the last name.
        } else if userLastName.text != "" {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(userLastName.text, forKey: "lName")
            userDefaults.synchronize()
        }
    }

    func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView.tag == 0 {
        return genderList[row]
        } else if pickerView.tag == 1 {
            return provinceList[row]
        } else if pickerView.tag == 2 {
            return publicHealthUnitList[row]
        }
        return ""
    }
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            userGender.text = genderList[row]
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(userGender.text, forKey: "gender")
            userDefaults.synchronize()
            genderPicker.hidden = true
        } else if pickerView.tag == 1 {
            userProvince.text = provinceList[row]
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(userProvince.text, forKey: "province")
            userDefaults.synchronize()
            provincePicker.hidden = true
        } else if pickerView.tag == 2 {
            userPublicHealthUnit.text = publicHealthUnitList[row]
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(userPublicHealthUnit.text, forKey: "publicHealthUnit")
            userDefaults.synchronize()
            publicHealthUnitPicker.hidden = true
        }
    }
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.view.endEditing(true) // Hides standard keyboard
        userDOB.resignFirstResponder() // Ensures date keyboard disappears when gender field is selected.
        if textField == userGender {
            genderPicker.hidden = false
        } else if textField == userProvince {
            provincePicker.hidden = false
            genderPicker.hidden = true
            publicHealthUnitPicker.hidden = true
        } else if textField == userPublicHealthUnit {
            publicHealthUnitPicker.hidden = false
            genderPicker.hidden = true
            provincePicker.hidden = true
        }
        return false
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return genderList.count
        } else if pickerView.tag == 1 {
            return provinceList.count
        } else if pickerView.tag == 2 {
            return publicHealthUnitList.count
        }
        return 1
    }
    @IBAction func genderFinish(sender: AnyObject) {
        genderPicker.hidden = true
    }

    @IBAction func validHealthCardNumber(sender: AnyObject) {
        if userHCN.text.rangeOfCharacterFromSet(hcnNumberSet) == nil || countElements(userHCN.text) > 10 {
            let alert: UIAlertController = UIAlertController(title: "Error", message: "The Health Card Number field accepts ten numeric characters only.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            userHCN.text = userHCN.text.substringToIndex(advance(userHCN.text.startIndex, countElements(userHCN.text) - 1)) // Ensures only numbers are added to Health Card Number field, 10 digits maximum.
        }}
    
    @IBAction func hcnEditDone(sender: AnyObject) {
        if userHCN.text.rangeOfCharacterFromSet(hcnNumberSet) != nil && userHCN.text != "" && countElements(userHCN.text) == 10 {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(userHCN.text, forKey: "hcn")
            println("Health Card Number accepted.")
            userDefaults.synchronize()
        }
    }

    func isValidEmail(emailStr: String) -> Bool { // function to verify user's email address
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" // Valid Regex solution for email
        let range = emailStr.rangeOfString(emailRegEx, options: .RegularExpressionSearch)
        let result = range != nil ? true: false // Checks whether email address is valid.
        return result
    }

    @IBAction func checkUserEmail(sender: AnyObject) {
        if isValidEmail(userEmail.text) {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(userEmail.text, forKey: "email")
            userDefaults.synchronize()
            println("Email address is valid.")
        } else {
            let alert: UIAlertController = UIAlertController(title: "Email Error", message: "The email address you have entered is not valid. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            // Alert message is email address is invalid.
        }}

    @IBAction func backToQRScreen(sender: UIButton) {
        let screenAlert: UIAlertController = UIAlertController(title: "Confirm Selection", message: "Once you go back to the QR Code Screen, all personal information fields will be cleared. Continue?", preferredStyle: UIAlertControllerStyle.Alert)
        screenAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
            self.performSegueWithIdentifier("backToQRScreen", sender: self)
        }))
        screenAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(screenAlert, animated: true, completion: nil)

    }
    
    @IBAction func transferInfo(sender: UIButton) {
        if isValidEmail(userEmail.text) && isFieldFilled(userDOB.text) && isFieldFilled(userProvince.text) && isFieldFilled(userPublicHealthUnit.text) && isHCNValid(userHCN.text) && isNameFieldValid(userFirstName.text) && isNameFieldValid(userLastName.text) && isNameFieldValid(userInitial.text) { // Checks if all fields are filled with valid input
            let screenAlert: UIAlertController = UIAlertController(title: "Confirm Data", message: "Once you go to the Submit Screen, user information cannot be changed. Continue?", preferredStyle: UIAlertControllerStyle.Alert)
            screenAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                let userDefaults = NSUserDefaults.standardUserDefaults()
                self.userFirstName.text = userDefaults.stringForKey("patientFName")
                self.userLastName.text = userDefaults.stringForKey("patientLName")
                self.userInitial.text = userDefaults.stringForKey("patientInit")
                self.userGender.text = userDefaults.stringForKey("patientGend")
                self.userHCN.text = userDefaults.stringForKey("patientHCN")
                self.userDOB.text = userDefaults.stringForKey("patientDOB")
                self.userEmail.text = userDefaults.stringForKey("patientMail")
                self.userProvince.text = userDefaults.stringForKey("patientPro")
                self.userPublicHealthUnit.text = userDefaults.stringForKey("patientPHU")
                userDefaults.synchronize()
                self.performSegueWithIdentifier("submitInfo", sender: self)
            }))
            screenAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(screenAlert, animated: true, completion: nil)
        }
        else {
            let alert: UIAlertController = UIAlertController(title: "Submission Denied", message: "All fields must be filled with valid information.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
}
