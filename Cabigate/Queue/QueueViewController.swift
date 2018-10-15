//
//  QueueViewController.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 01/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Presentr
import MBProgressHUD

class QueueViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var queueList = [Queue]()
    
    var hud = MBProgressHUD()
    
    var presenter: Presentr!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addBackground()
        UIApplication.shared.statusBarView?.backgroundColor = .white
        
        if let driver = DatabaseManager.realm.objects(Driver.self).first {
            let params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!]
            APIServices.OpenJobsQueue(params: params) { (error) in
//                guard (error == nil) else {
//                    self.hideHud(title: "Error", desc: error!)
//                    return
//                }
                self.hud.hide(animated: true)
                self.queueList = Queue.shared.value
                self.tableView.reloadData()
            }
        }

    }
    
    @IBAction func didTapZoneCheckin(_ sender: UIButton) {
        self.presenter = {
            let width = ModalSize.custom(size: Float(self.view.frame.size.width - 60))
            let height = ModalSize.custom(size: 510)
            let center = ModalCenterPosition.customOrigin(origin: CGPoint.init(x: 30, y: self.view.frame.midY - 180))
            let customType = PresentationType.custom(width: width, height: height, center: center)
            
            let customPresenter = Presentr(presentationType: customType)
            customPresenter.transitionType = TransitionType.crossDissolve
            customPresenter.dismissTransitionType = TransitionType.crossDissolve
            customPresenter.backgroundOpacity = 0.3
            customPresenter.dismissAnimated = true
            return customPresenter
        }()
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "selectzoneSID")
        self.customPresentViewController(self.presenter, viewController: vc, animated: true, completion: nil)
        
    }
    
    @IBAction func didTapMyZoneQueue(_ sender: UIButton) {
        
    }
    
}

extension QueueViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "QUEUE", image: #imageLiteral(resourceName: "queueUnselected"))
    }
}

extension QueueViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.queueList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell") as! QueueCell
        let queue = self.queueList[indexPath.row]
        cell.when.text = queue.when
        cell.pickup.text = queue.pickup
        cell.dropoff.text = queue.dropoff
        cell.duration.text = queue.duration
        cell.fare.text = "\(queue.fare!) GBP"
        cell.vehicleType.text = queue.vehicle_type
        cell.notes.text = queue.notes
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter = {
            let width = ModalSize.custom(size: Float(self.view.frame.size.width - 60))
            let height = ModalSize.custom(size: 440)
            let center = ModalCenterPosition.customOrigin(origin: CGPoint.init(x: 30, y: self.view.frame.midY - 120))
            let customType = PresentationType.custom(width: width, height: height, center: center)
            
            let customPresenter = Presentr(presentationType: customType)
            customPresenter.transitionType = TransitionType.crossDissolve
            customPresenter.dismissTransitionType = TransitionType.crossDissolve
            customPresenter.backgroundOpacity = 0.3
            customPresenter.dismissAnimated = true
            return customPresenter
        }()
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "jobdetailvcSID") as? JobDetailViewController
        vc?.screenType = JobScreenType.queue
        vc?.queue = self.queueList[indexPath.row]
        self.presenter.dismissOnTap = false
        self.customPresentViewController(self.presenter, viewController: vc!, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension QueueViewController {
    func showHud(){
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
    }
    
    func hideHud(title:String, desc: String){
        DispatchQueue.main.async {
            self.hud.mode = MBProgressHUDMode.text
            self.hud.label.text = title
            self.hud.detailsLabel.text = desc
            self.hud.hide(animated: true, afterDelay: 2.0)
        }
    }
}

