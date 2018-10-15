//
//  CancelJobViewController.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 02/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit

class CancelJobViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var nuButton: UIButton!
    
    @IBOutlet weak var noShowButton: SSRadioButton!
    @IBOutlet weak var otherButton: SSRadioButton!
    
    var radioButtonController: SSRadioButtonsController?
    
    var delegate: CancelJobVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        radioButtonController = SSRadioButtonsController(buttons: noShowButton, otherButton)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = true
        
        self.nuButton.layer.cornerRadius = self.nuButton.frame.size.height/2
        self.yesButton.layer.cornerRadius = self.yesButton.frame.size.height/2
        
        self.textView.addBorder(color: .darkGray, width: 1)
        self.textView.layer.cornerRadius = 10
    }

    @IBAction func didTapNo(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapYes(_ sender: UIButton) {
        let reason = self.textView.text!
        self.dismiss(animated: true, completion: nil)
        delegate.yes(reason: reason)
    }
}

extension CancelJobViewController: SSRadioButtonControllerDelegate {
    func didSelectButton(selectedButton: UIButton?)
    {
        print(#function)
    }
}
