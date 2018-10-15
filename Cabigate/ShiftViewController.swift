//
//  ShiftViewController.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 01/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit
import MBProgressHUD
import Presentr
import SwiftMoment
import CoreLocation

protocol ShiftTimerPickerVCDelegate {
    func selectedMinutes(minutes: Int)
}

class ShiftViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedVehicle: UILabel!
    @IBOutlet weak var confirm: UIButton!
    @IBOutlet weak var shiftend: UIButton!
    
    var vehicleList = [VehicleList]()
    var selectedIndex:Int? = nil
    var hud = MBProgressHUD()
    var presentr: Presentr!
    
    var totalMinutes: Int = 720
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shiftend.setTitle("Shift end: \((totalMinutes/60)%60)h:\(totalMinutes%60)m", for: .normal)
        self.tableView.tableFooterView = UIView()
        self.confirm.isEnabled = false
        self.confirm.setTitleColor(.gray, for: .normal)
        
        self.navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "cabigateNavLogo"))
        
        self.showHud()
        
        if let driver = DatabaseManager.realm.objects(Driver.self).first {
            let params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!]
            APIServices.FetchVehicleList(params: params) { (error ) in
                guard (error == nil) else {
                    self.hideHud(title: "Error", desc: error!)
                    return
                }
                self.hud.hide(animated: true)
                self.vehicleList = VehicleList.shared.value
                self.tableView.reloadData()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addBackground()
        UIApplication.shared.statusBarView?.backgroundColor = .white
    }
    
    @IBAction func didTapPicker(_ sender: UIButton) {
        self.presentr = {
            let width = ModalSize.custom(size: Float(self.view.frame.size.width - 60))
            let height = ModalSize.custom(size: 250)
            let center = ModalCenterPosition.customOrigin(origin: CGPoint.init(x: 30, y: self.view.frame.midY - 100))
            let customType = PresentationType.custom(width: width, height: height, center: center)
            
            let customPresenter = Presentr(presentationType: customType)
            customPresenter.transitionType = TransitionType.crossDissolve
            customPresenter.dismissTransitionType = TransitionType.crossDissolve
            customPresenter.backgroundOpacity = 0.3
            customPresenter.dismissAnimated = true
            return customPresenter
        }()
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "shiftTimerPickerSID") as! ShiftTimePickerVC
        vc.delegate = self
        self.customPresentViewController(self.presentr, viewController: vc, animated: true, completion: nil)
        
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapConfirm(_ sender: UIButton) {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            self.showHud()
            if let driver = DatabaseManager.realm.objects(Driver.self).first {
                var lat:Double = 0
                var long:Double = 0
                if let latitude = CabLocationManager.shared.locationManager.location {
                    lat = latitude.coordinate.latitude
                }
                
                if let longitude = CabLocationManager.shared.locationManager.location {
                    long = longitude.coordinate.longitude
                }

                let params = ["companyid":driver.companyId!,
                              "userid":driver.userId!,
                              "vehicleid":self.vehicleList[self.selectedIndex!].vehicleid!,
                              "lat":"\(lat)",
                    "lng":"\(long)",
                    "duration":"\(self.totalMinutes)",
                    "token":driver.token!]
                APIServices.ShiftInService(params: params) { (error ) in
                    guard (error == nil) else {
                        self.hideHud(title: "Error", desc: error!)
                        return
                    }
                    self.hud.hide(animated: true)
                    
                    let now = moment(Date())
                    let validTime = moment(["year": now.year,
                                            "second": now.second,
                                            "month": now.month,
                                            "minute": now.minute + self.totalMinutes%60,
                                            "hour": now.hour + (self.totalMinutes/60)%60,
                                            "day": now.day
                        ])!
                    let defaults = UserDefaults.standard
                    defaults.set(validTime.epoch(), forKey: "shiftEndTime")
                    defaults.synchronize()
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
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

extension ShiftViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vehicleList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shiftvehiclecell") as! ShiftVehicleCell
        cell.bgView.addShadow()
        
        let vehicle = self.vehicleList[indexPath.row]
        
        cell.vehicleBgView.layer.borderWidth = 2
        cell.vehicleBgView.layer.borderColor = UIColor.freeVehicle.cgColor
        cell.name.text = vehicle.name
        cell.number.text = vehicle.number
        cell.status.text = vehicle.status
        
        if let selected = selectedIndex, selected == indexPath.row {
            // cell.backgroundColor = .cabigateThemeColor
            cell.bgView.backgroundColor = UIColor(red: 210/255, green: 249/255, blue: 253/255, alpha: 1.0)
        }else {
            cell.bgView.backgroundColor = .white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.selectedVehicle.text = "SELECTED: \(self.vehicleList[indexPath.row].name!)"
        let string = NSMutableAttributedString(string: self.selectedVehicle.text!)
        string.setColorForText(self.vehicleList[indexPath.row].name!, with: .cabigateThemeColor)
        self.selectedVehicle.attributedText = string
        
        self.confirm.isEnabled = true
        self.confirm.setTitleColor(.white, for: .normal)
        
        
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension ShiftViewController: ShiftTimerPickerVCDelegate {
    func selectedMinutes(minutes: Int) {
        self.totalMinutes = minutes
        self.shiftend.setTitle("Shift end: \((totalMinutes/60)%60)h:\(totalMinutes%60)m", for: .normal)
    }
}

extension ShiftViewController {
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

