//
//  BusyViewController.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 02/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit
import Presentr
import MBProgressHUD
import GooglePlaces
import RxSwift
import SwiftMoment
import JSQMessagesViewController

protocol ReportProblemVCDelegate {
    func confirm()
}

protocol FarePaymentForJobVCDelegate {
    func next()
}

protocol FeedbackVCDelegate {
    func submit(feedback: String)
}

protocol CancelJobVCDelegate {
    func yes(reason: String)
}

protocol UpdateLocationDelegate {
    func update(details: UpdateJobDetails)
    func delete(details: UpdateJobDetails)
}

class BusyViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var callout: UIButton!
    @IBOutlet weak var wait: UIButton!
    @IBOutlet weak var pob: UIButton!
    @IBOutlet weak var deliverd: UIButton!
    
    var startJobTime: Date?
    var endJobTime: Date?
    
    var presenter: Presentr!
    var hud = MBProgressHUD()
    
    let disposeBag = DisposeBag()
    var jobDetails: UpdateJobDetails?
    var isSoundPlay: Bool!
    var player: AVAudioPlayer?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        isSoundPlay = false
        self.view.backgroundColor = .clear
        
        self.startJobTime = Date()
        self.endJobTime = Date()
        
        
        Driver.shared.asObservable().subscribe { (driver) in
            UserDefaults.standard.synchronize()
            guard let driver = Driver.shared.value, let job = driver.jobDetails else { return }
            guard let jobstatus = job.status else {
                self.didTapCallout(self.callout)
                return
            }
            if jobstatus == "callout" {
                UserDefaults.standard.setValue(0, forKey: Driver.shared.value!.jobDetails!.jobid!)
                UserDefaults.standard.synchronize()
                self.didTapCallout(self.callout)
            }
            if jobstatus == "wait" {
                self.didTapWAIT(self.wait)}
            if jobstatus == "pob" { self.didTapPOB(self.pob)}
            self.tableView.reloadData()
            
            if self.isSoundPlay {
//               JSQSystemSoundPlayer.shared().playSound(withFilename: "short_sms_2", fileExtension: "mp3")
            
//                self.playSound()
            }
            
            self.isSoundPlay = true
//
            
            
            }.disposed(by: self.disposeBag)
        
    }
    func playSound() {
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
    @IBAction func didTapCallout(_ sender: UIButton) {
        
        
        func configureUI() {
            self.callout.isEnabled = false
            self.callout.setTitleColor(.cabigateThemeColor, for: .normal)
            self.wait.isEnabled = true
            self.wait.setTitleColor(.white, for: .normal)
            self.pob.isEnabled = false
            self.pob.setTitleColor(.gray, for: .normal)
            self.deliverd.isEnabled = false
            self.deliverd.setTitleColor(.gray, for: .normal)
        }
        
        if Driver.shared.value!.jobDetails!.status == nil || Driver.shared.value!.jobDetails!.status != "callout" {
            if let driver = DatabaseManager.realm.objects(Driver.self).first {
                
                let now = moment(Date())
                let validTime = moment(["year": now.year,
                                        "second": now.second,
                                        "month": now.month,
                                        "minute": now.minute,
                                        "hour": now.hour,
                                        "day": now.day
                    ])!
                
                Driver.shared.value!.startTime = validTime.epoch()
                self.startJobTime = Date()
                

                let params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!,"status":"callout", "jobid":Driver.shared.value!.jobDetails!.jobid!]
                self.showHud()
                APIServices.UpdateJobStatus(params: params, callback: { (error) in
                    guard (error == nil) else {
                        self.hideHud(title: "Error", desc: error!)
                        return
                    }
                    self.hud.hide(animated: true)
                    let driver = Driver.shared.value
                    driver?.jobDetails?.status = "callout"
                    Driver.shared.value = driver
                    configureUI()
                })
            }
        }else {
            configureUI()
        }
        
    }
    
    @IBAction func didTapWAIT(_ sender: UIButton) {
        
        func configureUI() {
            self.callout.isEnabled = true
            self.callout.setTitleColor(.white, for: .normal)
            self.wait.isEnabled = false
            self.wait.setTitleColor(.cabigateThemeColor, for: .normal)
            self.pob.isEnabled = true
            self.pob.setTitleColor(.white, for: .normal)
            self.deliverd.isEnabled = false
            self.deliverd.setTitleColor(.gray, for: .normal)
        }
        
        if Driver.shared.value!.jobDetails!.status == nil || Driver.shared.value!.jobDetails!.status != "wait" {
            if let driver = DatabaseManager.realm.objects(Driver.self).first {
                
                let now = moment(Date())
                let validTime = moment(["year": now.year,
                                        "second": now.second,
                                        "month": now.month,
                                        "minute": now.minute,
                                        "hour": now.hour,
                                        "day": now.day
                    ])!
                
                
                
                Driver.shared.value!.waitingStartTime = validTime.epoch()
                
               self.endJobTime = Date()

                
                let calendar = NSCalendar.current
                
                let dateComponents =  calendar.dateComponents([.second], from: self.startJobTime!, to: self.endJobTime!)
                
               
                let seconds = dateComponents.second
                
                
                print("Seconds: \(seconds)")
                
                Driver.shared.value!.totalTime += Double(seconds!)
                
                Driver.shared.value!.stopTime = validTime.epoch()
           //     if Driver.shared.value!.startTime != 0 {
//                    let difference = Duration(value: Driver.shared.value!.stopTime).subtract(Duration(value: Driver.shared.value!.startTime))
//
//
//                    Driver.shared.value!.totalTime += difference.seconds
           //     }
                let params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!,"status":"wait", "jobid":Driver.shared.value!.jobDetails!.jobid!]
                self.showHud()
                APIServices.UpdateJobStatus(params: params, callback: { (error) in
                    guard (error == nil) else {
                        self.hideHud(title: "Error", desc: error!)
                        return
                    }
                    self.hud.hide(animated: true)
                    let driver = Driver.shared.value
                    driver?.jobDetails?.status = "wait"
                    Driver.shared.value = driver
                    
                    configureUI()
                    
                    let defaults = UserDefaults.standard
                    if let previous = defaults.value(forKey: Driver.shared.value!.jobDetails!.jobid!) as? Int {
                        if (1 + Driver.shared.value!.jobDetails!.waypoints!.count != previous) {
                            defaults.setValue(previous + 1, forKey: Driver.shared.value!.jobDetails!.jobid!)
                        }
                    }else {
                        defaults.setValue(1, forKey: Driver.shared.value!.jobDetails!.jobid!)
                    }
                    defaults.synchronize()
                    self.tableView.reloadData()
                })
            }
        }else if Driver.shared.value!.jobDetails!.status == "wait" && self.wait.titleLabel!.textColor != .cabigateThemeColor, Driver.shared.value!.shouldGoToNextIndex{
            print("shouldGoToNextIndex")
            let defaults = UserDefaults.standard
            if let previous = defaults.value(forKey: Driver.shared.value!.jobDetails!.jobid!) as? Int {
                if (1 + Driver.shared.value!.jobDetails!.waypoints!.count != previous) {
                    defaults.setValue(previous + 1, forKey: Driver.shared.value!.jobDetails!.jobid!)
                }
            }else {
                defaults.setValue(1, forKey: Driver.shared.value!.jobDetails!.jobid!)
            }
            defaults.synchronize()
            configureUI()
            self.tableView.reloadData()
            
        }else{
            configureUI()
        }
    }
    
    @IBAction func didTapPOB(_ sender: UIButton) {
        
        CabLocationManager.shared.startJob()

        func configureUI() {
            self.callout.isEnabled = true
            self.callout.setTitleColor(.white, for: .normal)
            self.wait.isEnabled = true
            self.wait.setTitleColor(.white, for: .normal)
            self.pob.isEnabled = false
            self.pob.setTitleColor(.cabigateThemeColor, for: .normal)
            self.deliverd.isEnabled = true
            self.deliverd.setTitleColor(.white, for: .normal)
        }
        
        if Driver.shared.value!.jobDetails!.status == nil || Driver.shared.value!.jobDetails!.status != "pob" {
            if let driver = DatabaseManager.realm.objects(Driver.self).first {
                
                let now = moment(Date())
                let validTime = moment(["year": now.year,
                                        "second": now.second,
                                        "month": now.month,
                                        "minute": now.minute,
                                        "hour": now.hour,
                                        "day": now.day
                    ])!
                
                
                Driver.shared.value!.waitingStopTime = validTime.epoch()
                //     if Driver.shared.value!.startTime != 0 {
                let difference = Duration(value: Driver.shared.value!.waitingStopTime).subtract(Duration(value: Driver.shared.value!.waitingStartTime))
                Driver.shared.value!.waitingTotalTime += difference.seconds
                
                
                Driver.shared.value!.startTime = validTime.epoch()
                self.startJobTime = Date()
                
                let params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!,"status":"pob", "jobid":Driver.shared.value!.jobDetails!.jobid!]
                self.showHud()
                APIServices.UpdateJobStatus(params: params, callback: { (error) in
                    guard (error == nil) else {
                        self.hideHud(title: "Error", desc: error!)
                        return
                    }
                    self.hud.hide(animated: true)
                    let driver = Driver.shared.value
                    driver?.jobDetails?.status = "pob"
                    Driver.shared.value = driver
                    configureUI()
                })
            }
        }else {
            configureUI()
        }
        
    }
    
    @IBAction func didTapDELIEVERD(_ sender: UIButton) {
        
        self.presenter = {
            let width = ModalSize.custom(size: Float(self.view.frame.size.width - 60))
            let height = ModalSize.custom(size: 250)
            let center = ModalCenterPosition.customOrigin(origin: CGPoint.init(x: 30, y: self.view.frame.midY + 25))
            let customType = PresentationType.custom(width: width, height: height, center: center)
            
            let customPresenter = Presentr(presentationType: customType)
            customPresenter.transitionType = TransitionType.crossDissolve
            customPresenter.dismissTransitionType = TransitionType.crossDissolve
            customPresenter.backgroundOpacity = 0.5
            // customPresenter.dismissAnimated = true
            return customPresenter
        }()
        
        let now = moment(Date())
        let validTime = moment(["year": now.year,
                                "second": now.second,
                                "month": now.month,
                                "minute": now.minute,
                                "hour": now.hour,
                                "day": now.day
            ])!
        
        Driver.shared.value!.stopTime = validTime.epoch()
        //     if Driver.shared.value!.startTime != 0 {
//        let difference = Duration(value: Driver.shared.value!.stopTime).subtract(Duration(value: Driver.shared.value!.startTime))
//        Driver.shared.value!.totalTime += difference.seconds
        
        self.endJobTime = Date()
        
        let calendar = NSCalendar.current
        let dateComponents =  calendar.dateComponents([.second], from: self.startJobTime!, to: self.endJobTime!)
        let seconds = dateComponents.second
        print("Seconds: \(String(describing: seconds))")
        
        Driver.shared.value!.totalTime = Double(seconds!)
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "farepaymentforjob") as! FarePaymentForJobVC
        vc.delgate = self
        self.customPresentViewController(self.presenter, viewController: vc, animated: true, completion: nil)
    }
    
    @IBAction func didTapReportProblem(_ sender: UIButton) {
        
        self.presenter = {
            let width = ModalSize.custom(size: Float(self.view.frame.size.width - 60))
            let height = ModalSize.custom(size: 200)
            let center = ModalCenterPosition.customOrigin(origin: CGPoint.init(x: 30, y: self.view.frame.midY))
            let customType = PresentationType.custom(width: width, height: height, center: center)
            
            let customPresenter = Presentr(presentationType: customType)
            customPresenter.transitionType = TransitionType.crossDissolve
            customPresenter.dismissTransitionType = TransitionType.crossDissolve
            customPresenter.backgroundOpacity = 0.3
            customPresenter.dismissAnimated = true
            return customPresenter
        }()
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "reportProblemVCSID") as! ReportProblemViewController
        vc.delgate = self
        self.customPresentViewController(self.presenter, viewController: vc, animated: true, completion: nil)
        
    }
    
    @objc func didTapPickupTitle(_ sender: UITapGestureRecognizer) {
        let tag = sender.view!.tag
        
        print(tag)
        
        if let driver = DatabaseManager.realm.objects(Driver.self).first {
            guard let job = Driver.shared.value?.jobDetails else { return }
            
            var obj = UpdateJobDetails(jobid: job.jobid!, userId: driver.userId!, companyId: driver.companyId!, waypointNumber: nil, lat: nil, lng: nil, location: nil, type: "waypoint")
            
            //
            //        guard let job = Driver.shared.value?.jobDetails else { return }
            var height: Float = 130 // 130 is for update and cancel button while 175 is for delete, update & cancel button
            var screenType = UpdateLocationType.pickup
            obj.type = "pickup"
            if let waypoints = job.waypoints {
                
                if tag == 0 {   // pickup location
                    screenType = UpdateLocationType.pickup
                    height = 130
                    obj.type = "pickup"
                    obj.lat = job.pickup_lat!
                    obj.lng = job.pickup_lng!
                    obj.location = job.pickup!
                    //                lat = job.pickup_lat!
                    //                long = job.pickup_lng!
                } else if tag == 2 + waypoints.count - 1 {      // dropof location
                    screenType = UpdateLocationType.dropoff
                    height = 130
                    obj.type = "dropoff"
                    obj.lat = job.drop_lat!
                    obj.lng = job.drop_lng!
                    obj.location = job.dropoff!
                    //                lat = job.drop_lat!
                    //                long = job.drop_lng!
                }else {     // waypoint
                    screenType = UpdateLocationType.waypoint
                    height = 175
                    obj.type = "waypoint"
                    
                    let waypoint = waypoints[tag - 1]
                    obj.lat = waypoint.lat!
                    obj.lng = waypoint.lng!
                    obj.location = waypoint.point!
                    obj.waypointNumber = tag
                }
            }else if tag != 0 {     // drop off
                height = 130
                screenType = UpdateLocationType.dropoff
                obj.type = "dropoff"
                obj.lat = job.drop_lat!
                obj.lng = job.drop_lng!
                obj.location = job.dropoff!
                
                
            }else {     // pick up
                height = 130
                screenType = UpdateLocationType.pickup
                obj.type = "pickup"
                obj.lat = job.pickup_lat!
                obj.lng = job.pickup_lng!
                obj.location = job.pickup!
                
            }
            
            self.presenter = {
                let width = ModalSize.custom(size: Float(self.view.frame.size.width - 60))
                let pheight = ModalSize.custom(size: height)
                let center = ModalCenterPosition.customOrigin(origin: CGPoint.init(x: 30, y: self.view.frame.midY))
                let customType = PresentationType.custom(width: width, height: pheight, center: center)
                
                let customPresenter = Presentr(presentationType: customType)
                customPresenter.transitionType = TransitionType.crossDissolve
                customPresenter.dismissTransitionType = TransitionType.crossDissolve
                customPresenter.backgroundOpacity = 0.3
                customPresenter.dismissAnimated = true
                return customPresenter
            }()
            
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "updatelocationvcSID") as! UpdateLocationVC
            vc.delegate = self
            vc.screenType = screenType
            vc.details = obj
            self.customPresentViewController(self.presenter, viewController: vc, animated: true, completion: nil)
        }
    }
    
    @objc func didTapPickupNav(sender: UITapGestureRecognizer) {
        
        guard let job = Driver.shared.value?.jobDetails else { return }
        
        var lat = "0"
        var long = "0"
        let tag = sender.view!.tag
        
        
        if let waypoints = job.waypoints {
            if tag == 0 {
                lat = job.pickup_lat!
                long = job.pickup_lng!
            } else if tag == 2 + waypoints.count - 1 {
                lat = job.drop_lat!
                long = job.drop_lng!
            }else {
                let waypoint = waypoints[tag - 1]
                lat = waypoint.lat!
                long = waypoint.lng!
            }
        }else if tag != 0{
            lat = job.drop_lat!
            long = job.drop_lng!
        }else {
            lat = job.pickup_lat!
            long = job.pickup_lng!
        }
        
        
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        //First check Google Maps installed on User's phone or not.
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            
            
            let googleMapActionButton = UIAlertAction(title: "Google Map", style: .default) { _ in
                UIApplication.shared.open(URL(string:
                    "comgooglemaps://?saddr=&daddr=\(lat),\(long)&directionsmode=driving")!, options: [:], completionHandler: { (bool) in
                })
            }
            actionSheetController.addAction(googleMapActionButton)
            
        } else {
            // Google Map is not installed. Launch AppStore to install Waze app
            if let aString = URL(string: "https://itunes.apple.com/us/app/google-maps-transit-food/id585027354?mt=8") {
                UIApplication.shared.open(aString, options: [:], completionHandler: nil)
                
            }
            
        }
        
    
