//
//  Extensions.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 01/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit
import RealmSwift

enum JobScreenType:Int {
    case queue = 0, offers, joboffer
}

public class DatabaseManager {
    static var realm: Realm {
        get {
            do {
                let realm = try Realm()
                return realm
            }
            catch {
                print("Could not access database: ", error)
            }
            return self.realm
        }
    }
}
enum ResponseStatus: Int {
    case incorrect = 0, correct
}
enum AwayTimes:Int {
    case thirtySeconds = 30, fourtyFiveSeconds = 45, tenMinutes = 600, fifteenMinutes = 900, thirtyMinutes = 1800 , oneHour = 3600
}

enum DriverStatus:Int {
    case available = 1, busy, away
}

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

extension UIColor {
    open class var cabigateThemeColor: UIColor{
        return UIColor(red: 112/255, green: 239.0/255, blue: 250.0/255, alpha: 1.0)
    }
    
    open class var freeVehicle: UIColor{
        return UIColor(red: 137/255, green: 191/255, blue: 69/255, alpha: 1.0)
    }
    
    open class var selectedTab: UIColor{
        return UIColor(white: 1, alpha: 1.0)
    }
    
    open class var unselectedTab: UIColor{
        return UIColor(white: 1, alpha: 0.4)
    }
    
    open class var availableColor: UIColor{
        return UIColor(red: 138/255, green: 183/255, blue: 56/255, alpha: 1.0)
    }
    
    open class var awayColor: UIColor{
        return UIColor(red: 240/255, green: 196/255, blue: 67/255, alpha: 1.0)
    }
    
    open class var busyColor: UIColor{
        return UIColor(red: 219/255, green: 129/255, blue: 98/255, alpha: 1.0)
    }
}

extension UIView {
    func addShadow(){
        self.layer.cornerRadius = 2.0
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: -1.0, height: 1.0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 1.0
        
        // caches shadow to improve the performance
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func makeRound () {
        self.layoutIfNeeded()
        self.layer.cornerRadius = self.bounds.size.width/2
        self.layer.masksToBounds = true
    }
    
    func addBorder(color: UIColor, width: CGFloat) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    
    func addDottedBorder() {
        
        let color = UIColor(red: 206/255, green: 207/255, blue: 208/255, alpha: 1.0).cgColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.cornerRadius = frameSize.width/2
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [8,5]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 0).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
    
}

extension UIViewController {
    func addBackground() {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height + 80
        let frame = CGRect(x: 0, y: -40, width: width, height: height)
        let imageViewBackground = UIImageView(frame: frame)
        imageViewBackground.contentMode = UIViewContentMode.scaleToFill
        imageViewBackground.image = #imageLiteral(resourceName: "backgroudImage")
        let shadowView = UIView(frame: frame)
        shadowView.backgroundColor = UIColor.black
        shadowView.alpha = 0.4
        imageViewBackground.addSubview(shadowView)
        self.view.addSubview(imageViewBackground)
        self.view.sendSubview(toBack: imageViewBackground)
    }
}

extension NSMutableAttributedString{
    func setColorForText(_ textToFind: String, with color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
        }
    }
}
