//
//  FarePaymentForJobVC.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 08/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit
import SwiftMoment

class FarePaymentForJobVC: UIViewController {

    @IBOutlet weak var taxiMeterTF: UITextField!
    @IBOutlet weak var client: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var payByLabel: UITextField!
    
    var delgate: FarePaymentForJobVCDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.taxiMeterTF.isUserInteractionEnabled = false
        if let driver = Driver.shared.value, let job = driver.jobDetails {
            
//            let now = moment(Date())
//            let validTime = moment(["year": now.year,
//                                    "second": now.second,
//                                    "month": now.month,
//                                    "minute": now.minute,
//                                    "hour": now.hour,
//                                    "day": now.day
//                ])!
//
//            let currentTime = validTime.second
//            let tillNow = currentTime - Mom

//            let sum = Driver.shared.value!.totalTime.reduce(0, +) //+ Double(tillNow)
            self.taxiMeterTF.text = job.fare
            self.payByLabel.text = "(\(job.payment_type!))"
            self.client.text = job.paxname
//            print("sum ", sum)
            print("totalTime ", Driver.shared.value!.totalTime)
            
            let date = NSDate(timeIntervalSinceNow: Driver.shared.value!.totalTime) // difference to now
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "hh:mm", options: 0, locale:     NSLocale.current)
            var traveledDistance: Double = 0.0
            if (CabLocationManager.shared.lastLocation != nil)
            {
            
               traveledDistance = CabLocationManager.shared.lastLocation.distance(from: CabLocationManager.shared.startLocation)
            
//
//                LMDistanceCalculator.sharedInstance().realDistance(fromOrigin: CabLocationManager.shared.startLocation.coordinate, destination: CabLocationManager.shared.lastLocation.coordinate) { (result, error) in
//
//
//                }
            
            }
//            self.time.text = job.duration
            self.time.text =  stringFromTimeInterval(interval: Driver.shared.value!.totalTime) as String

//            self.distance.text = String(format:"%.2f km",traveledDistance/1000)
            
            self.distance.text = String(format:"%.2f km",CabLocationManager.shared.traveledDistance/1000)

        }

    }
    
    func format(duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        
        return formatter.string(from: duration)!
    }
    
    
    
    func stringFromTimeInterval(interval: TimeInterval) -> NSString {
        
        let ti = NSInteger(interval)
        
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600) % 60
        
        return NSString(format: "%0.2d h : %0.2d min",hours,minutes)
    }


    @IBAction func didTapAdjust(_ sender: UIButton) {
        self.taxiMeterTF.isUserInteractionEnabled = true
        self.taxiMeterTF.becomeFirstResponder()
    }
    
    @IBAction func didTapNext(_ sender: UIButton) {
        Driver.shared.value!.jobDetails!.fare = self.taxiMeterTF.text!
        self.dismiss(animated: false, completion: nil)
        delgate!.next()
    }
}
