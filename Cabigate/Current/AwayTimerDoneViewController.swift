//
//  AwayTimerDoneViewController.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 02/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit

class AwayTimerDoneViewController: UIViewController {

    var delegate: AwayTimerDoneDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func didTapStillAway(_ sender: UIButton) {
        delegate?.selectedOption(stillAway: true, availableNow: false)
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func didTapAvailableNow(_ sender: UIButton) {
        delegate?.selectedOption(stillAway: false, availableNow: true)
        self.dismiss(animated: true, completion: nil)

    }

}


