//
//  OffersViewController.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 01/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Presentr
import RxSwift

protocol OfferVCDelegate  {
    func accepted()
}

class OffersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var presenter: Presentr!
    var vc = JobDetailViewController()
    
    var offersList = [Offer]()
    
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter = {
            let width = ModalSize.custom(size: Float(self.view.frame.size.width - 60))
            let height = ModalSize.custom(size: 450)
            let center = ModalCenterPosition.customOrigin(origin: CGPoint.init(x: 30, y: self.view.frame.midY - 180))
            let customType = PresentationType.custom(width: width, height: height, center: center)
            
            let customPresenter = Presentr(presentationType: customType)
            customPresenter.transitionType = TransitionType.crossDissolve
            customPresenter.dismissTransitionType = TransitionType.crossDissolve
            customPresenter.backgroundOpacity = 0.3
            customPresenter.dismissAnimated = true
            return customPresenter
        }()
        self.presenter.dismissOnTap = false
        self.vc.offersDelegate = self
        self.vc = self.storyboard!.instantiateViewController(withIdentifier: "jobdetailvcSID") as! JobDetailViewController
        
        Offer.shared.asObservable().subscribe { (messages) in
            self.offersList = Offer.shared.value
            self.tableView.reloadData()
            
            }.disposed(by: self.disposeBag)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addBackground()
        UIApplication.shared.statusBarView?.backgroundColor = .white
        
        
        if let driver = DatabaseManager.realm.objects(Driver.self).first {
            let params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!]
            APIServices.Offers(params: params) { (error) in }
        }
    }
}

extension OffersViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "OFFERS", image:#imageLiteral(resourceName: "offersUnselected"))
    }
}

extension OffersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.offersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "offerscell") as! OffersCell
        let offer = self.offersList[indexPath.row]
        cell.pickupDate.text = offer.pickup_date
        cell.pickup.text = offer.pickup
        cell.dropoff.text = offer.dropoff
        cell.duration.text = offer.duration
        cell.fare.text = "\(offer.fare!) GBP"
        cell.vehicleType.text = offer.vehicle_type
        cell.notes.text = offer.notes
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.vc.screenType = JobScreenType.offers
        self.vc.offer = self.offersList[indexPath.row]
        self.customPresentViewController(self.presenter, viewController: vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension OffersViewController: OfferVCDelegate {
    func accepted() {
        print("offer accepted delegate")
        if let driver = DatabaseManager.realm.objects(Driver.self).first {
            let params = ["companyid":driver.companyId!,"userid":driver.userId!, "token":driver.token!]
            APIServices.Offers(params: params) { (error) in
                guard (error == nil) else {
                    //  self.hideHud(title: "Error", desc: error!)
                    return
                }
                // self.hud.hide(animated: true)
                self.offersList = Offer.shared.value
                self.tableView.reloadData()
            }
        }
    }
}



