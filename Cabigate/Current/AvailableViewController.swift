//
//  AvailableViewController.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 02/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit

class AvailableViewController: UIViewController {

    @IBOutlet weak var shiftInlabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear

        if let _ = DatabaseManager.realm.objects(ShiftIn.self).first {
            self.shiftInlabel.isHidden = true
        }else {
            self.shiftInlabel.isHidden = false
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
