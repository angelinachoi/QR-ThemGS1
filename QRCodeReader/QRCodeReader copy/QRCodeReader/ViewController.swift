//
//  ViewController.swift
//  QRCodeReader
//
//  Created by Angelina Choi on 2015-01-08.
//  Copyright (c) 2015 Angelina Choi. All rights reserved.
//

import UIKit
import AVFoundation // This allows control of the device's camera.
import MobileCoreServices

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var bbitemStart: UIBarButtonItem!
    @IBOutlet weak var buttonBar: UIToolbar! // Outlets for QR Reader Screen
    
    @IBOutlet weak var tapLabel: UILabel! // Label containing instructions to tap screen to start scanning
    @IBOutlet weak var logoImage: UIImageView!
    
    @IBOutlet weak var initiateButton: UIButton!
    
    @IBAction func initiateQRReader(sender: UIButton) { // Screen Button initiates camera and scan.
        self.startReading()
        initiateButton.hidden = true
        self.bbitemStart.title = "Stop"
        self.lblStatus.text = "Scanning for Code..."
        isReading = true}
    
    @IBAction func stopReading(sender: UIBarButtonItem) { // Stop button at bottom left corner stops camera and scanning.
        self.stopReading()
        self.bbitemStart.title = ""
        initiateButton.hidden = false
        self.lblStatus.text = "Code Reader is not running."
        isReading = false
    }

    let ValidCharacterSet: NSCharacterSet = NSCharacterSet(charactersInString: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890,")
    var isReading = Bool()
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var audioPlayer: AVAudioPlayer?
    var qrCodeFrameView:UIView?
    
    var codeVaccinationTranslate = false
    var codePatientTranslate = false
    var pdfCodeScanned = false
    var codeValid = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "vaccine.jpg")!)
        customizeScreen()
        isReading = false
        var captureSession: AVCaptureSession? = nil
        stopReading()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceFlipped", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) { // keep camera rotation consistent with interface orientation
        switch UIDevice.currentDevice().orientation {
            case UIDeviceOrientation.Portrait:
                self.videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
            case UIDeviceOrientation.LandscapeLeft:
                self.videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
            case UIDeviceOrientation.LandscapeRight:
                self.videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
            case UIDeviceOrientation.PortraitUpsideDown:
                self.videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
            default:
                () // Do nothing
            }
    }
    
    func deviceFlipped() {
        switch UIDevice.currentDevice().orientation {
        case .FaceDown:
            self.performSegueWithIdentifier("toLoginScreen", sender: self)
            println("face down")
        default:
            println("Device is not face down")
        }
    } // Logs out when device is put face down.
    
    func customizeScreen() { // Logo on screen depends on PHU selected in the login screen
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var selectedPHU = userDefaults.stringForKey("selectedPublicHealthUnit")

        if selectedPHU == "Grey Bruce" { // Logo image is selected upon PHU selected
            logoImage.image = UIImage(named: "Grey Bruce Logo.png")
        } else if selectedPHU == "Hamilton" {
            logoImage.image = UIImage(named: "Hamilton Logo.png")
        } else if selectedPHU == "Toronto" {
            logoImage.image = UIImage(named: "Toronto Logo.png")
        } else if selectedPHU == "Niagara" {
            logoImage.image = UIImage(named: "Niagara Logo.png")
        }
    }
    
    func qrCodePatientInfo(qrString: String) { // Function to extract patient demographics from QR Code
        if qrString.rangeOfString("application") != nil {
            codeValid = false
            qrCodeFrameView?.layer.borderColor = UIColor.redColor().CGColor
            lblStatus.text = "Invalid QR Code detected" // QR Application Code is for QR-ME only. It is invalid for QR-Them.
        }
        else if qrString.rangeOfString("lastName") != nil && qrString.rangeOfString("firstName") != nil { // QR Code is patient demographics
            qrCodeFrameView?.layer.borderColor = UIColor.blueColor().CGColor // QR Patient Demographics are identified by a blue border
            let qrStrCutFirst = (qrString.substringFromIndex(advance(qrString.startIndex,10)))
            let qrStrTrimEnd = qrStrCutFirst.substringToIndex(qrStrCutFirst.endIndex.predecessor())
            codePatientTranslate = true // Patient Code has translated
            pdfCodeScanned = false // Patient information in QR Code overrides the information in the possibly scanned in PDF
            lblStatus.text = "Patient QR Code detected"
            let qrviewController = UIAlertController(title: "Full Patient Info", message: qrString, preferredStyle: UIAlertControllerStyle.Alert)
            qrviewController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(qrviewController, animated: true, completion: nil)
            // Message box displays information encoded within the QR Code
            
            let patientJSON = (qrString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
            let patientDict: NSDictionary = retrieveJsonFromData(patientJSON!) // Use JSON to parse patient code
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(patientDict["firstName"] as! String!, forKey: "patientFName")
            userDefaults.setObject(patientDict["lastName"] as! String!, forKey: "patientLName")
            userDefaults.setObject(patientDict["middleName"] as! String!, forKey: "patientMName")
            userDefaults.setObject(patientDict["initials"] as! String!, forKey: "patientInit")
            userDefaults.setObject(patientDict["gender"] as! String!, forKey: "patientGender")
            userDefaults.setObject(patientDict["hcn"] as! String!, forKey: "patientHCN")
            userDefaults.setObject(patientDict["dob"] as! String!, forKey: "patientDOB")
            userDefaults.setObject(patientDict["email"] as! String!, forKey: "patientMail")
            userDefaults.setObject(patientDict["phu"] as! String!, forKey: "patientPHU")
            userDefaults.synchronize()
            // Gets key-pair values of patient demographics and sets them as String objects to carry to other screens
            
        } else if qrString.rangeOfString("agent") != nil && qrString.rangeOfString("lotNumber") != nil { // QR Code is Vaccination information
            qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor // Vaccine Demographics are identified by a green border
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(qrString, forKey: "vaccineInfo")
            userDefaults.setObject("QR", forKey: "vaccineInfoType") // Determines type of info Vaccine info is
            userDefaults.synchronize()
            codeVaccinationTranslate = true // Patient demographics is not Vaccination information.
            lblStatus.text = "Vaccine QR Code detected"
            let qrviewController = UIAlertController(title: "Full Vaccine Info", message: qrString, preferredStyle: UIAlertControllerStyle.Alert)
            qrviewController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(qrviewController, animated: true, completion: nil)
            
        } else { // QR Code scanned is not legitimate information relevant to this app.
            codeValid = false
            qrCodeFrameView?.layer.borderColor = UIColor.redColor().CGColor
            lblStatus.text = "Invalid QR Code detected"
        }
    }
    
    func pdfCodeInfo(pdfString: String) { // Function when a PDF417 Code is scanned
        pdfCodeScanned = true
        codePatientTranslate = false // Overrides QR Code patient information
        let alert: UIAlertController = UIAlertController(title: "PDF417 Code", message: pdfString, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        // PDF 417 Information is displayed in a message box.
        let trimString = pdfString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if pdfString.rangeOfString("ON HC") != nil { // Identified PDF 417 code is Health Card Code
            lblStatus.text = "PDF417 Code detected: Health Card"
            let licenseIndex: String.Index = advance(pdfString.startIndex, 20)
            var cutString = pdfString.substringFromIndex(licenseIndex) // Cut first part of string (has a lot of useless characters in it)
            let numberIndex: String.Index = advance(cutString.startIndex, 10)
            var numberString = cutString.substringToIndex(numberIndex) // Segment of PDF string that has the HCN number
            let userDefaults = NSUserDefaults.standardUserDefaults()
            println(">>>\(numberString)<<<")
            userDefaults.setObject(numberString, forKey: "patientHCN") // Number string is labelled as patientHCN variable
            
            let nameIndex: String.Index = advance(cutString.startIndex, 10)
            var nameString = cutString.substringFromIndex(nameIndex) // Cut string to isolate the names in health card
            let nameArray = nameString.componentsSeparatedByString(" ") // separate each name by space character and turn them into an array
            
            var firstName: String = nameArray[0] // First element of namr array is always the first name
            userDefaults.setObject(firstName, forKey: "patientFName")
            
            let initialIndex: String.Index = advance(numberString.startIndex, 1)
            var firstInitial = userDefaults.stringForKey("patientFName")?.substringToIndex(initialIndex) // Get the first character of the first name to make the patient's initials.
            
            if nameArray.count == 3 { // If three names are in the array that means there is a middle name.
                var middleName: String? = nameArray[1] // Second element of array is the middle name.
                userDefaults.setObject(middleName, forKey: "patientMName")
                
                var lastName: String? = nameArray[2] // Third element of array is the last name.
                userDefaults.setObject(lastName, forKey: "patientLName")
                
                var middleInitial = userDefaults.stringForKey("patientMName")?.substringToIndex(initialIndex)
                var lastInitial = userDefaults.stringForKey("patientLName")?.substringToIndex(initialIndex)
                let pInitials = firstInitial! + middleInitial! + lastInitial! // Get the first characters of the middle and last names to create the full initials
                userDefaults.setObject(pInitials, forKey: "patientInit")
                
            } else { // Patient has no middle name
                var lastName: String? = nameArray[1] // Second name in array is the last name
                userDefaults.setObject(lastName, forKey: "patientLName")
                userDefaults.setObject("", forKey: "patientMName")
                var lastInitial = userDefaults.stringForKey("patientLName")?.substringToIndex(initialIndex)
                let pInitials = firstInitial! + lastInitial! // Initials are formed
                userDefaults.setObject(pInitials, forKey: "patientInit")
            }
            userDefaults.setObject("", forKey: "patientMail")
            userDefaults.setObject("", forKey: "patientGender")
            userDefaults.setObject("", forKey: "patientDOB")
            userDefaults.setObject("Ontario", forKey: "patientPro")
            userDefaults.setObject("", forKey: "patientPHU") // These informations cannot be extracted from the Health Card (likely the issue of encrypted codes and security problems)
            userDefaults.synchronize()
            
        } else if pdfString.rangeOfString("ANSI") != nil && pdfString.rangeOfString("DCS") != nil { // Identified PDF 417 code is Driver's License Code
            lblStatus.text = "PDF417 Code detected: Driver's License"
            let stringArray = trimString.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
            var sublist = stringArray[6...17] // Trim string information in Driver's License (as most of the string is nonsensical garbage)
            
            for elem in sublist { // Each element in the Driver's License String is put in an array
                var elem = elem.stringByTrimmingCharactersInSet(ValidCharacterSet.invertedSet)
                println(parseDriverLicenseInfo(elem)) // Each element is analyzed through the parseDriverLicense function.
            }
        }
    }
    
    func parseDriverLicenseInfo(infoString: String) -> String? { // Function to parse each element in the Driver's License
        let licenseIndex: String.Index = advance(infoString.startIndex, 3)
        let licenseString = infoString.substringToIndex(licenseIndex)
        var cutString = infoString.substringFromIndex(licenseIndex)
        var patientInitials: String
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject("", forKey: "patientMail")
        
        if licenseString == "DCS" { // Code for Last Name on License
            cutString = cutString.substringToIndex(advance(cutString.startIndex, count(cutString) - 1))
            userDefaults.setObject(cutString, forKey: "patientLName")
            return (">>\(cutString)<<")
        } else if licenseString == "DCT" { // Code for First and Middle Names on License
            if cutString.rangeOfString(",") != nil {
            let nameArray = cutString.componentsSeparatedByString(",")
            var firstName: String = nameArray[0] // First element of array: First Name
            var middleName: String? = nameArray[1] // Second element of array: Middle Name
            userDefaults.setObject(firstName, forKey: "patientFName")
            userDefaults.setObject(middleName, forKey: "patientMName")
            return (">>\(firstName)<<>>\(middleName)<<")
            } else {
                userDefaults.setObject(cutString, forKey: "patientFName")
                userDefaults.setObject("", forKey: "patientMName")
            }
        } else if licenseString == "DBB" { // Code for Date of Birth of Patient
            // Have to separate the strings by character for year, month, and day
            let yearIndex: String.Index = advance(infoString.startIndex, 4)
            let yearString = cutString.substringToIndex(yearIndex) // Year String
            
            let startMonthIndex: String.Index = advance(infoString.startIndex, 7)
            let endMonthIndex: String.Index = advance(infoString.startIndex, 9)
            let monthRange = startMonthIndex..<endMonthIndex
            let monthDigits = infoString[monthRange] // Month String
            
            let dayIndex: String.Index = advance(infoString.startIndex, 9)
            let endDayIndex: String.Index = advance(infoString.startIndex, 11)
            let dayRange = dayIndex..<endDayIndex
            let dayDigits = infoString[dayRange] // Day String
            
            let birthDate = yearString + "/" + monthDigits + "/" + dayDigits
            userDefaults.setObject(birthDate, forKey: "patientDOB")
            
        } else if licenseString == "DBC" { // Code for Gender
            if cutString == "1" {
                userDefaults.setObject("Male", forKey: "patientGender")
            } else {
                userDefaults.setObject("Female", forKey: "patientGender")
            }
        } else if licenseString == "DAI" { // Code for City (Can be PHU in this case)
            userDefaults.setObject(cutString, forKey: "patientPHU")
        } else if licenseString == "DBJ" { // Code for Province
            if cutString == "ON" {
                userDefaults.setObject("Ontario", forKey: "patientPro")
            } else {
                userDefaults.setObject("", forKey: "patientPro")
            }
            
        } else if licenseString == "DAQ" { // Code for License Number (Can be HCN in this case)
            userDefaults.setObject(cutString, forKey: "patientHCN")
        }
        
        let initialIndex: String.Index = advance(infoString.startIndex, 1)
        var firstInitial = userDefaults.stringForKey("patientFName")?.substringToIndex(initialIndex)

        var lastInitial = userDefaults.stringForKey("patientLName")?.substringToIndex(initialIndex)
        let pInitials = firstInitial! + lastInitial!
        userDefaults.setObject(pInitials, forKey: "patientInit") // Create initials by getting first character of each name
        
        userDefaults.synchronize()
        return "" // returns string with front three identification characters chopped off
    }
    
    func datamatrixVaccine(scannedMatrix: String) {
        // Hardcoded vaccines in Swiftdfdf
        qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
        println(scannedMatrix)
        var vaccineList: Array = [["gtin":"00697177004094","Lot Number":"C4380AA","Expiry Date":"2013-06-30",
            "Manufacture":"Sanofi Pasteur Limited",
            "Brand":"VAXIGRIP",
            "Route":"IH",
            "Agent":"Inf",
            "Dose Size":"0.5 ml",
            "Antigen":"Influenza (Inf)",
            "Disease":"Influenza",
            "Vaccine Description":"Inactivated Influenza Vaccine Trivalent Types A and B (Split Virion)"]]
        
        vaccineList.append(["gtin":"0069717700471117","Lot Number":"C3919AA","Expiry Date":"2013-11-00","Manufacture":"Sanofi Pasteur Limited","Brand":"Adacel","Route":"IH","Agent":"Tdap","Dose Size":"0.5 ml","Antigen":"Tetanus (T), Diphtheria (d), Pertussis (p)","Disease":"Tetanus, Diphtheria, Pertussis","Vaccine Description":"Tetanus Toxoid, Reduced Diphtheria. Toxoid and Acellular Pertussis Vaccine Adsorbed."])
        vaccineList.append(["gtin":"00697177004711","Lot Number":"C4248AA","Expiry Date":"2014-12-31","Manufacture": "Sanofi Pasteur Limited","Brand":"Adacel","Route":"IH","Agent":"Tdap","Dose Size":"0.5 ml","Antigen":"Tetanus (T), Diphtheria (d), Pertussis (p)","Disease":"Tetanus, Diphtheria, Pertussis","Vaccine Description":"Tetanus Toxoid, Reduced Diphtheria. Toxoid and Acellular Pertussis Vaccine Adsorbed."])
        vaccineList.append(["gtin":"00697177004933","Lot Number":"U4608AE","Expiry Date":"2014-12-17","Manufacture": "Sanofi Pasteur Limited","Brand":"Menactra","Route":"IH","Agent":"MEN-ACYW135","Dose Size":"0.5 ml","Antigen":"Meningococcal (Groups A, C, Y and W-135)","Disease":"Menigococcal, Diphtheria","Vaccine Description":"Meningococcal, Polysaccharide Diphtheria Toxoid Conjugate Vaccine."])
        vaccineList.append(["gtin":"00697177004674","Lot Number":"C4599AA","Expiry Date":"2016-08-17","Manufacture": "Sanofi Pasteur Limited","Brand":"Pediacel","Route":"IM","Agent":"Tdap-IPV","Dose Size":"0.5 ml","Antigen":"Tetanus (T), Diphtheria (d), Pertussis (p), Poliomyelitis (IPV)","Disease":"Tetanus, Diphtheria, Pertussis, Polio","Vaccine Description":"Tetanus Toxoid, Diphtheria. Toxoid and Acellular Pertussis Vaccine Adsorbed Combined with Inactivated Poliomyelitis Vaccine and Haemophilius b Conjugate Vaccine."])
        vaccineList.append(["gtin":"00697177004971","Lot Number":"C4636AA","Expiry Date":"2016-12-31","Manufacture": "Sanofi Pasteur Limited","Brand":"Tubersol","Route":"ID","Agent":"TB","Dose Size":"0.1 ml","Antigen":"Tuberculin (TB)","Disease":"Tuberculosis","Vaccine Description":"Tuberculin Purified Protein Derivative (Mantoux)"])
        
        vaccineList.append(["gtin":"00697177004094","Lot Number":"C4381AA","Expiry Date":"2013-06-30","Manufacture":"Sanofi Pasteur Limited","Brand":"VAXIGRIP","Route":"IH","Agent":"Inf","Dose Size":"0.5 ml","Antigen":"Influenza (Inf)","Disease":"Influenza","Vaccine Description":"Inactivated Influenza Vaccine Trivalent Types A and B (Split Virion)"])
        vaccineList.append(["gtin":"00697177004094","Lot Number":"C4386AA","Expiry Date":"2013-06-30","Manufacture":"Sanofi Pasteur Limited","Brand":"VAXIGRIP","Route":"IH","Agent":"Inf","Dose Size":"0.5 ml","Antigen":"Influenza (Inf)","Disease":"Influenza","Vaccine Description":"Inactivated Influenza Vaccine Trivalent Types A and B (Split Virion)"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"917759","Expiry Date":"2013-07-31","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"]) 
        vaccineList.append(["gtin":"066063971008","Lot Number":"918170","Expiry Date":"2013-07-31","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"918566","Expiry Date":"2013-09-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"919555","Expiry Date":"2015-02-28","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"919567","Expiry Date":"2015-02-28","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"920384","Expiry Date":"2015-07-31","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"920477","Expiry Date":"2015-08-31","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"922538","Expiry Date":"2016-04-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"922677","Expiry Date":"2016-05-31","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"G16722","Expiry Date":"2016-02-28","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"G32462","Expiry Date":"2016-02-28","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"G36462","Expiry Date":"2016-02-28","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"G72982","Expiry Date":"2015-11-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"H68695","Expiry Date":"2016-06-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"H91651","Expiry Date":"2016-02-28","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"J02468","Expiry Date":"2016-06-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"066063971008","Lot Number":"J49840","Expiry Date":"2016-07-31","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"697177004506","Lot Number":"J8343-2","Expiry Date":"2013-05-31","Manufacture":"Sanofi Pasteur Limited","Brand":"Intanza","Route":"ID","Agent":"Inf","Dose Size":"0.1 ml","Antigen":"Influenza (Inf)","Disease":"Influenza","Vaccine Description":"Influenza Vaccine (Split Virion, Inactivated)"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"F65384","Expiry Date":"2014-04-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"F98478","Expiry Date":"2014-06-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"G17982","Expiry Date":"2015-01-31","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"G63331","Expiry Date":"2015-02-28","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"G71150","Expiry Date":"2015-03-31","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"G83850","Expiry Date":"2015-04-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"G86850","Expiry Date":"2015-04-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"H05004","Expiry Date":"2015-06-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"H09238","Expiry Date":"2015-06-30","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"H22406","Expiry Date":"2016-02-29","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"H22520","Expiry Date":"2016-01-29","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        vaccineList.append(["gtin":"621027522520","Lot Number":"H45629","Expiry Date":"2015-07-31","Manufacture":"Pfizer Canada Inc.","Brand":"PREVNAR 13","Route":"IA","Agent":"Pneu-C-13","Dose Size":"0.5 ml","Antigen":"Pneumonia (Pneu 13)","Disease":"Pneumonia","Vaccine Description":"Pneumococcal 13-valent Conjugate Vaccine (Diphtheria CRM197 Protein)"])
        
        // 01006971770047111713110010C3919AA
        var gtinDetected: Bool = false
        var lotNumDetected: Bool = false
        var expDateDetected: Bool = false
        
        // First, let's identify the gtin of the GS1
        for eachProduct in vaccineList {
            let productGtin = eachProduct["gtin"] as String!
            let gtinCount = count(productGtin) + 2
            let scannedgtin = scannedMatrix.substringWithRange(Range<String.Index>(start: advance(scannedMatrix.startIndex, 2), end: advance(scannedMatrix.startIndex, gtinCount)))
            println("\(productGtin) and \(scannedgtin)") // Loop through each vaccine in the list to match gtin!
            let productLotNumber = eachProduct["Lot Number"] as String!
            let lotNumberCount = count(productLotNumber)
            let scannedLotNumber = scannedMatrix.substringWithRange(Range<String.Index>(start: advance(scannedMatrix.endIndex, -(lotNumberCount)), end: scannedMatrix.endIndex))
            
            let productExpiryDate = eachProduct["Expiry Date"] as String!
            let formattedExpDate = processProductExpiryDate(productExpiryDate)
            
            if scannedgtin == productGtin && scannedLotNumber == productLotNumber { // If the gtin and lot number of the scanned product matches a record in the list, then the expiry date is finaly compared.
                gtinDetected = true
                lotNumDetected = true // These variables are set as true
                
                let dateandlot = scannedMatrix.substringWithRange(Range<String.Index>(start: advance(scannedMatrix.endIndex, -(8 + lotNumberCount)), end: scannedMatrix.endIndex)) // First subtract the gtin and lot number from the matrix to isolate the expiry date.
                
                let scannedDate = dateandlot.substringWithRange(Range<String.Index>(start: dateandlot.startIndex, end: advance(dateandlot.startIndex, 6)))
                var yearAndMonth = dateandlot.substringWithRange(Range<String.Index>(start: dateandlot.startIndex, end: advance(dateandlot.startIndex, 4))) // Of the epiry date, the first four of six digits indicate the year and moth by two digits, respectively.
                let alternateDate = yearAndMonth + "00" // Some expiry dates on the vaccines only have the month and year, therefore not having a specific day. To accomodate that, the alternate version of an expiry date can be month, year, and 00 as day.
                println(alternateDate)
                
                if scannedDate == formattedExpDate || scannedDate == alternateDate { // The scanned matric and vaccine record is a perfect match if the scanned date matches the year, month, and day (if no day is specified on the vaccine)
                    expDateDetected = true
                    codeVaccinationTranslate = true
                    
                    let manufacture = eachProduct["Manufacture"] as String!
                    let brand = eachProduct["Brand"] as String!
                    let route = eachProduct["Route"] as String!
                    let agent = eachProduct["Agent"] as String!
                    let doseSize = eachProduct["Dose Size"] as String!
                    let antigen = eachProduct["Antigen"] as String!
                    let disease = eachProduct["Disease"] as String!
                    let vaccineDescription = eachProduct["Vaccine Description"] as String!
                    
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    userDefaults.setObject(productGtin, forKey: "productGtin")
                    userDefaults.setObject(productLotNumber, forKey: "productLotNumber")
                    userDefaults.setObject(productExpiryDate, forKey: "productExpiryDate")
                    
                    userDefaults.setObject(manufacture, forKey: "manufacture")
                    userDefaults.setObject(brand, forKey: "brand")
                    userDefaults.setObject(route, forKey: "route")
                    userDefaults.setObject(agent, forKey: "agent")
                    userDefaults.setObject(doseSize, forKey: "doseSize")
                    
                    userDefaults.setObject(antigen, forKey: "antigen")
                    userDefaults.setObject(disease, forKey: "disease")
                    userDefaults.setObject(vaccineDescription, forKey: "vaccineDescription")
                    
                    userDefaults.setObject("dataMatrix", forKey: "vaccineInfoType") // Determines type of info Vaccine info is
                    userDefaults.synchronize()
                    qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
                    
                    lblStatus.text = "Datamatrix Code Detected: Vaccine Information"
                    let alert: UIAlertController = UIAlertController(title: "Vaccine Code", message: "Gtin Code: \(productGtin)\nProduct Lot Number: \(productLotNumber)\nExpiry Date: \(productExpiryDate)\nManufacture: \(manufacture)\nBrand: \(brand)\nRoute: \(route)\nAgent: \(agent)\nDose Size: \(doseSize)\nAntigen: \(antigen)\nDisease: \(disease)\nVaccine Description: \(vaccineDescription)\nDosage Form: SUSP\nTemperature Control Change: TCREF", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
            }
        }
        
        if expDateDetected == false || lotNumDetected == false || gtinDetected == false {
            codeVaccinationTranslate = false
            lblStatus.text = "Datamatrix Code Detected: Invalid Code"
            let errorAlert: UIAlertController = UIAlertController(title: "Error", message: "The information encoded in the scanned datamatrix do not fit any of the products stored in the database.", preferredStyle: UIAlertControllerStyle.Alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(errorAlert, animated: true, completion: nil)

        }
    }
    
    func processProductExpiryDate (productDate: String) -> String {
        let yearStr = productDate.substringWithRange(Range<String.Index>(start: advance(productDate.startIndex, 2), end: advance(productDate.startIndex, 4)))
        let monthStr = productDate.substringWithRange(Range<String.Index>(start: advance(productDate.startIndex, 5), end: advance(productDate.startIndex, 7)))
        let dayStr = productDate.substringWithRange(Range<String.Index>(start: advance(productDate.startIndex, 8), end: productDate.endIndex))
        var formattedDate = yearStr + monthStr + dayStr
        return formattedDate
    }
    
    func startReading () -> Bool {
        var error: NSError?
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        let input: AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error)
        if (error != nil) {
            // If any error occurs, log the description of it and discontinue the program.
            println("\(error?.localizedDescription)")
            return false
        }
        captureSession = AVCaptureSession() // Initialize the captureSessionObject
        captureSession?.addInput(input as! AVCaptureInput) // Set the input device on the capture session.
        
        // Initialize a AVCaptureMetadaOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeDataMatrixCode]
        
        //logoImage: UIImageView!
        self.view.backgroundColor = UIColor.blackColor()
        logoImage.image = nil
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.bounds = self.view.bounds
        videoPreviewLayer?.frame = view.layer.bounds
        videoPreviewLayer?.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))
        
        view.layer.addSublayer(videoPreviewLayer)
        captureSession?.startRunning() // Start video capture.
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
        view.bringSubviewToFront(lblStatus) // Move the message label to the top view
        view.bringSubviewToFront(buttonBar) // And the toolbar as well
        
        return true
    }
    
    func captureOutput (captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            lblStatus.text = "No code detected"
            return
        }
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label
            let qrCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = qrCodeObject.bounds;
        
            if metadataObj.stringValue != nil {
                var qrCode = metadataObj.stringValue
                qrCodePatientInfo(qrCode)
            }
        }
        
        else if metadataObj.type == AVMetadataObjectTypePDF417Code {
            // If the found metadata is equal to the QR code metadata then update the status label
            let pdfCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = pdfCodeObject.bounds;
            //metadataObj.
            if metadataObj.stringValue != nil {
                var pdfCode = metadataObj.stringValue
                pdfCodeInfo(pdfCode)
            }
        }
        
        else if metadataObj.type == AVMetadataObjectTypeDataMatrixCode {
            let dataMatrixCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = dataMatrixCodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                var dataMatrix = metadataObj.stringValue
                datamatrixVaccine(dataMatrix)
            }
        }
    }
    
    func retrieveJsonFromData(data: NSData) -> NSDictionary { // Now deserialize JSON object into dictionary
        var error: NSError?
        let jsonObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
            options: .AllowFragments,
            error: &error)
        if  error == nil {
            println("Successfully deserialized...")
            if jsonObject is NSDictionary{
                let deserializedDictionary = jsonObject as! NSDictionary
                println("Deserialized JSON Dictionary = \(deserializedDictionary)")
                return deserializedDictionary
            } else {
                /* Some other object was returned. We don't know how to
                deal with this situation because the deserializer only
                returns dictionaries or arrays */
            }
        } else if error != nil {
            println("An error happened while deserializing the JSON data.")
        }
        return NSDictionary()
    }
    
    func JSONParseArray(jsonString: String) -> [AnyObject] { // Function to parse Json array
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
            if let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as? [AnyObject] {
                return array
            }
        }
        return [AnyObject]()
    }

    func stopReading () { // Stops the QR Reader camera process
        captureSession?.stopRunning()
        captureSession = nil
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "vaccine.jpg")!)
        customizeScreen()
        videoPreviewLayer?.removeFromSuperlayer() }
 
    @IBAction func personalInfoTransition(sender: UIBarButtonItem) {
        if codeVaccinationTranslate == false { // Vaccination code must be scanned to proceed.
            let alert: UIAlertController = UIAlertController(title: "Error", message: "No Vaccine QR Label has been scanned.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            if pdfCodeScanned == true { // If Patient demographics are derived from PDF417
                let patientConfirmation: UIAlertController = UIAlertController(title: "PDF417 Accepted", message: "Do you want to proceed with the PDF417 information?", preferredStyle: UIAlertControllerStyle.Alert)
                patientConfirmation.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                    self.performSegueWithIdentifier("CodeToInfo", sender: self)
                }))
                patientConfirmation.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(patientConfirmation, animated: true, completion: nil)
                
            } else if codePatientTranslate == true {
                let patientConfirmation: UIAlertController = UIAlertController(title: "Information Accepted", message: "Would you like to edit the patient information?", preferredStyle: UIAlertControllerStyle.Alert)
                patientConfirmation.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                    self.performSegueWithIdentifier("CodeToInfo", sender: self)
                }))
                patientConfirmation.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                    self.performSegueWithIdentifier("viewControllerToSubmitScreen", sender: self)
                }))
                
                self.presentViewController(patientConfirmation, animated: true, completion: nil)
                
            } else if codePatientTranslate == false {
                let patientConfirmation: UIAlertController = UIAlertController(title: "No Patient Demographics Scanned", message: "You have not scanned a patient QR Code. Would you like to input the information manually?", preferredStyle: UIAlertControllerStyle.Alert)
                patientConfirmation.addAction(UIAlertAction(title: "Yes, proceed", style: UIAlertActionStyle.Default, handler: { ( action: UIAlertAction!) in
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    userDefaults.setObject("", forKey: "patientFName")
                    userDefaults.setObject("", forKey: "patientLName")
                    userDefaults.setObject("", forKey: "patientMName")
                    userDefaults.setObject("", forKey: "patientInit")
                    userDefaults.setObject("", forKey: "patientGender")
                    userDefaults.setObject("", forKey: "patientDOB")
                    userDefaults.setObject("", forKey: "patientHCN")
                    userDefaults.setObject("", forKey: "patientMail")
                    userDefaults.setObject("", forKey: "patientPHU")
                    userDefaults.setObject("", forKey: "patientPro")
                    userDefaults.synchronize()
                    self.performSegueWithIdentifier("CodeToInfo", sender: self)
                }))
                patientConfirmation.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(patientConfirmation, animated: true, completion: nil)
                performSegueWithIdentifier("CodeToInfo", sender: self)
            }
        }
    }
}