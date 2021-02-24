//
//  ViewController.swift
//  Travel Book
//
//  Created by Simon Wilson on 23/02/2021.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    var locationManager = CLLocationManager()
    
    var chosenLatitude = Double()
    
    var chosenLongitude = Double()
    
    var selectedTitle = ""
    var selectedTitleId: UUID?
    
    var annotationTitle = ""
    
    var annotationSubtitle = ""
    
    var annotationLatitude = Double()
    
    var annotationLongitude = Double()
    
    
    
    @IBOutlet weak var map: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        map.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        
        gestureRecognizer.minimumPressDuration = 3
        
        map.addGestureRecognizer(gestureRecognizer)
        
        let gestureKeyboardRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        view.addGestureRecognizer(gestureKeyboardRecognizer)
        
        
        if selectedTitle != "" {
            
            // getCore data data
            
            let appdelegate = UIApplication.shared.delegate as? AppDelegate
            
            if let context = appdelegate?.persistentContainer.viewContext {
                
                let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
                
                let idString = selectedTitleId!.uuidString
                
                fetchrequest.predicate = NSPredicate(format: "id = %@", idString)
                
                fetchrequest.returnsObjectsAsFaults = false
                
                do {
                    
                    let results = try context.fetch(fetchrequest)
                    
                    if results.count > 0 {
                        
                        for result in results as! [NSManagedObject] {
                            
                            if let title = result.value(forKey: "title") as? String {
                                
                                annotationTitle = title
                                
                                if let subtitle = result.value(forKey: "subtitle") as? String {
                                    
                                    annotationSubtitle = subtitle
                                    
                                    if let latitude = result.value(forKey: "latitude") as? Double {
                                        
                                        annotationLatitude = latitude
                                        
                                        if let longitude = result.value(forKey: "longitude") as? Double {
                                            
                                            annotationLongitude = longitude
                                            
                                            let annotation = MKPointAnnotation()
                                            
                                            annotation.title = annotationTitle
                                            
                                            annotation.subtitle = annotationSubtitle
                                            
                                            let coordiante = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                            
                                            annotation.coordinate = coordiante
                                            
                                            map.addAnnotation(annotation)
                                            
                                            nameTextField.text = annotationTitle
                                            
                                            commentTextField.text = annotationSubtitle
                                            
                                            locationManager.stopUpdatingLocation()
                                            
                                            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                            
                                            let region = MKCoordinateRegion(center: coordiante, span: span)
                                            
                                            map.setRegion(region, animated: true)
                                            
                                        }
                                        
                                    }
                                    
                                    
                                }
                                
                                
                                
                                
                            }
                            
                            
                            
                        }
                        
                    }
                    
                } catch {
                    
                    print("unable to retrieve data")
                    
                }
                
                
            }
            
            
            
        } else {
            
            // Add new data
            
        }
        
        
    }
    
    @objc func hideKeyboard() {
        
        view.endEditing(true)
        
    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        
        
        if gestureRecognizer.state == .began {
            
            let touchPoint = gestureRecognizer.location(in: self.map)
            
            let touchCoordinates = self.map.convert(touchPoint, toCoordinateFrom: self.map)
            
            chosenLatitude = touchCoordinates.latitude
            
            chosenLongitude = touchCoordinates.longitude
            
            let annotations = MKPointAnnotation()
            
            annotations.coordinate = touchCoordinates
            
            annotations.title = nameTextField.text
            
            annotations.subtitle = commentTextField.text
            
            self.map.addAnnotation(annotations)
            
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if selectedTitle == "" {
        
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            
            let region = MKCoordinateRegion(center: location, span: span)
            
            map.setRegion(region, animated: true)
            
        } else {
            
            //  do nothing
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            
            return nil
            
        }
        
        let reuseId = "myAnnotation"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKAnnotationView
        
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            pinView?.canShowCallout = true
            
            pinView?.tintColor = UIColor.black
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            
            pinView?.rightCalloutAccessoryView = button
            
        } else {
            
            pinView?.annotation = annotation
            
        }
        
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if selectedTitle != "" {
            
            var requestedLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestedLocation) { (placemarks, error) in
                
                if let placemark = placemarks {
                
                    if placemark.count > 0 {
                    
                    let newPlacemark = MKPlacemark(placemark: placemark[0])
                        
                    let item = MKMapItem(placemark: newPlacemark)
                        
                        item.name = self.annotationTitle
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        
                        item.openInMaps(launchOptions: launchOptions)
                    
                }
                    
                }
                
            }
            
        }
        
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        
        if let context = appDelegate?.persistentContainer.viewContext {
            
            let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
            
            if nameTextField.text == "" && commentTextField.text == "" {
                
                self.alertMessage(title: "Error", message: "Please input title and comment")
                
            } else {
                
                newLocation.setValue(nameTextField.text, forKey: "title")
                
                newLocation.setValue(commentTextField.text, forKey: "subtitle")
                
                newLocation.setValue(chosenLatitude, forKey: "latitude")
                
                newLocation.setValue(chosenLongitude, forKey: "longitude")
                
                newLocation.setValue(UUID(), forKey: "id")
                
                do {
                    
                    try context.save()
                    
                    print("success")
                    
                } catch {
                    
                    print("unable to save")
                    
                }
                
                NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
                navigationController?.popViewController(animated: true)
                
            }
            
        }
        
    }
    
    func alertMessage(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
}

