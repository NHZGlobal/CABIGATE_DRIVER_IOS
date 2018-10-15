//
//  CurrentViewController.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 01/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Presentr
import RxSwift

protocol AwayTimesDelegate {
    func selectedTime(minutes: AwayTimes)
}

protocol AwayVCDelegate {
    func availableNow()
}

class CurrentViewController: UIViewController {
    
    @IBOutlet weak var availableView: UIView!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var awayView: UIView!
    @IBOutlet weak var awayLabel: UILabel!
    @IBOutlet weak var busyView: UIView!
    @IBOutlet weak var busyLabel: UILabel!
    
    var currentStatus = DriverStatus.available
    var container: ContainerViewController!
    
    var presenter: Presentr!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.availableView.makeRound()
        self.awayView.makeRound()
        self.busyView.makeRound()
        self.updateUI()

        Driver.shared.asObservable().subscribe { (driver) in
            guard let driver = Driver.shared.value else { return }
            if driver.jobDetails != nil {
                UserDefaults.standard.synchronize()
                self.currentStatus = DriverStatus.busy
                if let realmDriver = DatabaseManager.realm.objects(Driver.self).first {
                    
                    // update driver satatus to busy
                    if driver.last_status != "busy" {
                        let params = ["companyid":realmDriver.companyId!,"userid":realmDriver.userId!, "token":realmDriver.token!,"status":"busy", "eta":"0"]
                        APIServices.StatusUpdate(params: params, callback: { (error) in })
                    }
                }
                self.updateUI()
                
                let defaults = UserDefaults.standard
                defaults.removeObject(forKey: "awayExpiry")
                defaults.synchronize()

                
            }else if driver.last_status == "away"{
                if self.currentStatus != DriverStatus.away {
                self.currentStatus = DriverStatus.away
                    self.updateUI()
                }
            }else {
                self.currentStatus = DriverStatus.available
                self.updateUI()
                
                let defaults = UserDefaults.standard
                defaults.removeObject(forKey: "awayExpiry")
                defaults.synchronize()

            }
            
            }.disposed(by: self.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addBackground()
        UIApplication.shared.statusBarView?.backgroundColor = .white
    }
    
    @IBAction func didTapAvailable(_ sender: UITapGestureRecognizer) {
        if self.currentStatus == .busy { return }

        self.currentStatus = .available
        self.updateUI()

    }
    
    @IBAction func didTapAway(_ sender: UITapGestureRecognizer) {
        if self.currentStatus == .busy || self.currentStatus == .away { return }
        presenter = {
            let width = ModalSize.custom(size: Float(self.view.frame.size.width - 80))
            let height = ModalSize.custom(size: 250)
            let center = ModalCenterPosition.customOrigin(origin: CGPoint.init(x: 40, y: self.view.frame.midY - 20))
            let customType = PresentationType.custom(width: width, height: height, center: center)
            
            let customPresenter = Presentr(presentationType: customType)
            customPresenter.transitionType = TransitionType.crossDissolve
            customPresenter.dismissTransitionType = TransitionType.crossDissolve
            customPresenter.backgroundOpacity = 0.3
            customPresenter.dismissAnimated = true
            return customPresenter
        }()
        
        let awayTimes = self.storyboard!.instantiateViewController(withIdentifier: "awaytimesSID") as! AwayTimesViewController
        awayTimes.delgate = self
        customPresentViewController(presenter, viewController: awayTimes, animated: true, completion: nil)
        
        self.currentStatus = .away
        self.updateUI()
    }
    
    @IBAction func didTapBusy(_ sender: UITapGestureRecognizer) {
        self.currentStatus = .busy
        self.updateUI()
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "container"{
            container = segue.destination as! ContainerViewController
        }
    }
}

extension CurrentViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "CURRENT", image: #imageLiteral(resourceName: "currentSelected"))
    }
}

extension CurrentViewController: AwayTimesDelegate {
    func selectedTime(minutes: AwayTimes) {
        awayConfigure(bool: true, timer: minutes)
    }
}

extension CurrentViewController: AwayVCDelegate {
    func availableNow() {
        self.awayConfigure(bool: false, timer: nil)
        self.availableConfigure(bool: true)
    }
}

extension CurrentViewController {
    func updateUI() {
        switch currentStatus {
        case .available:
            self.availableConfigure(bool: true)
            self.awayConfigure(bool: false, timer: nil)
            self.busyConfigure(bool: false)
        case .away:
            self.availableConfigure(bool: false)
            self.awayConfigure(bool: true, timer: nil)
            self.busyConfigure(bool: false)
        case .busy:
            self.availableConfigure(bool: false)
            self.awayConfigure(bool: false, timer: nil)
            self.busyConfigure(bool: true)
        }
    }
    
    func availableConfigure(bool: Bool) {
        switch bool {
        case true:
            self.availableView.backgroundColor = .availableColor
            self.availableLabel.textColor = .white
            container!.segueIdentifierReceivedFromParent("available")
            
        case false:
            self.availableView.backgroundColor = .clear
            self.availableView.addBorder(color: .availableColor, width: 5)
            self.availableLabel.textColor = .availableColor
        }
    }
    
    func awayConfigure(bool: Bool, timer:AwayTimes?) {
        switch bool {
        case true:
            self.awayView.backgroundColor = .awayColor
            self.awayLabel.textColor = .white
            container!.segueIdentifierReceivedFromParent("away")
            let controller = container.currentViewController as? AwayViewController
            controller?.updateTimer(seconds: timer)
            controller?.delgate = self
            
        case false:
            self.awayView.backgroundColor = .clear
            self.awayView.addBorder(color: .awayColor, width: 5)
            self.awayLabel.textColor = .awayColor
        }
    }
    
    func busyConfigure(bool: Bool) {
        switch bool {
        case true:
            self.busyView.backgroundColor = .busyColor
            self.busyLabel.textColor = .white
            container!.segueIdentifierReceivedFromParent("busy")
        case false:
            self.busyView.backgroundColor = .clear
            self.busyView.addBorder(color: .busyColor, width: 5)
            self.busyLabel.textColor = .busyColor
        }
    }
}
