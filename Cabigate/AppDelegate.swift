    //
//  AppDelegate.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 01/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit
import RealmSwift
import GooglePlaces
import IQKeyboardManagerSwift
import Firebase
import UserNotifications
import SwiftyJSON
import ObjectMapper
import Presentr
    import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var connectTimer: Timer!
    var label:UILabel!
    let reachability = Reachability()!
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        CabLocationManager.shared.locationManager.startUpdatingLocation()
        // firebase configuration
        FirebaseApp.configure()
        
        // firebase push notification configuration
       // Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        
        UIApplication.shared.applicationIconBadgeNumber =  0
        
        UIApplication.shared.isIdleTimerDisabled = true

        
        GMSPlacesClient.provideAPIKey("AIzaSyBDjAWbd_bLWtJz33GW0s8-SoU5UIcSFdk")
        
        _ = JobMainViewController(nibName: nil, bundle: nil)
        IQKeyboardManager.sharedManager().enable = true
        
        connectTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        connectTimer.fire()
        
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .badge, .sound])  { (granted, error) in
                // Enable or disable features based on authorization.
            }
        } else {
            // REGISTER FOR PUSH NOTIFICATIONS
            let notifTypes:UIUserNotificationType  = [.alert, .badge, .sound]
            let settings = UIUserNotificationSettings(types: notifTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            application.applicationIconBadgeNumber = 0
            
        }
        
        
        if let _ = DatabaseManager.realm.objects(Driver.self).last {
            self.permissionForNotification()
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "mainSID")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        if launchOptions != nil {
            CabLocationManager.shared = CabLocationManager()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        return true
    }
    
    func showNotifications( message: NSString) {
        
        return
        
        let state = UIApplication.shared.applicationState
        if state == .background {
            let content = UNMutableNotificationContent()
            content.title = "Connection"
            content.body = message as String
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
            let request = UNNotificationRequest(identifier: "timerdone", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }

    }
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            print("============  Reachable via WiFi ===============")
            showNotifications(message: "Reachable via WiFi")
            self.establishConnection()
        case .cellular:
            print(" ============== Reachable via Cellular =============")
            showNotifications(message: "Reachable via Cellular")

            self.establishConnection()
        case .none:
            print(" ============== Network not reachabl ================e")
            showNotifications(message: "Network not reachable")

        }
    }
    
    func establishConnection()
    {
        if let realmDriver = DatabaseManager.realm.objects(Driver.self).first
        {
            CabigateSocket.socket.on(clientEvent: .connect) {data, ack in
                print("socket connected")
                CabigateSocket.socket.emit("senddata", ["user_id":"\(realmDriver.userId!)","username":"\(realmDriver.username!)","room_id":"\(realmDriver.companyId!)"])
                self.showNotifications(message: "socket connected")
            }
            
        }
    }
    
    @objc func runTimedCode()
    {
        
        if let realmDriver = DatabaseManager.realm.objects(Driver.self).first
        {
//            print(" ================= Timer Running ================= ")
            if CabigateSocket.isConnected == false  {
//                print(" ================= Reconnecting... ================= ")
               CabigateSocket.connect(userid: realmDriver.userId!, username: realmDriver.username!, roomid: realmDriver.companyId!)
            }
        }
}
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
           
        default:
            print("denied")
            
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LocationUpdate"), object: nil)
            
        }
        
        
    }
    func applicationWillTerminate(_ application: UIApplication) {
        CabLocationManager.shared = CabLocationManager()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber =  0
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("Application State: \(UIApplication.shared.applicationState)")
        print("a")
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("b")
        print(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Messaging.messaging().apnsToken = deviceToken
//        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
//        print("device token : \(token)")
//        self.updateFCMToken()
    }
    
    func updateLocation(distance: Double)
    {
        
        if(label == nil){
        label = UILabel(frame: CGRect(x: 10, y: 30, width: (self.window?.frame.size.width)!, height: 100))
        label.text = "00"
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.backgroundColor = UIColor.white
        label.textAlignment = .center
        label.textColor = UIColor.black
        self.window?.addSubview(label)
        }
        
        label.text = "\(distance)"
        
    }
    
    
    func updateFCMToken(){
        
//        print("is registered for remote notification : \(UIApplication.shared.isRegisteredForRemoteNotifications)")
//        let fcmToken = Messaging.messaging().fcmToken
//
//        if (UserDefaults.standard.value(forKey: "isfcmTokenSent") as? Bool) == nil {
//            UserDefaults.standard.set(false, forKey: "isfcmTokenSent")
//        }
//        if let isSent = UserDefaults.standard.value(forKey: "isfcmTokenSent") as? Bool, isSent == false, fcmToken != nil  {
//            print("token sending logic will goes here")
//            if let driver = DatabaseManager.realm.objects(Driver.self).first {
//                let parameters: [String : Any] = [
//                    "userid":driver.userId!,
//                    "companyid":driver.companyId!,
//                    "device_token":fcmToken!
//                ]
//
//                APIServices.UpdateDeviceToken(params: parameters, callback: { (error) in
//                    guard (error == nil) else { return }
//                    UserDefaults.standard.set(true, forKey: "isfcmTokenSent")
//                    UserDefaults.standard.synchronize()
//                })
//            }
//        }
        
    }
    
    func customappearance() {
        let myImage = #imageLiteral(resourceName: "BackNavIcon")
        let backButtonImage: UIImage? = myImage.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = backButtonImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backButtonImage
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-400.0, 0), for: .default)
    }
    
    func permissionForNotification() {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let userInfo = notification.request.content.userInfo
//        print("Application State: \(UIApplication.shared.applicationState.rawValue)")
//        print("c")
       // print(userInfo)
        
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        let userInfo = response.notification.request.content.userInfo
//        print("Application State: \(UIApplication.shared.applicationState.rawValue)")
//        print("d")
//        print(userInfo)
//        if UIApplication.shared.applicationState.rawValue != 0 {
//            let json = JSON(userInfo)
//           // print(json)
//            if json["notification_type"].string == "newjob"{
//                let jobObj = Mapper<ShowJob>().map(JSON: json.dictionaryObject!)
//                //    let driverObj = Driver.shared.value
//
//                let presenter:Presentr = {
//                    let width = ModalSize.custom(size: Float(UIScreen.main.bounds.width - 60))
//                    let height = ModalSize.custom(size: 450)
//                    let center = ModalCenterPosition.customOrigin(origin: CGPoint.init(x: 30, y: UIScreen.main.bounds.midY - 180))
//                    let customType = PresentationType.custom(width: width, height: height, center: center)
//
//                    let customPresenter = Presentr(presentationType: customType)
//                    customPresenter.transitionType = TransitionType.crossDissolve
//                    customPresenter.dismissTransitionType = TransitionType.crossDissolve
//                    customPresenter.backgroundOpacity = 0.3
//                    customPresenter.dismissAnimated = true
//                    return customPresenter
//                }()
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let vc = storyboard.instantiateViewController(withIdentifier: "jobdetailvcSID") as! JobDetailViewController
//
//                vc.screenType = JobScreenType.joboffer
//                vc.joboffer = jobObj
//
//                if var topController = UIApplication.shared.keyWindow?.rootViewController {
//                    while let presentedViewController = topController.presentedViewController {
//                        topController = presentedViewController
//                    }
//                    vc.delgate = topController as? JobDetailVCResponse
//                    if let _ = topController as? JobDetailViewController { return }
//                    topController.customPresentViewController(presenter, viewController: vc, animated: true, completion: nil)
//                }
//            }
//        }
        completionHandler()
    }
}

//extension AppDelegate : MessagingDelegate {
//
//    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
//        print("Firebase registration token: \(fcmToken)")
//        self.updateFCMToken()
//    }
//
//    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
//        print("Received data message: \(remoteMessage.appData)")
//    }
//}


