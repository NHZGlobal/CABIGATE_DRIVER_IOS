//
//  CabLocationManager.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 16/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import Foundation
import CoreLocation
import NotificationCenter

class CabLocationManager: NSObject, CLLocationManagerDelegate {
    
    static var shared = CabLocationManager()
    
    let locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var traveledDistance: Double = 0
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    func startJob(){
        if startLocation == nil {
            startLocation = CabLocationManager.shared.locationManager.location
            traveledDistance = 0
        }
    }
    
    func stopJob(){
        startLocation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if CabigateSocket.isConnected == false {
            if let realmDriver = DatabaseManager.realm.objects(Driver.self).first {
                CabigateSocket.connect(userid: realmDriver.userId!, username: realmDriver.username!, roomid: realmDriver.companyId!)
            }
        }

        if let location = locations.last {
            if location.speed > 5 {
                

//                if let location = locations.first {
//                    if let realmDriver = DatabaseManager.realm.objects(Driver.self).first {
//                        
//                        CabigateSocket.socket.emit("updatelocation", ["lat":"\(location.coordinate.latitude)","lng":"\(location.coordinate.longitude)","speed":"\(location.speed)","username":realmDriver.username!,"user_id":realmDriver.userId!,"company_id":realmDriver.companyId!])
//                    }
//                }
            }
        }
        
        if startLocation != nil {
            if let location = locations.last {
                if location.speed > 1 {
                    if lastLocation == nil {  lastLocation = locations.first   }
                    traveledDistance += lastLocation.distance(from: location)
                    
//                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                    appDelegate.updateLocation(distance: traveledDistance)
                    
                }
            }
        }
        
        if let location = locations.last, location.horizontalAccuracy <= 20 {
            lastLocation = locations.last
        }
        print("Distance Traveled : \(traveledDistance)")
      
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        CabLocationManager.shared.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            print("1authorizedWhenInUse1")
        default:
            print("1denied1")
            CabLocationManager.shared.locationManager.requestWhenInUseAuthorization()
        }
    }
    
}
