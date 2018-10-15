//
//  AwayTimesViewController.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 02/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit

class AwayTimesViewController: UIViewController {

    var delgate: AwayTimesDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction func didTap10Minutes(_ sender: UITapGestureRecognizer) {
        delgate?.selectedTime(minutes: .tenMinutes)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTap15Minutes(_ sender: UITapGestureRecognizer) {
        delgate?.selectedTime(minutes: .fifteenMinutes)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func didTap30Minutes(_ sender: UITapGestureRecognizer) {
        delgate?.selectedTime(minutes: .thirtyMinutes)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func didTap1Hour(_ sender: UITapGestureRecognizer) {
        delgate?.selectedTime(minutes: .oneHour)
        self.dismiss(animated: true, completion: nil)
    }

}