//        let appleMapActionButton = UIAlertAction(title: "Apple Map", style: .default)
//        { _ in
//            let directionsURL = "http://maps.apple.com/?saddr=\( CabLocationManager.shared.lastLocation.coordinate.latitude),\(CabLocationManager.shared.lastLocation.coordinate.longitude)&daddr=\(lat),\(long)"
//            guard let url = URL(string: directionsURL) else {
//                return
//            }
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            } else {
//                UIApplication.shared.openURL(url)
//            }
//        }
//        actionSheetController.addAction(appleMapActionButton)
        
        if (UIApplication.shared.canOpenURL(URL(string:"waze://")!)) {  //First check Waze Mpas installed on User's phone or not.
            let wazeActionButton = UIAlertAction(title: "Waze Map", style: .default)
            { _ in
            
                self.navigate(toLatitude: lat, longitude: long)
                
            }
            actionSheetController.addAction(wazeActionButton)

            
            
        } else {
            print("Can't use waze://");
        }
       
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        self.present(actionSheetController, animated: true, completion: nil)
        
        
        
       
        
    }

    func navigate(toLatitude latitude: String, longitude: String) {
        if let aString = URL(string: "waze://") {
            if UIApplication.shared.canOpenURL(aString) {
                // Waze is installed. Launch Waze and start navigation
                let urlStr = "https://waze.com/ul?ll=\(latitude),\(longitude)&navigate=yes"
                if let aStr = URL(string: urlStr) {
                    UIApplication.shared.open(aStr, options: [:], completionHandler: nil)

                }
            } else {
                // Waze is not installed. Launch AppStore to install Waze app
                if let aString = URL(string: "http://itunes.apple.com/us/app/id323229106") {
                        UIApplication.shared.open(aString, options: [:], completionHandler: nil)
                    
                }
            }
        }
    }
    @objc func didTapPhoneNumber() {
        print(Driver.shared.value!.jobDetails!.paxtel!)
        let url = URL(string: "TEL://\(Driver.shared.value!.jobDetails!.paxtel!)")
        UIApplication.shared.open(url!)
    }
    
    
}

