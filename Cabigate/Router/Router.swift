//
//  Router.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 04/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import Alamofire
import SwiftyJSON

enum Router: URLRequestConvertible{
    
    case login(parameters: Parameters)
    case logout(parameters: Parameters)
    case fetchvehicleList(parameters: Parameters)
    case shiftin(parameters: Parameters)
    case shiftout(parameters: Parameters)
    case zonelist(parameters: Parameters)
    case zonecheckin(parameters: Parameters)
    case zonecheckout(parameters: Parameters)
    case viewoffers(parameters: Parameters)
    case openjobsqueue(parameters: Parameters)
    case acceptoffer(parameters: Parameters)
    case jobdetails(parameters: Parameters)
    case statuspdate(parameters: Parameters)
    case mylaststate(parameters: Parameters)
    case updatejobstatus(parameters: Parameters)
    case deliverjob(parameters: Parameters)
    case canceljob(parameters: Parameters)
    case updatejobdetails(parameters: Parameters)
    case devicetoken(parameters: Parameters)
    case waitingtimeupdate(parameters: Parameters)


    static let baseURLString = "http://api.cabigate.com/index.php"
    
    var method: HTTPMethod
    {
        switch self {
        case .login:
            return .post
        case .logout:
            return .post
        case .fetchvehicleList:
            return .post
        case .shiftin:
            return .post
        case .shiftout:
            return .post
        case .zonelist:
            return .post
        case .zonecheckin:
            return .post
        case .zonecheckout:
            return .post
        case .viewoffers:
            return .post
        case .openjobsqueue:
            return .get
        case .acceptoffer:
            return .post
        case .jobdetails:
            return .post
        case .statuspdate:
            return .post
        case .mylaststate:
            return .post
        case .updatejobstatus:
            return .get
        case .deliverjob:
            return .get
        case .canceljob:
            return .get
        case .updatejobdetails:
            return .post
        case .devicetoken:
            return .post
        case .waitingtimeupdate:
            return .post
            
        }
    }
    
    var path: String
    {
        switch self {
        case .login:
            return "/login"
        case .logout:
            return "/logout"
        case .fetchvehicleList:
            return "/vehiclelist"
        case .shiftin:
            return "/shiftin"
        case .shiftout:
            return "/shiftout"
        case .zonelist:
            return "/zonelist"
        case .zonecheckin:
            return "/zonecheckin"
        case .zonecheckout:
            return "/zonecheckout"
        case .viewoffers:
            return "/offers"
        case .openjobsqueue(let params):
            return "\(Router.baseURLString)/openjobsque?companyid=\(params["companyid"]!)&userid=\(params["userid"]!)&token=\(params["token"]!)"
        case .acceptoffer:
            return "/acceptoffer"
        case .jobdetails:
            return "/jobdetails"
        case .statuspdate:
            return "/statuspdate"
        case .mylaststate:
            return "/mylaststate"
        case .updatejobstatus(let params):
            return "\(Router.baseURLString)/updatestatus?companyid=\(params["companyid"]!)&userid=\(params["userid"]!)&token=\(params["token"]!)&jobid=\(params["jobid"]!)&status=\(params["status"]!)"
        case .deliverjob(let params):
            return "\(Router.baseURLString)/deliverjob?companyid=\(params["companyid"]!)&userid=\(params["userid"]!)&token=\(params["token"]!)&jobid=\(params["jobid"]!)&comment=\(params["comment"]!)&rating=\(params["rating"]!)&fare=\(params["fare"]!)&pay_via=\(params["pay_via"]!)"
        case .canceljob(let params):
            return "\(Router.baseURLString)/canceljob?companyid=\(params["companyid"]!)&userid=\(params["userid"]!)&token=\(params["token"]!)&jobid=\(params["jobid"]!)&reason=\(params["reason"]!)"
        case .updatejobdetails:
            return "/updatejobdetails"
        case .devicetoken:
            return "/devicetoken"

        case .waitingtimeupdate:
            return "/actualfare"
        }
    }
    
    internal func asURLRequest() -> URLRequest {
        
        let url = try! Router.baseURLString.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = ["Content-Type": "application/x-www-form-urlencoded"]
        
        switch self {
        case .login(let parameters):
            let params = JSON(parameters).rawString()!.utf8
            urlRequest = try! URLEncoding.default.encode(urlRequest, with: ["data":params])
        case .logout(let parameters):
            let params = JSON(parameters).rawString()!.utf8
            urlRequest = try! URLEncoding.default.encode(urlRequest, with: ["data":params])
        case .fetchvehicleList(let parameters):
            let params = JSON(parameters).rawString()!.utf8
            urlRequest = try! URLEncoding.default.encode(urlRequest, with: ["data":params])
        case .shiftin(let parameters):
            let params = JSON(parameters).rawString()!.utf8
            urlRequest = try! URLEncoding.default.encode(urlRequest, with: ["data":params])
        case .shiftout(let parameters):
            let params = JSON(parameters).rawString()!.utf8
            urlRequest = try! URLEncoding.default.encode(urlRequest, with: ["data":params])
        case .zonelist(let parameters):
            let params = JSON(parameters).rawString()!.utf8
            urlRequest = try! URLEncoding.default.encode(urlRequest, with: ["data":params])
        case .zonecheckin(let parameters):
            let params = JSON(parameters).rawString()!.utf8
            urlRequest = try! URLEncoding.default.encode(urlRequest, with: ["data":params])
        case .zonecheckout(let parameters):
            let params = JSON(parameters).rawString()!.utf8
            urlRequest = try! URLEncoding.default.encode(urlRequest, with: ["data":params])
        case .viewoffers(let parameters):
            let params = JSON(parameters).rawString()!.utf8
            urlRequest = try! URLEncoding.default.encode(urlRequest, with: ["data":params])
        case .acceptoffer(let parameters):
            let params = JSON(parameters).rawString()!.utf8
            urlRequest = try! URLEncoding.default.encode(urlRequest, with: ["data":params])
        case .jobdetails(let parameters):
            let params = JSON(parameters).rawString()!.utf8
            urlRequest = try! URLEncoding.default.encode(urlRequest, with: ["data":params])
        case .statuspdate(let parameters):
            let params = JSON(parameters).rawString()!.utf8
            urlRequest = try! URLEncoding.default.encode(urlRequest, with: ["data":params])
        case .mylaststate(let parameters):
            let params = JSON(parameters).rawString()!.utf8
            urlRequest = try! URLEncoding.default.encode(urlRequest, with: ["data":params])
        case .updatejobdetails(let parameters):
            let params = JSON(parameters).rawString()!.utf8
            urlRequest = try! URLEncoding.default.encode(urlRequest, with: ["data":params])
        case .devicetoken(let parameters):
            let params = JSON(parameters).rawString()!.utf8
            urlRequest = try! URLEncoding.default.encode(urlRequest, with: ["data":params])
        case .waitingtimeupdate(let parameters):
            let params = JSON(parameters).rawString()!.utf8
            urlRequest = try! URLEncoding.default.encode(urlRequest, with: ["data":params])
        default :
            break
        }
        
        return urlRequest
    }
    
    static func path(_ url: Router) -> URLRequest {
        return url.asURLRequest()
    }
}

