//
//  UpdateLocationVC.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 02/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit

struct UpdateJobDetails {
    var jobid: String
    var userId: String
    var companyId: String
    var waypointNumber: Int?
    var lat: String?
    var lng: String?
    var location: String?
    var type: String
}

enum UpdateLocationType:Int {
    case pickup = 0, dropoff, waypoint
}

class UpdateLocationVC: UIViewController {

    @IBOutlet weak var deleteButton: UIButton!
    
    var delegate: UpdateLocationDelegate!
    var screenType: UpdateLocationType!
    var details: UpdateJobDetails!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if screenType == UpdateLocationType.pickup || screenType == UpdateLocationType.dropoff  {
            self.deleteButton.isHidden = true
        }
    }

    @IBAction func didTapDelete(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        delegate.delete(details: self.details)
    }
    
    @IBAction func didTapUpdate(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        delegate?.update(details: self.details)
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