extension BusyViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let job = Driver.shared.value?.jobDetails else { return 0}
        guard let waypoints = job.waypoints else { return 3 }
        return 3 + waypoints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let job = Driver.shared.value?.jobDetails else { return UITableViewCell() }
        
        let defaults = UserDefaults.standard
        var highlightedIndex = 0
        if let previous = defaults.value(forKey: Driver.shared.value!.jobDetails!.jobid!) as? Int {
            highlightedIndex = previous
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "busypickupcell") as! BusyPickupCell
        
        let navGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapPickupNav(sender:)))
        cell.navBgView.tag = indexPath.row
        cell.navBgView.addGestureRecognizer(navGesture)
        
        let pickGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapPickupTitle(_:)))
        cell.titleBgView.tag = indexPath.row
        cell.titleBgView.addGestureRecognizer(pickGesture)
        
        if highlightedIndex == indexPath.row  {
            cell.travelTitle.textColor = .cabigateThemeColor
            cell.placeName.textColor = .cabigateThemeColor
            cell.checkmark.isHidden = true
            cell.navBgView.isHidden = false
        }else if highlightedIndex > indexPath.row {
            cell.travelTitle.textColor = .white
            cell.placeName.textColor = .white
            cell.checkmark.isHidden = false
            cell.navBgView.isHidden = true
        }else {
            cell.travelTitle.textColor = .white
            cell.placeName.textColor = .white
            cell.checkmark.isHidden = true
            cell.navBgView.isHidden = true
        }
        
        if indexPath.row == 0 {
            cell.travelTitle.text = "PICK UP LOCATION"
            cell.placeName.text = job.pickup!
            return cell
        }
        
        if indexPath.row <= job.waypoints!.count{
            cell.travelTitle.text = "WAYPOINT \(indexPath.row)"
            cell.placeName.text = job.waypoints![indexPath.row - 1].point!
            return cell
        }
        
        if indexPath.row == job.waypoints!.count + 1{
            cell.travelTitle.text = "DROP OFF LOCATION"
            cell.placeName.text = job.dropoff!
            return cell
        }
        
        if indexPath.row == job.waypoints!.count + 2{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "busydetailcell") as! BusyDetailCell
            let passengers = Int(job.passengers!)!
            for passengerIcon in cell.passengerIcon[0..<passengers] {
                passengerIcon.image = #imageLiteral(resourceName: "passengerSelected")
            }
            
            let bags = Int(job.bags!)!
            for bagIcon in cell.bagIcons[0..<bags] {
                bagIcon.image = #imageLiteral(resourceName: "bagsSelected")
            }
            
            cell.fareEstimateLabel.text = "Fare Estimate (\(job.payment_type!))"
            cell.fare.text = job.fare!
            cell.when.text = job.pickuptime!
            cell.passengerName.text = job.paxname!
            cell.notes.text = "NOTES: \(job.notes!)"
            cell.contactNumber.text = job.paxtel!
            
            let phoneGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapPhoneNumber))
            cell.contactBgView.addGestureRecognizer(phoneGesture)
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let job = Driver.shared.value?.jobDetails else { return 0 }
        if let waypoint = job.waypoints {
            if indexPath.row == (3 + waypoint.count - 1) {
                return UITableViewAutomaticDimension
            }
        }
        return 72
    }
}

