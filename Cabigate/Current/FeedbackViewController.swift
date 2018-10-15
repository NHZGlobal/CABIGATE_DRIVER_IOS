//
//  FeedbackViewController.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 08/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {

    @IBOutlet weak var payByLabel: UILabel!
    var delgate: FeedbackVCDelegate? = nil

    @IBOutlet weak var textview: NKTextView!
    var payText = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.payByLabel.text = payText
    }

    @IBAction func didTapCancel(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func didTapNext(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
        delgate?.submit(feedback: textview.text)

    }
}
