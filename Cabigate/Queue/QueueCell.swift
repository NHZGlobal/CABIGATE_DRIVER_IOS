//
//  QueueCell.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 03/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit

class QueueCell: UITableViewCell {

    @IBOutlet weak var when: UILabel!
    @IBOutlet weak var pickup: UILabel!
    @IBOutlet weak var dropoff: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var fare: UILabel!
    @IBOutlet weak var vehicleType: UILabel!
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
