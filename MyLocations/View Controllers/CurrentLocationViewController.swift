//
//  ViewController.swift
//  MyLocations
//
//  Created by Tolga PIRTURK on 11.04.2021.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: Error?
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    var timer: Timer?
    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longtitudeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var tagButton: UIButton!
    @IBOutlet var getButton: UIButton!
    
    // MARK: - Actions
    @IBAction func getLocation() {
        let authStatus = locationManager.authorizationStatus
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
        }
    }
    
    // MARK: - CLLocation Manager Delegate
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        //print("didFailWithError \(error.localizedDescription)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        let newLocation = locations.last!
        //print("didUpdateLocations \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                //print("We're done!")
                stopLocationManager()
                
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            updateLabels()
            
            if !performingReverseGeocoding {
                //print("*** Going to geocode")
                
                performingReverseGeocoding = true
                
                geocoder.reverseGeocodeLocation(newLocation) {placemarks, error in
                    self.lastGeocodingError = error
                    if error == nil, let places = placemarks, !places.isEmpty {
                        self.placemark = places.last!
                    } else {
                        self.placemark = nil
                    }
                    
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                }
            } else if distance < 1 {
                let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
                if timeInterval > 10 {
                    //print("*** Force done!")
                    stopLocationManager()
                    updateLabels()
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings",
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longtitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = " "
            
            func string(from placemark: CLPlacemark) -> String {
                var line1 = ""
                if let tmp = placemark.subThoroughfare {    // House Number
                    line1 += tmp + " "
                }
                if let tmp = placemark.thoroughfare {
                    line1 += tmp
                }
                
                var line2 = ""
                if let tmp = placemark.locality {
                    line2 += tmp + " "
                }
                if let tmp = placemark.administrativeArea {
                    line2 += tmp
                }
                return line1 + "\n" + line2
            }
            
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastLocationError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
            
        } else {
            latitudeLabel.text = ""
            longtitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            
            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
        }
        configureGetButton()
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
                        
            timer = Timer.scheduledTimer(
                timeInterval: 60,
                target: self,
                selector: #selector(didTimeOut),
                userInfo: nil,
                repeats: false)
        }
    }
    
    @objc func didTimeOut() {
        //print("*** Time Out")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(
                domain: "MyLocationsErrorDomain",
                code: 1,
                userInfo: nil)
            updateLabels()
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Location", for: .normal)
        }
    }
}


