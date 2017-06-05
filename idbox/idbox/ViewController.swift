//
//  ViewController.swift
//  idbox
//
//  Created by Miro Markarian on 6/5/17.
//  Copyright © 2017 zer0xfourd. All rights reserved.
//

import UIKit
import LocalAuthentication
import AFNetworking

class ViewController: UIViewController {
    
    @IBOutlet weak var message: UILabel!
    var context = LAContext()
    
    let kMsgShowReason = "Touch to unlock the box"
    let kMsgLockSuccessful = "Locking successful! ✅"
    let kMsgUnlockSuccessful = "Unlocking successful! ✅"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func lockBox(_ sender: Any) {
        let manager = AFHTTPSessionManager()
        manager.get(
            "http://192.168.1.1/LOCK",
            parameters: nil,
            success:
            {(operation, responseObject) in
                
        },
            failure:
            {(operation, error) in
                print("Error: " + error.localizedDescription)

        })
        
        self.message.text = self.kMsgLockSuccessful
    }
    
    @IBAction func unlockBox(_ sender: Any) {
        var policy: LAPolicy?
        // Depending the iOS version we'll need to choose the policy we are able to use
        if #available(iOS 9.0, *) {
            // iOS 9+ users with Biometric and Passcode verification
            policy = .deviceOwnerAuthentication
        } else {
            // iOS 8+ users with Biometric and Custom (Fallback button) verification
            context.localizedFallbackTitle = "Fuu!"
            policy = .deviceOwnerAuthenticationWithBiometrics
        }
        
        var err: NSError?
        
        // Check if the user is able to use the policy we've selected previously
        guard context.canEvaluatePolicy(policy!, error: &err) else {
            //image.image = UIImage(named: "TouchID_off")
            // Print the localized message received by the system
            //message.text = err?.localizedDescription
            return
        }

       unlockWithID(policy: policy!)

    }
    
    private func unlockWithID(policy: LAPolicy) {
        // Start evaluation process with a callback that is executed when the user ends the process successfully or not
        context.evaluatePolicy(policy, localizedReason: kMsgShowReason, reply: { (success, error) in
            DispatchQueue.main.async {
                guard success else {
                    guard let error = error else {
                       // self.showUnexpectedErrorMessage()
                        return
                    }
                    switch(error) {
                    case LAError.authenticationFailed:
                        self.message.text = "There was a problem verifying your identity."
                    case LAError.userCancel:
                        self.message.text = "Authentication was canceled by user."
                        // Fallback button was pressed and an extra login step should be implemented for iOS 8 users.
                    // By the other hand, iOS 9+ users will use the pasccode verification implemented by the own system.
                    case LAError.userFallback:
                        self.message.text = "The user tapped the fallback button (Fuu!)"
                    case LAError.systemCancel:
                        self.message.text = "Authentication was canceled by system."
                    case LAError.passcodeNotSet:
                        self.message.text = "Passcode is not set on the device."
                    case LAError.touchIDNotAvailable:
                        self.message.text = "Touch ID is not available on the device."
                    case LAError.touchIDNotEnrolled:
                        self.message.text = "Touch ID has no enrolled fingers."
                    // iOS 9+ functions
                    case LAError.touchIDLockout:
                        self.message.text = "There were too many failed Touch ID attempts and Touch ID is now locked."
                    case LAError.appCancel:
                        self.message.text = "Authentication was canceled by application."
                    case LAError.invalidContext:
                        self.message.text = "LAContext passed to this call has been previously invalidated."
                    // MARK: IMPORTANT: There are more error states, take a look into the LAError struct
                    default:
                        self.message.text = "Touch ID may not be configured"
                        break
                    }
                    return
                }
                
                // Good news! Everything went fine 👏
                let manager = AFHTTPSessionManager()
                manager.get(
                    "http://192.168.1.1/UNLOCK",
                    parameters: nil,
                    success:
                    {(operation, responseObject) in
                        
                },
                    failure:
                    {(operation, error) in
                        print("Error: " + error.localizedDescription)
                        
                })
                self.message.text = self.kMsgUnlockSuccessful
            }
        })
    }

}

