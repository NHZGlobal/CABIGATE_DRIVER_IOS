//
//  SelectZoneVC.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 03/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit

class SelectZoneVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var selectedIndex:Int? = nil
    
    @IBOutlet weak var selectZoneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.selectZoneButton.layer.cornerRadius = self.selectZoneButton.frame.size.height/2
        self.cancelButton.layer.cornerRadius = self.cancelButton.frame.size.height/2
    }

    @IBAction func didTapCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSelectThisZone(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension SelectZoneVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shiftvehiclecell") as! ShiftVehicleCell
        cell.bgView.addShadow()
        
        cell.vehicleBgView.layer.borderWidth = 2
        cell.vehicleBgView.layer.borderColor = UIColor.freeVehicle.cgColor
        
        if let selected = selectedIndex, selected == indexPath.row {
            // cell.backgroundColor = .cabigateThemeColor
            cell.bgView.backgroundColor = UIColor(red: 210/255, green: 249/255, blue: 253/255, alpha: 1.0)
        }else {
            cell.bgView.backgroundColor = .white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
