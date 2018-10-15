//
//  SearchViewController.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 16/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit
import GooglePlaces

class SearchViewController: UIViewController {
    
    var showedPlaces = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.showedPlaces {
            self.showedPlaces = false
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            present(autocompleteController, animated: true, completion: nil)
        }else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension SearchViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        if let driver = DatabaseManager.realm.objects(Driver.self).first {
            guard let job = Driver.shared.value?.jobDetails else { return }
            
            var waypointNumber = 1
            if let waypoints = job.waypoints {
                waypointNumber = waypoints.count + 1
            }
            let parameters: [String : Any] = ["jobid":job.jobid!,
                                              "userid":driver.userId!,
                                              "companyid":driver.companyId!,
                                              "action":"add",
                                              "waypointnumber":waypointNumber,
                                              "lat":"\(place.coordinate.latitude)",
                                              "lng":"\(place.coordinate.longitude)",
                                              "location":place.name,
                                              "type": "waypoint"]
            APIServices.UpdateJobDetails(params: parameters, callback: { (error) in
                
            })
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

