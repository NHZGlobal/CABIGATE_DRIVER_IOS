import Foundation
import XLPagerTabStrip
import RxSwift
import GooglePlaces
import SwiftyJSON
import JSQMessagesViewController

protocol ChatNavigationDelegate {
    func pushToConversationViewController(_ channelID: String)
    func pushToOneToOneChatViewController(with memberID: String)
}

class JobMainViewController: BaseButtonBarPagerTabStripViewController<JobTabIconCell> , InternetStatusIndicable{
    
    var internetConnectionIndicator:InternetViewIndicator?

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var plusButton: UIBarButtonItem!
    let disposeBag = DisposeBag()
    var mainVC: MainViewController!
    

    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buttonBarItemSpec = ButtonBarItemSpec.nibFile(nibName: "JobTabIconCell", bundle: Bundle(for: JobTabIconCell.self), width: { _ in
            return self.view.frame.size.width/4 - 4
        })
    }
    
    override func viewDidLoad() {
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = .clear
        settings.style.selectedBarHeight = 0
        settings.style.buttonBarMinimumLineSpacing = 1
        
        self.startMonitoringInternet()
        
       
        
    
        
        CabigateSocket.socket.off("forcelogout")
        CabigateSocket.socket.on("forcelogout"){ data, ack in
            print("job main vcforce logout")
            try! DatabaseManager.realm.write {
                if let driver = DatabaseManager.realm.objects(Driver.self).first {
                    let params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!]
                    APIServices.Logout(params: params) { (error ) in
                        guard (error == nil) else {
                            return
                        }
                        
                        // update userdefaults
                        UserDefaults.standard.set(false, forKey: "isfcmTokenSent")
                        UserDefaults.standard.synchronize()
                        
                        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
                        delegate.window = UIWindow(frame: UIScreen.main.bounds)
                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "loginSID")
                        delegate.window?.rootViewController = vc
                        delegate.window?.makeKeyAndVisible()
                        
                        CabigateSocket.socket.disconnect()
                        // CabigateSocket.socket.removeAllHandlers()
                    }
                    DatabaseManager.realm.delete(DatabaseManager.realm.objects(Driver.self))
                }
            }

        }

        changeCurrentIndexProgressive = { [weak self] (oldCell: JobTabIconCell?, newCell: JobTabIconCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            
            guard changeCurrentIndex == true else { return }
            
            oldCell?.Titlelabel.textColor = UIColor.unselectedTab
            newCell?.Titlelabel.textColor = UIColor.selectedTab
            
            guard let old = oldCell, let new = newCell else {
                newCell?.bgView.alpha = 0.6
                return
            }
            
            old.bgView.alpha = 1.0
            if let oldIndexPath = self?.buttonBarView.indexPath(for: old) {
                switch oldIndexPath.item {
                case 0:
                    oldCell?.iconImage.image = #imageLiteral(resourceName: "currentUnselected")
                case 1:
                    oldCell?.iconImage.image = #imageLiteral(resourceName: "queueUnselected")
                case 2:
                    oldCell?.iconImage.image = #imageLiteral(resourceName: "offersUnselected")
                default:
                    oldCell?.iconImage.image = #imageLiteral(resourceName: "chatUnselected")
                }
            }
            
            new.bgView.alpha = 0.6
            if let newIndexPath = self?.buttonBarView.indexPath(for: new) {
                switch newIndexPath.item {
                case 0:
                    newCell?.iconImage.image = #imageLiteral(resourceName: "currentSelected")
                case 1:
                    newCell?.iconImage.image = #imageLiteral(resourceName: "queueSelected")
                case 2:
                    newCell?.iconImage.image = #imageLiteral(resourceName: "offerSelected")
                default:
                    newCell?.iconImage.image = #imageLiteral(resourceName: "chatSelected")
                    if Driver.shared.value != nil {
                        Driver.shared.value!.chatCount = 0
                        newCell?.iconImage.badgeView.text = "\(Driver.shared.value!.chatCount)"
                    }
                }
            }
        }
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "cabigateNavLogo"))
        
        Driver.shared.asObservable().subscribe { (driver) in
            guard let driver = Driver.shared.value else { return }
            if driver.jobDetails != nil {
                self.backButton.isEnabled = false
                self.navigationItem.rightBarButtonItem = self.plusButton
                self.moveToViewController(at: 0)
            }else {
                self.backButton.isEnabled = true
                self.navigationItem.rightBarButtonItem = nil
            }
            }.disposed(by: self.disposeBag)
    }
  
    
    @objc func locationUpdateNotification()  {
        
        let alertController = UIAlertController (title: "Need Location Access", message: "In Settings, You must allow access to your location for the cabigate driver app to work. We will only track your location when you are using the cabigate drivers app.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
        
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "LocationUpdate"), object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdateNotification), name: NSNotification.Name(rawValue: "LocationUpdate"), object: nil)
    }
    
    @IBAction func didTapPlus(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "goToSearchVC", sender: nil)
    }
    
    @IBAction func didTapBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let currentVC = storyboard.instantiateViewController(withIdentifier: "currentVC")
        let queueVC = storyboard.instantiateViewController(withIdentifier: "queueVC")
        let offerVC = storyboard.instantiateViewController(withIdentifier: "offerVC")
        let chatVC = storyboard.instantiateViewController(withIdentifier: "chatVC")
        
        return [currentVC, queueVC, offerVC , chatVC]
        
    }
    
    var chatOberserverCount:Int = 0
    
    override func configure(cell: JobTabIconCell, for indicatorInfo: IndicatorInfo) {
        cell.iconImage.image = indicatorInfo.image
        cell.Titlelabel.text = indicatorInfo.title
        
        cell.iconImage.showBadge(animated: true)
        cell.iconImage.badgeView.offsets = CGPoint(x: 25, y: 0)
        cell.iconImage.badgeView.style = AXBadgeViewStyle.number
        if cell.Titlelabel.text == "OFFERS" {
            cell.iconImage.badgeView.text = "0"
        }
        
        if cell.Titlelabel.text == "CHAT" {
            if let driver = Driver.shared.value {
                cell.iconImage.badgeView.text = "\(driver.chatCount)"
            }
        }
        
        if cell.Titlelabel.text == "OFFERS" {
            if let driver = Driver.shared.value {
                cell.iconImage.badgeView.text = driver.offersCount
            }
        }
        
        Offer.shared.asObservable().subscribe { (messages) in
            if cell.Titlelabel.text == "OFFERS" {
                cell.iconImage.badgeView.text = "\(Offer.shared.value.count)"
            }
            }.disposed(by: self.disposeBag)
        
        Driver.messages.asObservable().subscribe { (messages) in
            if cell.Titlelabel.text == "CHAT" {
                if let driver = Driver.shared.value {
                    cell.iconImage.badgeView.text = "\(driver.chatCount)"
                }
            }
            }.disposed(by: self.disposeBag)
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
        //self.searchButton.image = toIndex == 2 ? #imageLiteral(resourceName: "FilterReportIcon") : #imageLiteral(resourceName: "Search")
    }
    
}






