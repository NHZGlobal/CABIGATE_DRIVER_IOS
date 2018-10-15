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

class VehicleList:Mappable {
    
    var vehicleid: String?
    var name: String?
    var number: String?
    var driver: String?
    var status: String?
    
    static var shared:Variable<[VehicleList]> = Variable([])

    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        self.vehicleid               <- map["vehicleid"]
        self.name               <- map["name"]
        self.number                  <- map["number"]
        self.driver                <- map["driver"]
        self.status            <- map["status"]
        
    }
}


