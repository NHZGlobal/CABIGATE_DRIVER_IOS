//
//  ViewController.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 01/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit
import SwiftValidator
import Alamofire
import SwiftyJSON
import MBProgressHUD
import CoreLocation

class LoginViewController: UIViewController {
    
    @IBOutlet weak var companyErrorLabel: UILabel!
    @IBOutlet weak var companyTF: NKTextField!
    
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var usernameTF: NKTextField!
    
    @IBOutlet weak var passwordTF: NKTextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    @IBOutlet weak var versionNumberLabel: UILabel!
    // variables
    let validator = Validator()
    var hud = MBProgressHUD()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CabLocationManager.shared.locationManager.requestWhenInUseAuthorization()

        
        //First get the nsObject by defining as an optional anyObject
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = nsObject as! String
        
        self.versionNumberLabel.text = version
        

        self.addBackground()
        
        self.validator.registerField(self.companyTF, errorLabel: self.companyErrorLabel, rules: [RequiredRule()])
        self.validator.registerField(self.usernameTF, errorLabel: self.usernameErrorLabel, rules: [RequiredRule()])
        self.validator.registerField(self.passwordTF, errorLabel: self.passwordErrorLabel, rules: [RequiredRule()])
        
        self.validator.styleTransformers(success:{ (validationRule) -> Void in
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
        }, error:{ (validationError) -> Void in
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
        })
        
//        let params = ["companyid":"2100","userid":"1", "token":"XHGYASGHGYUH"]
//        APIServices.logout(params: params) { (error ) in }
        
//        let params = ["companyid":"2100","userid":"1", "token":"XHGYASGHGYUH"]
//        APIServices.FetchVehicleList(params: params) { (error ) in }

//        let params = ["companyid":"2100",
//                      "userid":"1",
//                      "vehicleid":"5",
//                      "lat":"51.215454",
//                      "lng":"-31.215454",
//                      "duration":"60",
//                      "token":"123456"]
//        APIServices.ShiftIn(params: params) { (error ) in }
        
//        let params = ["companyid":"2100","userid":"1", "token":"XHGYASGHGYUH"]
//        APIServices.ShiftOut(params: params) { (error ) in }
    }
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarView?.backgroundColor = .white
        
        if let companyId = UserDefaults.standard.value(forKey: "companyId") as? String {
            self.companyTF.text = companyId
        }
        
        if let userId = UserDefaults.standard.value(forKey: "userId") as? String {
            self.usernameTF.text = userId
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @IBAction func didTapSignIn(_ sender: UIButton) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            self.validator.validate(self)
        default:
            print("denied")
            
            let alertController = UIAlertController (title: "Need Location Access", message: "In Settings, You must allow access to your location for the cabigate driver app to work. We will only track your location when you are using the cabigate drivers app.", preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            alertController.addAction(settingsAction)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }    
    
}

extension LoginViewController: ValidationDelegate {
    
    func validationSuccessful() {
        let paramsData = ["company":self.companyTF.text!,"username":self.usernameTF.text!, "password":self.passwordTF.text!, "devicetype" : "IOS"]
        self.showHud()
        APIServices.Login(params: paramsData) { (error ) in
            guard (error == nil) else {
                self.hideHud(title: "Error", desc: error!)
                return
            }
            self.hud.hide(animated: true)
            
            let defaults = UserDefaults.standard
            defaults.set(self.companyTF.text!, forKey: "companyId")
            defaults.set(self.usernameTF.text!, forKey: "userId")
            defaults.synchronize()
            
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.permissionForNotification()
            delegate.updateFCMToken()
            self.performSegue(withIdentifier: "mainVC", sender: nil)
        }
    }
    
    func validationFailed(_ errors:[(Validatable, ValidationError)]) {
    }
}

extension LoginViewController {
    func showHud(){
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
    }
    
    func hideHud(title:String, desc: String){
        DispatchQueue.main.async {
            self.hud.mode = MBProgressHUDMode.text
            self.hud.label.text = title
            self.hud.detailsLabel.text = desc
            self.hud.hide(animated: true, afterDelay: 2.0)
        }
    }
}


