//
//  AddViewController.swift
//  OnTheMap
//
//  Created by Reham on 26/12/2018.
//  Copyright © 2018 Reham. All rights reserved.
//

import UIKit
import CoreLocation
class AddLocationViewController: UIViewController {
    
    @IBOutlet weak var locationName: UITextField!
    @IBOutlet weak var mediaURL: UITextField!
    
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var coordinates = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       activityIndicator.isHidden = true
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func findLocation(_ sender: Any) {
        
        guard locationName.text != "", mediaURL.text != "" else {
            // add alert
            let alert = UIAlertController(title: "Error", message: "Please Enter value needed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }

        setUIEnabled(false)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        geocoder()
    }
    
    private func completeGeocoding() {
        performUIUpdatesOnMain {
            self.setUIEnabled(true)
             self.performSegue(withIdentifier: "FindLocation", sender: self)
        }
    }
    
    func geocoder(){
        let geocoder = CLGeocoder()
        let address = "\(locationName.text!)"
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            
            guard error == nil else {
                let alert = UIAlertController(title: "Error", message: "location not found", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            self.coordinates = (placemark.location?.coordinate)!
            print(self.coordinates)
            self.completeGeocoding()
           
        })
        
         self.activityIndicator.stopAnimating()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let findLocation = segue.destination as! FindLocationViewController
        findLocation.locationName = "\(locationName.text!)"
        findLocation.mediaURL = "\(mediaURL.text!)"
        findLocation.coordinates.latitude = coordinates.latitude
        findLocation.coordinates.longitude = coordinates.longitude
    }

    
}

// MARK: - AddLocationViewController (Configure UI)
private extension AddLocationViewController {
    
    func setUIEnabled(_ enabled: Bool){
        locationName.isEnabled = enabled
        mediaURL.isEnabled = enabled

        // adjust login button alpha
        findLocationButton.alpha = enabled ? 1.0 : 0.5
    }
}
