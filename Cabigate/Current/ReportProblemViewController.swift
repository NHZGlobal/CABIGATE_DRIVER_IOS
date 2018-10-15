//
//  ReportProblemViewController.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 02/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit

class ReportProblemViewController: UIViewController {

    var delgate: ReportProblemVCDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapConfirm(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
        delgate?.confirm()
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
