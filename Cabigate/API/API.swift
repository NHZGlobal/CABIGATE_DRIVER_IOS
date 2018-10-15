//
//  API.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 04/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import ObjectMapper
import RxSwift
import RealmSwift

class APIServices {
    
    static func Login(params: Parameters, callback: @escaping (_ error: String?) -> Void ) {
        Alamofire.request(Router.path(.login(parameters: params))).responseJSON { (response) in
            let json = JSON(response.data!)
            if  json["status"].int == ResponseStatus.correct.rawValue {
                let driver = Mapper<Driver>().map(JSON: json["response"].dictionaryObject!)
                Driver.shared.value = driver
                do {
                    try DatabaseManager.realm.write {
                        DatabaseManager.realm.deleteAll()
                        DatabaseManager.realm.add(driver!)
                    }
                }catch let error {
                    print(error.localizedDescription)
                }
                
                callback(nil)
            }else {
                callback(json["error_msg"].string)
            }
        }
    }
    
    static func Logout(params: Parameters, callback: @escaping (_ error: String?) -> Void ) {
        Alamofire.request(Router.path(.logout(parameters: params))).responseJSON { (response) in
            let json = JSON(response.data!)
            print(json)
            if  json["status"].int == ResponseStatus.correct.rawValue {
                callback(nil)
            }else {
                callback(json["error_msg"].string)
            }
        }
    }
    
    static func FetchVehicleList(params: Parameters, callback: @escaping (_ error: String?) -> Void ) {
        Alamofire.request(Router.path(.fetchvehicleList(parameters: params))).responseJSON { (response) in
            let json = JSON(response.data!)
            if  json["status"].int == ResponseStatus.correct.rawValue {
                let vehicles = Mapper<VehicleList>().mapArray(JSONObject: json["response"]["list"].arrayObject!)
                VehicleList.shared.value = vehicles!
                callback(nil)
            }else {
                callback(json["error_msg"].string)
            }
        }
    }
    
    static func ShiftInService(params: Parameters, callback: @escaping (_ error: String?) -> Void ) {
        Alamofire.request(Router.path(.shiftin(parameters: params))).responseJSON { (response) in
            let json = JSON(response.data!)
            if  json["status"].int == ResponseStatus.correct.rawValue {
                let obj = Mapper<ShiftIn>().map(JSON: json["response"].dictionaryObject!)
                print(obj?.jobdetails?.showdropoff ?? "")
                print(obj?.jobdetails?.isprice ?? "")
                ShiftIn.shared.value = obj!
                
                do {
                    try DatabaseManager.realm.write {
                        DatabaseManager.realm.add(obj!)
                    }
                }catch let error {
                    print(error.localizedDescription)
                }
                
                callback(nil)
            }else {
                callback(json["error_msg"].string)
            }
        }
    }
    
    static func ShiftOut(params: Parameters, callback: @escaping (_ error: String?) -> Void ) {
        Alamofire.request(Router.path(.shiftout(parameters: params))).responseJSON { (response) in
            let json = JSON(response.data!)
            print(json)
            if  json["status"].int == ResponseStatus.correct.rawValue {
                print(json["response"]["msg"] )
                callback(nil)
            }else {
                callback(json["error_msg"].string)
            }
        }
    }
    
    static func OpenJobsQueue(params: Parameters, callback: @escaping (_ error: String?) -> Void ) {
        
        Alamofire.request(Router.openjobsqueue(parameters: params).path).responseJSON { (response) in
            let json = JSON(response.data!)
            print("OpenJobsQueue Response \(json)")
            if  json["status"].int == ResponseStatus.correct.rawValue {
                let queueList = Mapper<Queue>().mapArray(JSONObject: json["response"]["list"].arrayObject!)
                Queue.shared.value = queueList!
                callback(nil)
            }else {
                Queue.shared.value = []
                callback(json["error_msg"].string)
            }
        }
    }
    
    static func Offers(params: Parameters, callback: @escaping (_ error: String?) -> Void ) {
        
        Alamofire.request(Router.path(.viewoffers(parameters: params))).responseJSON { (response) in
            let json = JSON(response.data!)
            if  json["status"].int == ResponseStatus.correct.rawValue {
                let offersList = Mapper<Offer>().mapArray(JSONObject: json["response"]["list"].arrayObject!)
                Offer.shared.value = offersList!
                callback(nil)
            }else {
                Offer.shared.value = []
                callback(json["error_msg"].string)
            }
        }
    }
    
    static func AcceptOffer(params: Parameters, callback: @escaping (_ error: String?) -> Void ) {
        Alamofire.request(Router.path(.acceptoffer(parameters: params))).responseJSON { (response) in
            let json = JSON(response.data!)
            print(json)
            if  json["status"].int == ResponseStatus.correct.rawValue {
                print(json["response"]["msg"] )

                callback(nil)
            }else {
                callback(json["error_msg"].string)
            }
        }
    }
    
    static func JobDetails(params: Parameters, callback: @escaping (_ error: String?) -> Void ) {
        Alamofire.request(Router.path(.jobdetails(parameters: params))).responseJSON { (response) in
            
            let json = JSON(response.data!)
            print(json)
            if  json["status"].int == ResponseStatus.correct.rawValue {
                let job = Mapper<ShowJob>().map(JSON: json["response"]["details"].dictionaryObject!)
                ShowJob.shared.value = job!
                callback(nil)
            }else {
                callback(json["error_msg"].string)
            }
        }
    }
    
