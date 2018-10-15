//
//  PickupCell.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 02/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit

class BusyPickupCell: UITableViewCell {

    @IBOutlet weak var titleBgView: UIView!
    @IBOutlet weak var navBgView: UIView!
    @IBOutlet weak var travelTitle: UILabel!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var checkmark: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
