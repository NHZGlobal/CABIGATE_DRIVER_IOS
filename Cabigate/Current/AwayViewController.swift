//
//  AwayViewController.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 02/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit
import SwiftyTimer
import SwiftMoment
import Presentr

protocol AwayTimerDoneDelegate {
    func selectedOption(stillAway: Bool, availableNow: Bool)
}

class AwayViewController: UIViewController {
    
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var timer: Timer = Timer()
    var presenter: Presentr!
    var delgate: AwayVCDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        
        self.timerView.makeRound()
        self.timerView.addBorder(color: .white, width: 5)
        
        updateTimer(seconds: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        
        if let expire = defaults.value(forKey: "awayExpiry") as? TimeInterval {
            self.expiryTime(timeInterval: expire)
        }else {
            self.timerView.isHidden = true
            self.timeLabel.isHidden = true
        }
    }
    
    @IBAction func didTapFinish(_ sender: UIButton) {
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "awayExpiry")
        defaults.synchronize()

        // update status to free
        self.timer.invalidate()
        if let driver = DatabaseManager.realm.objects(Driver.self).first {
            let params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!,"status":"free", "eta":"0"]
            APIServices.StatusUpdate(params: params, callback: { (error) in
                let driverObj = Driver.shared.value
                driverObj?.last_status = "free"
                Driver.shared.value! = driverObj!
            })
        }
    }
    
    func updateTimer(seconds: AwayTimes?) {
        self.timer.invalidate()
        
        var second: Int = 0
        if let selectedSecond = seconds {
            second = selectedSecond.rawValue
            
            if let driver = DatabaseManager.realm.objects(Driver.self).first {
                
                var params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!,"status":"away", "eta":"0"]
                switch seconds! {
                case .tenMinutes:
                    params["eta"] = "10"
                case .fifteenMinutes:
                    params["eta"] = "15"
                case .thirtyMinutes:
                    params["eta"] = "30"
                case .oneHour:
                    params["eta"] = "60"
                default:
                    break
                }
                
                APIServices.StatusUpdate(params: params, callback: { (error) in
                    let driverObj = Driver.shared.value
                    driverObj?.last_status = "away"
                    Driver.shared.value = driverObj!
                })
            }

        }else {
            self.timerView.isHidden = true
            self.timeLabel.isHidden = true
        }
        
        if second == 0 { return }
        let now = Date()
        let validTime = moment(["year": moment(now).year,
                                "second": moment(now).second + second,
                                "month": moment(now).month,
                                "minute": moment(now).minute,
                                "hour": moment(now).hour,
                                "day": moment(now).day
            ])!
        
        let defaults = UserDefaults.standard
        defaults.set(validTime.epoch(), forKey: "awayExpiry")
        defaults.synchronize()

        if let expire = defaults.value(forKey: "awayExpiry") as? TimeInterval {
             self.expiryTime(timeInterval: expire)
        }
    }
    
    func expiryTime(timeInterval: Double) {
        self.timerView.isHidden = false
        self.timeLabel.isHidden = false

        self.timer.invalidate()
        self.timer = Timer.every(1.seconds) { (timer: Timer) in
            let difference = Duration(value: timeInterval).subtract(Duration(value: moment(Date()).epoch()))
            
            if difference.seconds <= 0 {
                self.timeLabel.text = "00:00"
                self.timer.invalidate()
                self.showTimerDoneVC()
            }else {
                let minutes = String(format: "%02d", (Int(difference.minutes.truncatingRemainder(dividingBy: 60))))
                let seconds = String(format: "%02d", (Int(difference.seconds.truncatingRemainder(dividingBy: 60))))
                self.timeLabel.text = "\(minutes):\(seconds)"
            }
        }
    }
    
    func showTimerDoneVC() {
        self.presenter = {
            let width = ModalSize.custom(size: Float(self.view.frame.size.width - 60))
            let height = ModalSize.custom(size: 200)
            let center = ModalCenterPosition.customOrigin(origin: CGPoint.init(x: 30, y: self.view.frame.midY + 25))
            let customType = PresentationType.custom(width: width, height: height, center: center)
            
            let customPresenter = Presentr(presentationType: customType)
            customPresenter.transitionType = TransitionType.crossDissolve
            customPresenter.dismissTransitionType = TransitionType.crossDissolve
            customPresenter.backgroundOpacity = 0.3
            customPresenter.dismissAnimated = true
            return customPresenter
        }()
        
        let awayTimes = self.storyboard!.instantiateViewController(withIdentifier: "awaytimerdone") as! AwayTimerDoneViewController
        awayTimes.delegate = self
        self.customPresentViewController(self.presenter, viewController: awayTimes, animated: true, completion: nil)
        
    }
}

extension AwayViewController: AwayTimerDoneDelegate {
    func selectedOption(stillAway: Bool, availableNow: Bool) {
        if stillAway {
            self.updateTimer(seconds: .thirtySeconds)
        }
        if availableNow {
            
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "awayExpiry")
            defaults.synchronize()

            self.timer.invalidate()
            if let driver = DatabaseManager.realm.objects(Driver.self).first {
                let params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!,"status":"free", "eta":"0"]
                APIServices.StatusUpdate(params: params, callback: { (error) in
                    let driverObj = Driver.shared.value
                    driverObj?.last_status = "free"
                    Driver.shared.value! = driverObj!
                })
            }
        }
    }
}

