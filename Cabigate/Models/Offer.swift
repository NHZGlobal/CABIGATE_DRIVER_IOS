//
//  Queue.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 05/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit
import RxSwift
import ObjectMapper
import RealmSwift
import ObjectMapper_RealmSwift

class Offer:Object, Mappable {
    
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
    var pickup: String?
    var dropoff: String?
    var journey_type: String?
    var stop_count: String?
    var vehicle_type: String?
    var status: String?
    var refrence: String?
    var notes: String?
    var  isprice: Bool?
    var  showdropoff: Bool?
    var pickup_date: String?
    
    static var shared:Variable<[Offer]> = Variable([Offer]())
    
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
        self.pickup_date               <- map["pickup_date"]
        self.dropoff               <- map["dropoff"]
        self.journey_type             <- map["journey_type"]
        self.stop_count             <- map["stop_count"]
        self.vehicle_type                   <- map["vehicle_type"]
        self.paxemail                  <- map["paxemail"]
        self.status                     <- map["status"]
        self.refrence             <- map["refrence"]
        self.notes                <- map["notes"]
        self.isprice                   <- map["isprice"]
        self.showdropoff                   <- map["showdropoff"]
        
    }
    
}




