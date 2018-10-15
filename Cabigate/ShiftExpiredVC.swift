//
//  ShiftExpiredVC.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 18/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit

class ShiftExpiredVC: UIViewController {

    var delegate: ShiftExpiredVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func didTapShiftEnd(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        delegate.continueShift()
    }
    
    @IBAction func didTapContinue(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        delegate.continueShift()
    }

}
