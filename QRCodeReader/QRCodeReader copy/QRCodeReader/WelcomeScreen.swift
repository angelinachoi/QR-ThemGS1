//
//  ViewController.swift
//  test02
//
//  Created by Angelina Choi on 2015-01-30.
//  Copyright (c) 2015 Angelina Choi. All rights reserved.
//

import UIKit
import Foundation

class WelcomeScreen: UIViewController { // Welcoming Screen, with instructions and button to start scanning QR Codes
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var scanButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "vaccine.jpg")!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceFlipped", name: UIDeviceOrientationDidChangeNotification, object: nil) // Calls deviceFlipped function when device is face-down
        customPHUScreen() // Customize colours and logos depending on PHU selected in login screen
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deviceFlipped() {
        switch UIDevice.currentDevice().orientation {
        case .FaceDown:
            self.performSegueWithIdentifier("welcomeToLogin", sender: self)
            println("face down") // When device is face-down, screen transitions back to login screen. (Logs out)
        default:
            println("Device is not face down") // Otherwise nothing has changed.
        }
    }
    
    func customPHUScreen() { // Customize screen colours & logos according to user's PHU from the login screen.
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var selectedPHU = userDefaults.stringForKey("selectedPublicHealthUnit") // Gets the PHU from login screen to customize welcome screen
        scanButton.layer.cornerRadius = 5.0
        scanButton.layer.borderWidth = 2.0
        
        if selectedPHU == "Grey Bruce" {
            logoImage.image = UIImage(named: "Grey Bruce Logo.png")
            scanButton.backgroundColor = UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 48.0/255.0, alpha: 1.0)
            scanButton.layer.borderColor = UIColor(red: 171.0/255.0, green: 118.0/255.5, blue: 12.0/255.0, alpha: 1.0).CGColor
            scanButton.setTitleColor(UIColor(red: 171.0/255.0, green: 118.0/255.5, blue: 12.0/255.0, alpha: 1.0), forState: UIControlState.Normal)
            
        } else if selectedPHU == "Hamilton" {
            logoImage.image = UIImage(named: "Hamilton Logo.png")
            scanButton.backgroundColor = UIColor(red: 0.0/255.0, green: 94.0/255.5, blue: 145.0/255.0, alpha: 1.0)
            scanButton.layer.borderColor = UIColor(red: 254.0/255.0, green: 218.0/255.5, blue: 170.0/255.0, alpha: 1.0).CGColor
            scanButton.setTitleColor(UIColor(red: 254.0/255.0, green: 218.0/255.5, blue: 170.0/255.0, alpha: 1.0), forState: UIControlState.Normal)
        } else if selectedPHU == "Toronto" {
            logoImage.image = UIImage(named: "Toronto Logo.png")
            scanButton.backgroundColor = UIColor.blackColor()
            scanButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            scanButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)

        } else if selectedPHU == "Peel" {
            logoImage.image = UIImage(named: "Peel Logo.png")
            scanButton.backgroundColor = UIColor(red: 104.0/255.0, green: 174.0/255.5, blue: 224.0/255.0, alpha: 1.0)
            scanButton.layer.borderColor = UIColor(red: 51.0/255.0, green: 102.0/255.5, blue: 153.0/255.0, alpha: 1.0).CGColor
            scanButton.setTitleColor(UIColor(red: 51.0/255.0, green: 102.0/255.5, blue: 153.0/255.0, alpha: 1.0), forState: UIControlState.Normal)
            
        } else if selectedPHU == "Niagara" {
            logoImage.image = UIImage(named: "Niagara Logo.png")
            scanButton.backgroundColor = UIColor(red: 141.0/255.0, green: 194.0/255.5, blue: 69.0/255.0, alpha: 1.0)
            scanButton.layer.borderColor = UIColor(red: 0.0/255.0, green: 82.0/255.5, blue: 99.0/255.0, alpha: 1.0).CGColor
            scanButton.setTitleColor(UIColor(red: 0.0/255.0, green: 82.0/255.5, blue: 99.0/255.0, alpha: 1.0), forState: UIControlState.Normal)
            
            //UIColor(red: 141.0/255.0, green: 194.0/255.5, blue: 69.0/255.0, alpha: 1.0) niagara green
            //UIColor(red: 0.0/255.0, green: 82.0/255.5, blue: 99.0/255.0, alpha: 1.0) niagara teal
        }
    }

}