extension BusyViewController: ReportProblemVCDelegate{
    func confirm() {
        self.presenter = {
            let width = ModalSize.custom(size: Float(self.view.frame.size.width - 60))
            let height = ModalSize.custom(size: 350)
            let center = ModalCenterPosition.customOrigin(origin: CGPoint.init(x: 30, y: self.view.frame.midY - 40))
            let customType = PresentationType.custom(width: width, height: height, center: center)
            
            let customPresenter = Presentr(presentationType: customType)
            customPresenter.transitionType = TransitionType.crossDissolve
            customPresenter.dismissTransitionType = TransitionType.crossDissolve
            customPresenter.backgroundOpacity = 0.3
            customPresenter.dismissAnimated = true
            return customPresenter
        }()
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "cancelJobSID") as! CancelJobViewController
        vc.delegate = self
        self.customPresentViewController(self.presenter, viewController: vc, animated: true, completion: nil)
        
    }
}

extension BusyViewController {
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

extension BusyViewController: FarePaymentForJobVCDelegate {
    func next() {
        self.presenter = {
            let width = ModalSize.custom(size: Float(self.view.frame.size.width - 60))
            let height = ModalSize.custom(size: 250)
            let center = ModalCenterPosition.customOrigin(origin: CGPoint.init(x: 30, y: self.view.frame.midY + 25))
            let customType = PresentationType.custom(width: width, height: height, center: center)
            
            let customPresenter = Presentr(presentationType: customType)
            customPresenter.transitionType = TransitionType.crossDissolve
            customPresenter.dismissTransitionType = TransitionType.crossDissolve
            customPresenter.backgroundOpacity = 0.7
            customPresenter.dismissAnimated = false
            return customPresenter
        }()
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "feedbackvc") as! FeedbackViewController
        guard let job = Driver.shared.value?.jobDetails else { return }
        vc.payText = "PAY BY \(job.payment_type!.uppercased())"
        vc.delgate = self
        self.customPresentViewController(self.presenter, viewController: vc, animated: true, completion: nil)
        
    }
}