    // update driver status to available, away or busy
    static func StatusUpdate(params: Parameters, callback: @escaping (_ error: String?) -> Void ) {
        Alamofire.request(Router.path(.statuspdate(parameters: params))).responseJSON { (response) in
            let json = JSON(response.data!)
            // print(json)
            if  json["status"].int == ResponseStatus.correct.rawValue {
                callback(nil)
            }else {
                callback(json["error_msg"].string)
            }
        }
    }
    
    static func LastState(params: Parameters, callback: @escaping (_ error: String?) -> Void ) {
        Alamofire.request(Router.path(.mylaststate(parameters: params))).responseJSON { (response) in
            
            let json = JSON(response.data!)
            //print("LastState : ", json)
            if  json["status"].int == ResponseStatus.correct.rawValue {
                let lastState = Mapper<Driver>().map(JSON: json["response"].dictionaryObject!)
                Driver.shared.value = lastState!
                Driver.shared.value!.last_status = lastState!.last_status
                Driver.shared.value!.last_shiftend_time = lastState!.last_shiftend_time
                callback(nil)
            }else {
                callback(json["error_msg"].string)
            }
        }
    }
    
    // update job status to callout, wait, or pob
    static func UpdateJobStatus(params: Parameters, callback: @escaping (_ error: String?) -> Void ) {
        
        Alamofire.request(Router.updatejobstatus(parameters: params).path).responseJSON { (response) in
            let json = JSON(response.data!)
            //    print(json)
            if  json["status"].int == ResponseStatus.correct.rawValue {
                callback(nil)
            }else {
                callback(json["error_msg"].string)
            }
        }
    }
    
    
    
    static func WaitingTimeForJob(params: Parameters, callback: @escaping (_ error: String?) -> Void ) {
        Alamofire.request(Router.path(.waitingtimeupdate(parameters: params))).responseJSON { (response) in
            let json = JSON(response.data!)
            print("UpdateWaitingTime : ", json)
            if  json["status"].int == ResponseStatus.correct.rawValue {
                callback(nil)
            }else {
                callback(json["error_msg"].string)
            }
        }
    }
    // deliver job
    static func DeliverJob(params: Parameters, callback: @escaping (_ error: String?,_ hasJob: Bool?) -> Void ) {
        
        Alamofire.request(Router.deliverjob(parameters: params).path).responseJSON { (response) in
            let json = JSON(response.data!)
            print("DeliverJob : ", json)
            if  json["status"].int == ResponseStatus.correct.rawValue {
                if json["response"]["jobdetails"].dictionaryObject != nil {
                    if let jobDict = json["response"]["jobdetails"].dictionaryObject, jobDict.count > 0 {
                        let job = Mapper<ShowJob>().map(JSON: json["response"]["jobdetails"].dictionaryObject!)
                        CabigateSocket.socket.emit("sendstatus", ["status": "1","jobid":job!.jobid,"room_id":job!.room_id, "to":job!.sender])
                        let driver = Driver.shared.value
                        driver!.jobDetails = job
                        Driver.shared.value = driver!
                        if let _ = job {
                            callback(nil, true)
                        }else {
                            callback(nil, false)
                        }
                    }else {
                        callback(nil, false)
                    }
                }else {
                    callback(nil, false)
                }
                
            }else {
                callback(json["error_msg"].string, false)
            }
        }
    }
    
    // cancel job
    static func CancelJob(params: Parameters, callback: @escaping (_ error: String?,_ hasJob: Bool?) -> Void ) {
        
        Alamofire.request(Router.canceljob(parameters: params).path).responseJSON { (response) in
            let json = JSON(response.data!)
            print("CancelJob", json)
            if  json["status"].int == ResponseStatus.correct.rawValue {
                if json["response"]["jobdetails"].dictionaryObject != nil {
                    if let jobDict = json["response"]["jobdetails"].dictionaryObject, jobDict.count > 0 {
                        let job = Mapper<ShowJob>().map(JSON: json["response"]["jobdetails"].dictionaryObject!)
                        CabigateSocket.socket.emit("sendstatus", ["status": "1","jobid":job!.jobid,"room_id":job!.room_id, "to":job!.sender])
                        let driver = Driver.shared.value
                        driver!.jobDetails = job
                        Driver.shared.value = driver!
                        if let _ = job {
                            callback(nil, true)
                        }else {
                            callback(nil, false)
                        }
                    }else {
                        callback(nil, false)
                    }
                }else {
                    callback(nil, false)
                }
                
            }else {
                callback(json["error_msg"].string, false)
            }
        }
    }
    
    static func UpdateJobDetails(params: Parameters, callback: @escaping (_ error: String?) -> Void ) {
        Alamofire.request(Router.path(.updatejobdetails(parameters: params))).responseJSON { (response) in
            let json = JSON(response.data!)
            print("UpdateJobDetails : ", json)
            if  json["status"].int == ResponseStatus.correct.rawValue {
                let job = Mapper<ShowJob>().map(JSON: json["response"]["jobdetails"].dictionaryObject!)
                let driver = Driver.shared.value
                driver!.jobDetails = job
                Driver.shared.value = driver!
                callback(nil)
            }else {
                callback(json["error_msg"].string)
            }
        }
    }
    
    static func UpdateDeviceToken(params: Parameters, callback: @escaping (_ error: String?) -> Void ) {
        Alamofire.request(Router.path(.devicetoken(parameters: params))).responseJSON { (response) in
            let json = JSON(response.data!)
            print("UpdateDeviceToken : ", json)
            if  json["status"].int == ResponseStatus.correct.rawValue {
                callback(nil)
            }else {
                callback(json["error_msg"].string)
            }
        }
    }
    
}
