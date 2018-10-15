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


class ShiftIn:Object, Mappable {
    
    @objc dynamic var  next_active_job: String?
    @objc dynamic var  jobdetails: JobDetails?
    @objc dynamic var  offerscount: String?
    @objc dynamic var  msg: String?
    
    static var shared:Variable<ShiftIn?> = Variable(nil)

    required convenience init?(map: Map) {
        self.init()
    }

    // Mappable
    func mapping(map: Map) {
        self.next_active_job               <- map["next_active_job"]
        self.jobdetails                    <- map["jobdetails"]
        self.offerscount                   <- map["offerscount"]
        self.msg                           <- map["msg"]
    }
}

class JobDetails:Object, Mappable {
    
    @objc dynamic var  jobid: String?
    @objc dynamic var  pickup_lat: String?
    @objc dynamic var  pickup_lng: String?
    @objc dynamic var  drop_lat: String?
    @objc dynamic var  drop_lng: String?
    @objc dynamic var  distance: String?
    @objc dynamic var  fare: String?
    @objc dynamic var  tariff: String?
    @objc dynamic var  duration: String?
    @objc dynamic var  passengers: String?
    @objc dynamic var  bags: String?
    @objc dynamic var  wheelchairs: String?
    @objc dynamic var  paxrid: String?
    @objc dynamic var  paxname: String?
    @objc dynamic var  paxtel: String?
    @objc dynamic var  paxemail: String?
    @objc dynamic var  when: String?
    @objc dynamic var  pickuptime: String?
    @objc dynamic var  pickupdistance: String?
    @objc dynamic var  pickup: String?
    @objc dynamic var  dropoff: String?
    @objc dynamic var  journey_type: String?
    @objc dynamic var  stop_count: String?
    var waypoints = List<WayPoints>()
    @objc dynamic var  payment_type: String?
    @objc dynamic var  vehicle_type: String?
    var  timer: Int?
    @objc dynamic var  to: String?
    @objc dynamic var  room_id: String?
    @objc dynamic var  company_id: String?
    var  sender: Int?
    @objc dynamic var  dispatcher: String?
    @objc dynamic var  status: String?
    @objc dynamic var  refrence: String?
    @objc dynamic var  notes: String?
    var  isprice: Bool?
    var  showdropoff: Bool?
    
    required convenience init?(map: Map) {
        self.init()
    }

    // Mappable
    func mapping(map: Map) {
        self.jobid                  <- map["jobid"]
        self.pickup_lat               <- map["pickup_lat"]
        self.pickup_lng                  <- map["pickup_lng"]
        self.drop_lat                <- map["drop_lat"]
        self.drop_lng             <- map["drop_lng"]
        self.distance               <- map["distance"]
        self.fare                <- map["fare"]
        self.tariff              <- map["tariff"]
        self.duration             <- map["duration"]
        self.passengers             <- map["passengers"]
        self.bags                 <- map["bags"]
        self.wheelchairs         <- map["wheelchairs"]
        self.paxrid                   <- map["paxrid"]
        self.paxname               <- map["paxname"]
        self.paxtel               <- map["paxtel"]
        self.paxemail                  <- map["paxemail"]
        self.when                <- map["when"]
        self.pickuptime            <- map["pickuptime"]
        self.pickupdistance              <- map["pickupdistance"]
        self.pickup               <- map["pickup"]
        self.dropoff               <- map["dropoff"]
        self.journey_type             <- map["journey_type"]
        self.stop_count             <- map["stop_count"]
        self.waypoints               <- map["waypoints"]
        self.payment_type         <- map["payment_type"]
        self.vehicle_type                   <- map["vehicle_type"]
        self.paxemail                  <- map["paxemail"]
        self.timer                <- map["timer"]
        self.to                      <- map["to"]
        self.room_id              <- map["room_id"]
        self.company_id              <- map["company_id"]
        self.sender               <- map["sender"]
        self.dispatcher             <- map["dispatcher"]
        self.status                     <- map["status"]
        self.refrence             <- map["refrence"]
        self.notes                <- map["notes"]
        self.isprice                   <- map["isprice"]
        self.showdropoff                   <- map["showdropoff"]
        
    }
    
}


