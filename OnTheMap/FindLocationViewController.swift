//
//  FindLocationViewController.swift
//  OnTheMap
//
//  Created by Reham on 26/12/2018.
//  Copyright © 2018 Reham. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class FindLocationViewController: UIViewController {
    
    @IBOutlet weak var finishButton: UIButton!
    var appDelegate: AppDelegate!
    var locationName:String!
    var  mediaURL:String!
    var annotations = [MKPointAnnotation]()
    var coordinates = CLLocationCoordinate2D()
    
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print(locationName!)
        print("this is the \(self.coordinates)")
        
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)

        
        let _locationName = "\(self.locationName!)"
        let mediaURL = "\(self.mediaURL!)"
        
        let latitude:CLLocationDegrees = self.coordinates.latitude
        
        let longitude:CLLocationDegrees = self.coordinates.longitude
        
        let latDelta:CLLocationDegrees = 0.05
        
        let lonDelta:CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.coordinates
        annotation.title = "\(_locationName)"
        annotation.subtitle = "\(mediaURL)"
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        self.annotations.append(annotation)
        self.mapView.setRegion(region, animated: true)
        self.mapView.addAnnotations(self.annotations)
    }
    
    
    @IBAction func finishButton(_ sender: Any) {
        
        APICalls.shared.postLocation(locationName: self.locationName!, mediaURL: self.mediaURL!, latitude: self.coordinates.latitude, longitude: self.coordinates.longitude) { (message, result, error) in
            
            guard error == nil else {
                let alert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            guard result == true else {
                return
            }
        
        }
        performUIUpdatesOnMain {
            self.setUIEnabled(false)
        }
        self.completeAddingLocation()
        
    }
    private func completeAddingLocation() {
        performUIUpdatesOnMain {
            self.setUIEnabled(true)
            
        }
    }
    


}

// MARK: - FindLocationViewController (Configure UI)
private extension FindLocationViewController {
    
    func setUIEnabled(_ enabled: Bool){
        finishButton.isEnabled = enabled
        
        // adjust Finish button alpha
        finishButton.alpha = enabled ? 1.0 : 0.5        
    }
}

extension FindLocationViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
               // app.openURL(URL(string: toOpen)!)
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
                
            }
        }
    }
    
    
}


