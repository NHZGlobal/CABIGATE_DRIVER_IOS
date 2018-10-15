//
//  JobCompleteViewController.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 08/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit

class JobCompleteViewController: UIViewController {

    var timer: Timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.timer = Timer.every(2.seconds) { (timer: Timer) in
            self.timer.invalidate()
            self.dismiss(animated: true, completion: nil)
        }
        
    }


    @IBAction func didTapQueuedJobs(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }

}
