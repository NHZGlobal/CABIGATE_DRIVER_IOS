//
//  ShiftVehicleCell.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 01/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit

class ShiftVehicleCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var vehicleBgView: UIView!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var number: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
