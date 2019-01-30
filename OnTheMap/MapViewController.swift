//
//  ViewController.swift
//  OnTheMap
//
//  Created by Reham on 25/12/2018.
//  Copyright © 2018 Reham. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationData = APICalls()
    var info = [StudentInformation]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationData.getStudentLocation { (studentsInfo, error) in
            
            guard error == nil else {
                let errorAlert = UIAlertController(title: "Error", message: "There was an error performing your request", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
                return
            }
            
            guard let studentsInfo = studentsInfo else {
                let locationsErrorAlert = UIAlertController(title: "Erorr loading locations", message: "There was an error loading locations", preferredStyle: .alert )
                locationsErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(locationsErrorAlert, animated: true, completion: nil)
                
                return }
            
            DispatchQueue.main.async {
                UserManager.shared.locations = studentsInfo
                self.displayLoctions(locatins: UserManager.shared.locations)
            }
            
        }
   
    }
    
    func displayLoctions(locatins:[StudentInformation]){
        
        let locations = locatins
        var annotations = [MKPointAnnotation]()
        
        for item in locations {
            
            let lat = CLLocationDegrees(item.latitude ?? 1.1)
            let long = CLLocationDegrees(item.longitude ?? 1.1)
            
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let fullName = item.fullName
            
            let mediaURL = item.mediaURL
            
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(String(describing: fullName!))"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
    
    @IBAction func logoutButton(_ sender: Any) {
        
        APICalls.shared.logout { (message, result, error) in
            guard error == nil else {
                let errorAlert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
                return
            }
            
            guard result == true else {
                let errorAlert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
                return
            }
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
            self.present(controller, animated: true, completion: nil)
        }
        
        
    }
    @IBAction func didUnwindFromFindLocation(_ sender: UIStoryboardSegue){
        
    }
    
}


extension MapViewController: MKMapViewDelegate{
    
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
               
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
    

    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView)
    {
        if let annotationTitle = view.annotation?.title
        {
            print("User tapped on annotation with title: \(annotationTitle!)")
        }
    }
    
    
}

