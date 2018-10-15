//
//  ShiftTimePickerVC.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 13/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit

class ShiftTimePickerVC: UIViewController {

    @IBOutlet weak var pickerView: UIDatePicker!
    var delegate: ShiftTimerPickerVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.locale = Locale(identifier: "en_GB")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        let date = dateFormatter.date(from: "12:00")
        pickerView.date = date!

    }

    @IBAction func didTapSave(_ sender: UIButton) {
        let date = pickerView.date
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hours = components.hour!
        let minutes = components.minute!
        let totalMinutes = (hours*60) + minutes
        print(totalMinutes)
        delegate.selectedMinutes(minutes: totalMinutes)
        self.dismiss(animated: true, completion: nil)
    }
    


}
