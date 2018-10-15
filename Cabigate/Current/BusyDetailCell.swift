//
//  BusyDetailCell.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 02/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit

class BusyDetailCell: UITableViewCell {

    @IBOutlet var passengerIcon: [UIImageView]!
    @IBOutlet var bagIcons: [UIImageView]!
    @IBOutlet weak var fareEstimateLabel: UILabel!
    @IBOutlet weak var passengerName: UILabel!
    @IBOutlet weak var contactBgView: UIView!
    @IBOutlet weak var contactNumber: UILabel!
    @IBOutlet weak var fare: UILabel!
    @IBOutlet weak var when: UILabel!
    @IBOutlet weak var notes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
