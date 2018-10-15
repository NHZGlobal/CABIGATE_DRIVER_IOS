//
//  ShowJob.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 06/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit
import RxSwift
import ObjectMapper
import RealmSwift
import ObjectMapper_RealmSwift

class ShowJob:Object, Mappable {
    
    var jobid: String?
    var pickup_lat: String?
    var pickup_lng: String?
    var drop_lat: String?
    var drop_lng: String?
    var distance: String?
    var fare: String?
    var tariff: String?
    var duration: String?
    var passengers: String?
    var bags: String?
    var wheelchairs: String?
    var paxrid: String?
    var paxname: String?
    var paxtel: String?
    var paxemail: String?
    var when: String?
    var dropoff: String?
    var journey_type: String?
    var stop_count: String?
    var vehicle_type: String?
    var notes: String?
    var isprice: Bool?
    var showdropoff: Bool?
    var pickup: String?
    var pickupdistance: String?
    var pickuptime: String?
    var refrence: String?
    var sender: String?
    var room_id: String?
    var to: String?
    var payment_type: String?
    var dispatcher: String?
    var status: String?
    var waypoints:[WayPoints]?
    var stop1: String?
    var stop1_lat: Bool?
    var stop1_lng: Bool?
    var stop2: String?
    var stop2_lat: String?
    var stop2_lng: String?
    var stop3: String?
    var stop3_lat: String?
    var stop3_lng: String?
    var stop4: String?
    var stop4_lat: String?
    var stop4_lng: String?
    var stop5: String?
    var stop5_lat: String?
    var stop5_lng: String?
    
    static var shared:Variable<ShowJob?> = Variable(nil)
    
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
        self.pickup               <- map["pickup"]
        self.pickupdistance               <- map["pickupdistance"]
        self.dropoff               <- map["dropoff"]
        self.journey_type             <- map["journey_type"]
        self.stop_count             <- map["stop_count"]
        self.vehicle_type                   <- map["vehicle_type"]
        self.paxemail                  <- map["paxemail"]
        self.pickuptime                     <- map["pickuptime"]
        self.refrence             <- map["refrence"]
        self.notes                <- map["notes"]
        self.isprice                   <- map["isprice"]
        self.showdropoff                   <- map["showdropoff"]
        self.sender                   <- map["sender"]
        self.room_id                   <- map["room_id"]
        self.to                   <- map["to"]
        self.payment_type                   <- map["payment_type"]
        self.dispatcher                   <- map["dispatcher"]
        self.status                   <- map["status"]
        self.waypoints                   <- map["waypoints"]
        self.stop1               <- map["stop1"]
        self.stop1_lat               <- map["stop1_lat"]
        self.stop1_lng             <- map["stop1_lng"]
        self.stop2               <- map["stop2"]
        self.stop2_lat               <- map["stop2_lat"]
        self.stop2_lng             <- map["stop2_lng"]
        self.stop3               <- map["stop3"]
        self.stop3_lat               <- map["stop3_lat"]
        self.stop3_lng             <- map["stop3_lat"]
        self.stop4               <- map["stop4"]
        self.stop4_lat               <- map["stop4_lat"]
        self.stop4_lng             <- map["stop4_lat"]
        self.stop5               <- map["stop5"]
        self.stop5_lat               <- map["stop5_lat"]
        self.stop5_lng             <- map["stop5_lat"]

    }
    
}





