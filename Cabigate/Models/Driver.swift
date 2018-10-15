//
//  Driver.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 04/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit
import RxSwift
import ObjectMapper
import RealmSwift
import ObjectMapper_RealmSwift
import JSQMessagesViewController

class Driver:Object, Mappable {
    
    @objc dynamic var socketURL: String?
    @objc dynamic var companyId: String?
    @objc dynamic var userId: String?
    @objc dynamic var username: String?
    @objc dynamic var driver_image: String?
    @objc dynamic var job_active: String?
    @objc dynamic var last_jobid: String?
    @objc dynamic var last_vehicleid: String?
    @objc dynamic var last_zoneid: String?
    var last_status = String()
    var last_shiftend_time = RealmOptional<Int>()
    @objc dynamic var show_dispatcher: String?
    @objc dynamic var token: String?
    var jobDetails: ShowJob?
    var chatCount: Int = 0
    var offersCount: String = "0"
    var shouldGoToNextIndex = false
    var totalTime:Double = 0
    var startTime:Double = 0
    var stopTime: Double = 0
    
    var waitingTotalTime:Double = 0
    var waitingStartTime:Double = 0
    var waitingStopTime: Double = 0

    static var messages: Variable<[JSQMessage]> = Variable([JSQMessage]())
    
    static var shared:Variable<Driver?> = Variable(nil)

    required convenience init?(map: Map) {
        self.init()
    }

    // Mappable
    func mapping(map: Map) {
        self.socketURL               <- map["SOCKETURL"]
        self.companyId               <- map["CompanyID"]
        self.userId                  <- map["Userid"]
        self.username                <- map["Username"]
        self.driver_image            <- map["driver_image"]
        self.job_active              <- map["job_active"]
        self.last_jobid              <- map["last_jobid"]
        self.last_vehicleid          <- map["last_vehicleid"]
        self.last_zoneid             <- map["last_zoneid"]
        self.last_status             <- map["last_status"]
        self.last_shiftend_time      <- map["last_shiftend_time"]
        self.show_dispatcher         <- map["show_dispatcher"]
        self.token                   <- map["token"]
        self.jobDetails              <- map["details"]
    }
    
}

