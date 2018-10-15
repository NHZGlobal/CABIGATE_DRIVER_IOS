//
//  MainViewController.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 01/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit
import MBProgressHUD
import SDWebImage
import RealmSwift
import SwiftyJSON
import ObjectMapper
import Presentr
import SocketIO
import RxSwift
import SwiftMoment
import JSQMessagesViewController
import CoreLocation
import UserNotifications

protocol JobDetailVCResponse {
    func accepted()
}

protocol ShiftExpiredVCDelegate {
    func continueShift()
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var lastCarLabel: UILabel!
    @IBOutlet weak var shiftEndLabel: UILabel!
    @IBOutlet weak var shiftButton: UIButton!
    @IBOutlet weak var versionNumberLabel: UILabel!

    var player: AVAudioPlayer?
    var hud = MBProgressHUD()
    var presenter: Presentr!
    var timer: Timer = Timer()
    var locationTimer: Timer = Timer()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lastCarLabel.text = ""
        
        //First get the nsObject by defining as an optional anyObject
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = nsObject as! String
        
        self.versionNumberLabel.text = version
        
        self.profileImage.layer.borderColor = UIColor.gray.cgColor
        self.profileImage.layer.borderWidth = 3
        
        if let realmDriver = DatabaseManager.realm.objects(Driver.self).first {
            if let profileURL = realmDriver.driver_image {
                profileImage.setShowActivityIndicator(true)
                profileImage.setIndicatorStyle(.gray)
                profileImage.sd_setImage(with: URL(string: profileURL))
            }
            self.welcomeLabel.text = "Welcome, \(realmDriver.username!)"
            
            let params = ["companyid":realmDriver.companyId!,"userid":realmDriver.userId!, "token":realmDriver.token!]
            APIServices.LastState(params: params, callback: { (error) in
                
            })
            
            
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
            }
            
            
            CabigateSocket.connect(userid: realmDriver.userId!, username: realmDriver.username!, roomid: realmDriver.companyId!)
            
            CabigateSocket.socket.on("send_my_details"){ data, ack in
                print("send_my_details")
                print(data)
                let driverObj = Driver.shared.value
                var parameters = ["user_id":"\(realmDriver.userId!)","company_id":"\(realmDriver.companyId!)","status": "\(driverObj!.last_status)", "jobid": "", "jobrefrence":"", "lat": "0", "lng": "0", "username":"", "jobstatus": "", "sender":"", "app_version_info": "1.0"]
                
                if let job = driverObj?.jobDetails, let jobid = job.jobid{
                    parameters["jobid"] = jobid
                    parameters["jobrefrence"] = job.refrence!
                    parameters["jobstatus"] = job.status!
                    if let sender = job.sender {
                        parameters["sender"] = sender
                    }
                }
                
                if let location = CabLocationManager.shared.locationManager.location {
                    parameters["lat"] = "\(location.coordinate.latitude)"
                    parameters["lng"] = "\(location.coordinate.longitude)"
                }
                CabigateSocket.socket.emit("send_my_details", parameters)
            }
            
            
            CabigateSocket.socket.on("pushnotification"){ data, ack in
                print("pushnotification")
                
                guard let notifyData = data[0] as? NSDictionary else { return }
                print(notifyData)
                
                print()
                print()
                let notification = UILocalNotification()
                notification.fireDate = Date()
                notification.alertTitle = notifyData["title"] as? String
                notification.alertBody = notifyData["message"] as? String
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.shared.scheduleLocalNotification(notification)
            }
            CabigateSocket.socket.on("showjob"){ data, ack in
                print("show job of socket")
                
                
                let json = JSON(data[0])
                let job = Mapper<ShowJob>().map(JSON: json.dictionaryObject!)
                CabigateSocket.socket.emit("job_recived_on_app", ["user_id":"\(realmDriver.userId!)","company_id":"\(realmDriver.companyId!)","jobid":"\(job!.jobid!)","refrence":"\(job!.refrence!)","sender":"\(job!.sender!)"])
                
                self.presenter = {
                    let width = ModalSize.custom(size: Float(self.view.frame.size.width - 60))
                    let height = ModalSize.custom(size: 450)
                    let center = ModalCenterPosition.customOrigin(origin: CGPoint.init(x: 30, y: self.view.frame.midY - 180))
                    let customType = PresentationType.custom(width: width, height: height, center: center)
                    
                    let customPresenter = Presentr(presentationType: customType)
                    customPresenter.transitionType = TransitionType.crossDissolve
                    customPresenter.dismissTransitionType = TransitionType.crossDissolve
                    customPresenter.backgroundOpacity = 0.3
                    customPresenter.dismissAnimated = true
                    return customPresenter
                }()
                
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "jobdetailvcSID") as! JobDetailViewController
                