extension BusyViewController: CancelJobVCDelegate {
    func yes(reason: String) {
        CabLocationManager.shared.stopJob()
        if let driver = DatabaseManager.realm.objects(Driver.self).first {
            let params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!, "jobid":Driver.shared.value!.jobDetails!.jobid!, "reason":reason,]
            self.showHud()
            let cancelJobId = Driver.shared.value!.jobDetails!.jobid!
            APIServices.CancelJob(params: params, callback: { (error, hasJob)  in
                    guard (error == nil) else {
                        self.hideHud(title: "Error", desc: error!)
                        return
                    }
                    
                    CabLocationManager.shared.stopJob()
                    let defaults = UserDefaults.standard
                    defaults.removeObject(forKey: cancelJobId)
                    defaults.synchronize()
                    
                    self.hud.hide(animated: true)
                    if hasJob == false {
                        let driverObj = Driver.shared.value
                        driverObj?.jobDetails = nil
                        Driver.shared.value! = driverObj!
                        
                        // update status to free
                        let params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!,"status":"free", "eta":"0"]
                        APIServices.StatusUpdate(params: params, callback: { (error) in
                            let driverObj = Driver.shared.value
                            driverObj?.last_status = "free"
                            
                            Driver.shared.value = driverObj
                        })
                    }else {
                        //  Driver.shared.asObservable().subscribe { (driver) in
                        UserDefaults.standard.synchronize()
                        guard let driver = Driver.shared.value, let job = driver.jobDetails else { return }
                        guard let jobstatus = job.status else {
                            self.didTapCallout(self.callout)
                            return
                        }
                        if jobstatus == "callout" {
                            UserDefaults.standard.setValue(0, forKey: Driver.shared.value!.jobDetails!.jobid!)
                            UserDefaults.standard.synchronize()
                            self.didTapCallout(self.callout)
                        }else if jobstatus == "wait" {
                            self.didTapWAIT(self.wait)
                            
                        }else if jobstatus == "pob" {
                            self.didTapPOB(self.pob)
                        }else {
                            UserDefaults.standard.setValue(0, forKey: Driver.shared.value!.jobDetails!.jobid!)
                            UserDefaults.standard.synchronize()
                            self.didTapCallout(self.callout)
                            
                        }
                        self.tableView.reloadData()
                    }
                })
        }
    }
}


