//
//  JobDetailViewController.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 03/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyTimer
import SwiftMoment
import AVFoundation

class JobDetailViewController: UIViewController {
    
    @IBOutlet weak var passengername: UILabel!
    @IBOutlet weak var pickupLocation: UILabel!
    @IBOutlet weak var dropOffLocation: UILabel!
    @IBOutlet weak var when: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var fare: UILabel!
    @IBOutlet weak var passenger: UILabel!
    @IBOutlet weak var bags: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var countDownView: UIView!
    var screenType: JobScreenType?
    var offer: Offer?
    var queue: Queue?
    var joboffer: ShowJob?
    
    var hud = MBProgressHUD()
    var timer: Timer = Timer()
    
    var offersDelegate: OfferVCDelegate? = nil
    var delgate: JobDetailVCResponse? = nil
    
    var player: AVAudioPlayer?
    
    
    @objc func methodToRefresh()
  {
    if self.screenType!.rawValue == 2 {
    playSound()
    }
    
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timer.invalidate()
        print(#function)
        
        NotificationCenter.default.addObserver(self, selector:#selector(methodToRefresh), name: NSNotification.Name.UIApplicationWillEnterForeground, object: UIApplication.shared)

        switch screenType! {
        case .queue:
            self.acceptButton.isHidden = true
            guard let queue = self.queue  else { return }
            self.passengername.text = queue.paxname
            self.pickupLocation.text = queue.pickup
            self.dropOffLocation.text = queue.dropoff
            self.when.text = queue.when
            self.duration.text = queue.duration
            self.fare.text = "\(queue.fare!) GBP"
            self.passenger.text = queue.passengers
            self.bags.text = queue.bags
            
        case .offers:
            guard let offer = self.offer  else { return }
            self.passengername.text = offer.paxname
            self.pickupLocation.text = offer.pickup
            self.dropOffLocation.text = offer.dropoff
            self.when.text = offer.when
            self.duration.text = offer.duration
            self.fare.text = "\(offer.fare!) GBP"
            self.passenger.text = offer.passengers
            self.bags.text = offer.bags
            
            
        case .joboffer:
//            self.playSound()
            self.countDownView.isHidden = false
            self.countDownLabel.isHidden = false
            self.cancelButton.setTitle("REJECT", for: .normal)
            self.updateTimer(seconds: .fourtyFiveSeconds)
            guard let job = self.joboffer  else { return }
            self.passengername.text = job.paxname
            self.pickupLocation.text = job.pickup
            self.dropOffLocation.text = job.dropoff
            self.when.text = job.when
            self.duration.text = job.duration
            self.fare.text = "\(job.fare!) GBP"
            self.passenger.text = job.passengers
            self.bags.text = job.bags
        }
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        Sound.stopAll()
        guard let player = self.player else  { return }
        player.stop()
        
        NotificationCenter.default.removeObserver(self)

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if self.screenType!.rawValue == 2 {
            playSound()
        }
        
        
    }
    
    func playSound() {
        Sound.stopAll()
        Sound.play(file: "tick_muscic", fileExtension: "wav", numberOfLoops: -1)
        
        return
        guard let url = Bundle.main.url(forResource: "tick_muscic", withExtension: "wav") else { print("no sound"); return }
        
        if let player = self.player {
            
            player.stop()
            self.player = nil
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            
            UIApplication.shared.beginReceivingRemoteControlEvents()
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            player?.prepareToPlay()
            guard let player = player else { return }
            player.numberOfLoops = -1
                player.play()
            
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        switch self.screenType! {
        case .joboffer:
            CabigateSocket.socket.emit("sendstatus", ["status": "0","jobid":joboffer!.jobid,"room_id":joboffer!.room_id, "to":joboffer!.sender])
            self.timer.invalidate()

            
            Sound.stopAll()
//                if self.player != nil
//                {
//                    self.player?.stop()
//                }
            
            self.dismiss(animated: true, completion: nil)
            Sound.stopAll()
            guard let player = self.player else  { return }
            player.stop()
            
        default:
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func didTapAgree(_ sender: UIButton) {
        switch self.screenType! {
        case .offers:
            self.showHud()
            CabLocationManager.shared.traveledDistance = 0
            if let driver = DatabaseManager.realm.objects(Driver.self).first {
                let params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!, "jobid": self.offer!.jobid!]
                APIServices.AcceptOffer(params: params) { (error ) in
                    guard (error == nil) else {
                        self.hideHud(title: "Error", desc: error!)
                        return
                    }
                    self.hud.hide(animated: true)
                    self.offersDelegate?.accepted()
                    self.dismiss(animated: true, completion: nil)
                    
                }
            }
        case .joboffer:
            
            let driverObj = Driver.shared.value
            
            if driverObj?.jobDetails != nil{
                CabigateSocket.socket.emit("sendstatus", ["status": "2","jobid":self.joboffer!.jobid,"room_id":self.joboffer!.room_id, "to":self.joboffer!.sender])
                self.dismiss(animated: false, completion: nil)
            }else {
                self.showHud()
                
                if let realmDriver = DatabaseManager.realm.objects(Driver.self).first {

                    // update driver satatus to busy
                    let paramsBusy = ["companyid":realmDriver.companyId!,"userid":realmDriver.userId!, "token":realmDriver.token!,"status":"busy", "eta":"0"]
                    APIServices.StatusUpdate(params: paramsBusy, callback: { (error) in })
    
                    CabigateSocket.socket.emit("sendstatus", ["status": "1","jobid":self.joboffer!.jobid,"room_id":self.joboffer!.room_id, "to":self.joboffer!.sender])
                    let params = ["companyid":realmDriver.companyId!,"userid":realmDriver.userId!, "token":realmDriver.token!]
                    Timer.after(1, {
                        APIServices.LastState(params: params, callback: { (error) in
                            self.hud.hide(animated: true)
                            self.dismiss(animated: false, completion: nil)
                            self.delgate?.accepted()
                        })
                    })
                }
            }
            Sound.stopAll()
//            guard let player = self.player else  { return }
//            player.stop()
            
        default:
            break
        }
    }
}

extension JobDetailViewController {
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
    
    func updateTimer(seconds: AwayTimes?) {
        
        
        let now = Date()
        let validTime = moment(["year": moment(now).year,
                                "second": moment(now).second + seconds!.rawValue,
                                "month": moment(now).month,
                                "minute": moment(now).minute,
                                "hour": moment(now).hour,
                                "day": moment(now).day
            ])!
        
        self.timer = Timer.every(1.seconds) { (timer: Timer) in
            let difference = Duration(value: validTime.date.timeIntervalSince1970).subtract(Duration(value: Date().timeIntervalSince1970))
            let seconds = String(format: "%02d", (Int(difference.seconds.truncatingRemainder(dividingBy: 60))))
            self.countDownLabel.text = "\(seconds)"
            
            
            
            if self.countDownLabel.text! == "00" {
                self.timer.invalidate()
                Sound.stopAll()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