                vc.screenType = JobScreenType.joboffer
                vc.joboffer = job
                
                if var topController = UIApplication.shared.keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    
                    
                    let state = UIApplication.shared.applicationState
                    if state == .background {
                    let content = UNMutableNotificationContent()
                    content.title = "New Job"
                    content.body = "You recieved a new job"
             //       if let audioUrl == nil {
             //           content.sound = UNNotificationSound.defaultSound()
             //       } else {
            //            let alertSound = NSURL(fileURLWithPath: self.selectedAudioFilePath)
                        content.sound = UNNotificationSound(named: "tick_muscic.wav")
             //       }
             //       content.userInfo = infoDic as [NSObject : AnyObject]
            //        content.badge = 1
            //        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: true)
                    let identifier = "Reminder-\(Date())"
                    
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
                    let center = UNUserNotificationCenter.current()
                    center.add(request, withCompletionHandler: { (error) in
                        if error != nil {
                            print("local notification created successfully.")
                        }else {
                            print("Notificaiton error \(error)")
                        }
                    })
                    }
                    
                    self.presenter.dismissOnTap = false
                    
                    vc.delgate = topController as? JobDetailVCResponse
                    topController.customPresentViewController(self.presenter, viewController: vc, animated: true, completion: nil)
                }
            }
            
            
            
            CabigateSocket.socket.on("recivemessage"){ data, ack in
                guard let message = data[0] as? NSDictionary else { return }
                
                
                self.playChatSound()
                
                Driver.shared.value!.chatCount += 1
                Driver.messages.value.append(JSQMessage(senderId: message["senderid"] as! String, displayName: message["username"] as! String, text: message["message"] as! String))
                
                let state = UIApplication.shared.applicationState
                if state == .background {
                    let content = UNMutableNotificationContent()
                    content.title = (message["username"] as? String)!
                    content.body =  (message["message"] as? String)!
                    content.sound = UNNotificationSound.default()
                    
                    let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
                    let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
                    
                    let center = UNUserNotificationCenter.current()
                    center.add(request) { (error) in
                        print(error ?? "error")
                    }
                }
            }
            
            // Offers Observers
            CabigateSocket.socket.on("offersnotifier"){ data, ack in
                let json = JSON(data[0])
                
                Driver.shared.value!.offersCount = json["offerscount"].string!
                
                if let driver = DatabaseManager.realm.objects(Driver.self).first {
                    let params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!]
                    APIServices.Offers(params: params) { (error) in }
                }
            }
            
            CabigateSocket.socket.on("sync_dispatch_status"){ data, ack in
                print("sync_dispatch_status")
                let json = JSON(data[0])
                print("=========================\(json)=====================")
                if json["synctype"].string == "job" && json["paxtel"].string != nil{
                    let jobObj = Mapper<ShowJob>().map(JSON: json.dictionaryObject!)
                    let driverObj = Driver.shared.value
                    
                    if let job = driverObj?.jobDetails, let jobid = job.jobid, jobid == jobObj?.jobid, job.status == "wait" {
                        driverObj?.shouldGoToNextIndex = false
                        driverObj!.jobDetails = jobObj
                        Driver.shared.value = driverObj!

                    }else {
                        driverObj?.shouldGoToNextIndex = true
                        driverObj!.jobDetails = jobObj
                        Driver.shared.value = driverObj!

                    }

                    self.playSyncSound()

                }else if json["status"] == "clear" {
                    // complete job than show popup
                    guard let jobDetails = Driver.shared.value?.jobDetails else {
                        // update status to free
                        let params = ["companyid":realmDriver.companyId!,"userid":realmDriver.userId!, "token":realmDriver.token!,"status":"free", "eta":"0"]
                        APIServices.StatusUpdate(params: params, callback: { (error) in
                            let driverObj = Driver.shared.value
                            driverObj?.last_status = "free"
                            
                            Driver.shared.value = driverObj
                        })
                        return
                    }
                    
                    let params = ["companyid":realmDriver.companyId!,"userid":realmDriver.userId!, "token":realmDriver.token!, "jobid":jobDetails.jobid!, "rating":"5", "comment":"",  "fare":jobDetails.fare!, "pay_via":jobDetails.payment_type!]
                    
                    APIServices.DeliverJob(params:  params) { (error, hasJob)  in
                        guard (error == nil) else {
                            print("Deliver Job Error : \(error!)")
                            return
                        }
                        
                        let defaults = UserDefaults.standard
                        defaults.removeObject(forKey:jobDetails.jobid!)
                        defaults.synchronize()
                        
                        if hasJob == false {
                            let driverObj = Driver.shared.value
                            driverObj?.jobDetails = nil
                            Driver.shared.value! = driverObj!
                            
                            // update status to free
                            let params = ["companyid":realmDriver.companyId!,"userid":realmDriver.userId!, "token":realmDriver.token!,"status":"free", "eta":"0"]
                            APIServices.StatusUpdate(params: params, callback: { (error) in
                                let driverObj = Driver.shared.value
                                driverObj?.last_status = "free"
                                
                                Driver.shared.value = driverObj
                            })
                        }
                    }
                }
            }
            
            
            Driver.shared.asObservable().subscribe({ (driver ) in
                guard let driver = driver.element, driver?.jobDetails != nil else { return }
                self.performSegue(withIdentifier: "jobVC", sender: nil)
                
            }).disposed(by: self.disposeBag)
            
        }
        
        self.locationTimer = Timer.every(5.seconds) { (timer: Timer) in
            var TTimer = Timer()
           // print("timer")
            
            if CabigateSocket.isConnected == false {
                if let realmDriver = DatabaseManager.realm.objects(Driver.self).first {
                    if self.locationTimer.isValid {
                        CabigateSocket.connect(userid: realmDriver.userId!, username: realmDriver.username!, roomid: realmDriver.companyId!)
                    }
                }
            }
            
            if let location = CabLocationManager.shared.locationManager.location {
                if let realmDriver = DatabaseManager.realm.objects(Driver.self).first {
                    if location.speed > 0{
                        CabigateSocket.socket.emit("updatelocation", ["lat":"\(location.coordinate.latitude)","lng":"\(location.coordinate.longitude)","speed":"\(location.speed)","username":realmDriver.username!,"user_id":realmDriver.userId!,"company_id":realmDriver.companyId!])
                        TTimer.invalidate()
                    }else {
                        if !TTimer.isValid {
                            TTimer = Timer.after(30.seconds, {
                                
                                if TTimer.isValid {
                                    if let currentLocation = CabLocationManager.shared.locationManager.location {
                                        TTimer.invalidate()
                                        CabigateSocket.socket.emit("updatelocation", ["lat":"\(currentLocation.coordinate.latitude)","lng":"\(currentLocation.coordinate.longitude)","speed":"\(currentLocation.speed)","username":realmDriver.username!,"user_id":realmDriver.userId!,"company_id":realmDriver.companyId!])
                                    }
                                }
                            })
                        }
                        
                    }
                }
            }
        }
        
    }
    func playChatSound() {
        guard let url = Bundle.main.url(forResource: "short_sms_tone", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    func playSyncSound() {
        guard let url = Bundle.main.url(forResource: "short_sms_2", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            if (player != nil)
            {
                player?.stop()
            }
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "LocationUpdate"), object: nil)
    }
    @objc func locationUpdateNotification()  {
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        
         NotificationCenter.default.addObserver(self, selector: #selector(locationUpdateNotification), name: NSNotification.Name(rawValue: "LocationUpdate"), object: nil)
        
        self.addBackground()
        UIApplication.shared.statusBarView?.backgroundColor = .white
        
        self.updateShift()
        
        CabigateSocket.socket.off("forcelogout")
        CabigateSocket.socket.on("forcelogout"){ data, ack in
            print("force logout")
            self.didTapLogout(self)
        }
    }
    
    @IBAction func didTapEndShift(_ sender: UIButton) {
        if self.shiftButton.titleLabel?.text == "END SHIFT" {
            
            do {
                try DatabaseManager.realm.write {
                    if let driver = DatabaseManager.realm.objects(Driver.self).first {
                        self.showHud()
                        let params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!]
                        APIServices.ShiftOut(params: params, callback: { (error) in
                            
                            guard (error == nil) else {
                                self.hideHud(title: "Error", desc: error!)
                                return
                            }
                            self.hud.hide(animated: true)
                            
                            ShiftIn.shared.value = nil
                            self.updateShift()
                            let defaults = UserDefaults.standard
                            defaults.removeObject(forKey: "shiftEndTime")
                            defaults.synchronize()
                            
                        })
                        
                        DatabaseManager.realm.delete(DatabaseManager.realm.objects(ShiftIn.self).first!)
                    }
                }
            }catch let error {
                print(error.localizedDescription)
            }
            
        }else {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                print("authorizedWhenInUse")
                self.performSegue(withIdentifier: "shiftVC", sender: nil)
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
    
    @IBAction func didTapJobView(_ sender: UIButton) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            self.performSegue(withIdentifier: "jobVC", sender: nil)
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
    
    @IBAction func didTapLogout(_ sender: AnyObject) {
        print(#function)
        try! DatabaseManager.realm.write {
            if let driver = DatabaseManager.realm.objects(Driver.self).first {
                let params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!]
                self.showHud()
                APIServices.Logout(params: params) { (error ) in
                    guard (error == nil) else {
                        self.hideHud(title: "Error", desc: error!)
                        return
                    }
                    self.hud.hide(animated: true)
                    
                    // update userdefaults
                    UserDefaults.standard.set(false, forKey: "isfcmTokenSent")
                    UserDefaults.standard.synchronize()
                    
                    guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
                    delegate.window = UIWindow(frame: UIScreen.main.bounds)
                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "loginSID")
                    delegate.window?.rootViewController = vc
                    delegate.window?.makeKeyAndVisible()
                    
                    CabigateSocket.socket.disconnect()
                    self.locationTimer.invalidate()
                    // CabigateSocket.socket.removeAllHandlers()
                }
                DatabaseManager.realm.delete(DatabaseManager.realm.objects(Driver.self))
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "jobVC" {
            let destVC = segue.destination as! UINavigationController
            if let jobMainVC = destVC.childViewControllers.first as? JobMainViewController {
                jobMainVC.mainVC = self
            }
        }
    }
}

extension MainViewController: ShiftExpiredVCDelegate {
    func continueShift() {
        // end shift and than go to shifviewcontroller
        do {
            try DatabaseManager.realm.write {
                if let driver = DatabaseManager.realm.objects(Driver.self).first {
                    self.showHud()
                    let params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!]
                    APIServices.ShiftOut(params: params, callback: { (error) in
                        
                        guard (error == nil) else {
                            self.hideHud(title: "Error", desc: error!)
                            return
                        }
                        self.hud.hide(animated: true)
                        
                        ShiftIn.shared.value = nil
                        self.updateShift()
                        let defaults = UserDefaults.standard
                        defaults.removeObject(forKey: "shiftEndTime")
                        defaults.synchronize()
                        self.performSegue(withIdentifier: "shiftVC", sender: nil)
                    })
                    
                    DatabaseManager.realm.delete(DatabaseManager.realm.objects(ShiftIn.self).first!)
                }
            }
        }catch let error {
            print(error.localizedDescription)
        }
        
    }
}

extension MainViewController{
    func updateShift() {
        
        if let _ = DatabaseManager.realm.objects(ShiftIn.self).first {
            self.shiftButton.setTitle("END SHIFT", for: .normal)
            
            if let value = UserDefaults.standard.value(forKey: "shiftEndTime") as? TimeInterval {
                self.shiftEndLabel.text = "Shiftends : \(moment(value).format("hh:mm:ss a yyyy/MM/dd"))"
                self.timer.invalidate()
                self.timer = Timer.every(1.seconds) { (timer: Timer) in
                    let difference = Duration(value: moment(value).date.timeIntervalSince1970).subtract(Duration(value: Date().timeIntervalSince1970))
                    
                    if Int(difference.seconds) <= 0 {
                        print("shift is expired")
                        self.timer.invalidate()
                        self.presenter = {
                            let width = ModalSize.custom(size: Float(self.view.frame.size.width - 60))
                            let height = ModalSize.custom(size: 170)
                            let center = ModalCenterPosition.customOrigin(origin: CGPoint.init(x: 30, y: self.view.frame.midY - 100))
                            let customType = PresentationType.custom(width: width, height: height, center: center)
                            
                            let customPresenter = Presentr(presentationType: customType)
                            customPresenter.transitionType = TransitionType.crossDissolve
                            customPresenter.dismissTransitionType = TransitionType.crossDissolve
                            customPresenter.backgroundOpacity = 0.3
                            customPresenter.dismissAnimated = true
                            return customPresenter
                        }()
                        
                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "shiftExpiredVC") as! ShiftExpiredVC
                        vc.delegate = self
                        self.customPresentViewController(self.presenter, viewController: vc, animated: true, completion: nil)
                    }
                }
            }
        }else {
            self.shiftEndLabel.text = ""
            self.shiftButton.setTitle("START SHIFT", for: .normal)
        }
    }
}

extension MainViewController {
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

extension MainViewController: JobDetailVCResponse{
    func accepted() {
        print(#function)
        
        self.performSegue(withIdentifier: "jobVC", sender: nil)
    }
}