extension BusyViewController: FeedbackVCDelegate {
    func submit(feedback: String) {
        
        // complete job than show popup
        if let driver = DatabaseManager.realm.objects(Driver.self).first {
            let params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!, "jobid":Driver.shared.value!.jobDetails!.jobid!, "rating":"5", "comment":feedback,  "fare":Driver.shared.value!.jobDetails!.fare!, "pay_via":Driver.shared.value!.jobDetails!.payment_type!]
            self.showHud()
            
            if CabLocationManager.shared.traveledDistance != 0
            {
                
                let job = driver.jobDetails
                
                
                let param = ["jobid":Driver.shared.value!.jobDetails!.jobid!,"userid":driver.userId!,"duration":job?.duration ,"distance":String(format:"%.2",CabLocationManager.shared.traveledDistance) ,"waiting_time": String(format: "%f", Driver.shared.value!.waitingTotalTime) ]
                
                APIServices.WaitingTimeForJob(params: param as [String: Any]) { (error) in
                    guard (error == nil) else {
                        return
                    }
                }
                

                
            }
            
            let deliverJobId = Driver.shared.value!.jobDetails!.jobid!
            APIServices.DeliverJob(params:  params) { (error, hasJob)  in
                guard (error == nil) else {
                    self.hideHud(title: "Error", desc: error!)
                    return
                }
                
                CabLocationManager.shared.stopJob()
                let defaults = UserDefaults.standard
                defaults.removeObject(forKey: deliverJobId)
                defaults.synchronize()
                
                self.hud.hide(animated: true)
                if hasJob == false {
                    let driverObj = Driver.shared.value
                    driverObj?.jobDetails = nil
                    Driver.shared.value! = driverObj!
                    
                    self.presenter = {
                        let width = ModalSize.custom(size: Float(self.view.frame.size.width - 60))
                        let height = ModalSize.custom(size: 250)
                        let center = ModalCenterPosition.customOrigin(origin: CGPoint.init(x: 30, y: self.view.frame.midY + 25))
                        let customType = PresentationType.custom(width: width, height: height, center: center)
                        
                        let customPresenter = Presentr(presentationType: customType)
                        customPresenter.transitionType = TransitionType.crossDissolve
                        customPresenter.dismissTransitionType = TransitionType.crossDissolve
                        customPresenter.backgroundOpacity = 0.7
                        // customPresenter.dismissAnimated = true
                        return customPresenter
                    }()
                    
                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "jobcompletevc") as! JobCompleteViewController
                    self.customPresentViewController(self.presenter, viewController: vc, animated: true, completion: nil)
                    
                    // update status to free
                    let params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!,"status":"free", "eta":"0"]
                    APIServices.StatusUpdate(params: params, callback: { (error) in
                        let driverObj = Driver.shared.value
                        driverObj?.last_status = "free"
                        
                        Driver.shared.value = driverObj
                    })
                }else {
                    //  Driver.shared.asObservable().subscribe { (driver) in
                    UserDefaults.standard.synchronize()
                    guard let driver = Driver.shared.value, let job = driver.jobDetails else { return }
                    guard let jobstatus = job.status else {
                        self.didTapCallout(self.callout)
                        return
                    }
                    if jobstatus == "callout" {
                        UserDefaults.standard.setValue(0, forKey: Driver.shared.value!.jobDetails!.jobid!)
                        UserDefaults.standard.synchronize()
                        self.didTapCallout(self.callout)
                    }else if jobstatus == "wait" {
                        self.didTapWAIT(self.wait)
                        
                    }else if jobstatus == "pob" {
                        self.didTapPOB(self.pob)
                    }else {
                        UserDefaults.standard.setValue(0, forKey: Driver.shared.value!.jobDetails!.jobid!)
                        UserDefaults.standard.synchronize()
                        self.didTapCallout(self.callout)
                        
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension BusyViewController: UpdateLocationDelegate {
    func update(details: UpdateJobDetails) {
        self.jobDetails = details
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func delete(details: UpdateJobDetails) {
        print(#function)
        var parameters: [String : Any] = ["jobid":details.jobid,
                                          "userid":details.userId,
                                          "companyid":details.companyId,
                                          "action":"delete",
                                          "lat":details.lat!,
                                          "lng":details.lng!,
                                          "location":details.location!,
                                          "type": details.type]
        if details.type == "waypoint" {
            parameters["waypointnumber"] = details.waypointNumber!
        }
        APIServices.UpdateJobDetails(params: parameters, callback: { (error) in
            
        })
        
    }
}
extension BusyViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        
        guard let details = self.jobDetails else { return }
        print("type = \(details.type)")
        
        let parameters: [String : Any] = ["jobid":details.jobid,
                                          "userid":details.userId,
                                          "companyid":details.companyId,
                                          "action":"update",
                                          "lat":place.coordinate.latitude,
                                          "lng":place.coordinate.longitude,
                                          "location":place.name,
                                          "type": details.type]
        
        APIServices.UpdateJobDetails(params: parameters, callback: { (error) in
            
        })
        
        self.jobDetails = nil
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}


