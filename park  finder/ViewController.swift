//
//  ViewController.swift
//  park  finder
//
//  Created by James Caldwell on 3/15/21.
//  Copyright © 2021 James Caldwell. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var textArea: UITextField!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    let locationManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    var currentLocation: CLLocation!
    var parks: [MKMapItem] = []
    var locArray: [CLLocationCoordinate2D] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       segmentedController.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
    }
    
   // MARK: Change width of input text
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        widenTextField()
    }

    @IBAction func overlayButton(_ sender: UIButton) {
        let polyline = MKPolyline(coordinates: &self.locArray, count: self.locArray.count)
        self.mapView.addOverlay(polyline)
        print(self.locArray)
    }
    func widenTextField() {
        var frame: CGRect? = textArea?.frame
        frame?.size.width = 250
        textArea?.frame = frame!
    }
    
    
    
    func locationManager (_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[0]
    }
    @IBAction func whenZoom(_ sender: Any) {
        let cordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let center = currentLocation.coordinate
        let region = MKCoordinateRegion(center: center, span: cordinateSpan)
        mapView.setRegion(region, animated: true)
    }
    @IBAction func whenSearchButtonPressed(_ sender: UIBarButtonItem) {
        parks.removeAll()
        removeAllAnnotations()

        guard let searchText = textArea.text else {return}
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        request.region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
        let search = MKLocalSearch(request: request)
        search.start { (response,  error) in
            guard let response =  response else { return }
            for mapItem in response.mapItems {
               //  self.locArray.append()

                self.parks.append(mapItem)
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                print(annotation.coordinate)
                self.locArray.append(annotation.coordinate)
                annotation.title = mapItem.name
                self.mapView.addAnnotation(annotation)
            }

        }
//        let polyline = MKPolyline(coordinates: &self.locArray, count: self.locArray.count)
//        self.mapView.addOverlay(polyline)
//        print(self.locArray)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        // change to search
        if let title = annotation.title, let actualTitle = title {
            if actualTitle == "Westgrove Park" {
                pin.image = UIImage(named: "MobileMakerIconPinImage")
            }else {
                pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
            }
        }
        pin.canShowCallout = true
        let button = UIButton(type: .detailDisclosure)
        pin.rightCalloutAccessoryView = button
        if annotation.isEqual(mapView.userLocation){
            return nil
        }
        return pin
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        
        var currentMapItem = MKMapItem()
        if let coordinate = view.annotation?.coordinate {
            for mapItem in parks {
                if mapItem.placemark.coordinate.latitude == coordinate.latitude &&  mapItem.placemark.coordinate.longitude == coordinate.longitude {
//                    locArray.append(currentLocation.coordinate)
//                    let polyline = MKPolyline(coordinates: &locArray, count: locArray.count)
//                    mapView.addOverlay(polyline)
                    currentMapItem = mapItem
                    
                }
            }
        }
        let placemark = currentMapItem.placemark
        if let parkName = placemark.name, let  streetNumber = placemark.subThoroughfare, let streetName = placemark.thoroughfare {
//            let streetAddress = streetNumber + " " + streetName
//            let streetAddress = "\(String(annotation.coordinate))"
            let alert = UIAlertController(title: parkName, message: streetAddress, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            present(alert, animated: true,  completion: nil
            )
        }
    }
    
    func removeAllAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
    }
    
}

