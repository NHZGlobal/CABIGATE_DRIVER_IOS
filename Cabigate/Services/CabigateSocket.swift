//
//  SocketServices.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 06/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import Foundation
import SocketIO
import SwiftyJSON
import ObjectMapper
import UIKit

class CabigateSocket {
    
    static let manager = SocketManager(socketURL: URL(string: "http://cabigate.com:3000")!, config: [.log(true), .compress])
    static let socket = CabigateSocket.manager.defaultSocket
    static var isConnected = false

  
    static func connect(userid: String, username: String, roomid: String) {
     //   if self.isConnected == false {
     //       self.isConnected = true
            socket.connect()
            CabigateSocket.socket.on(clientEvent: .connect) {data, ack in
                print("socket connected")
                CabigateSocket.socket.emit("senddata", ["user_id":"\(userid)","username":"\(username)","room_id":"\(roomid)"])
                self.isConnected = true
            }
        
        
            CabigateSocket.socket.on(clientEvent: .disconnect, callback: { (dack , ack ) in
                print("socket disconnect")
                self.isConnected = false
                
                if CabigateSocket.isConnected == false {
                    if let realmDriver = DatabaseManager.realm.objects(Driver.self).first {
                        CabigateSocket.connect(userid: realmDriver.userId!, username: realmDriver.username!, roomid: realmDriver.companyId!)
                    }
                }
               // socket.connect()
            })
    //    }
    }
    
}

