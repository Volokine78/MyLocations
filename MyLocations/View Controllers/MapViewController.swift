//
//  MapViewController.swift
//  MyLocations
//
//  Created by Tolga PIRTURK on 8.05.2021.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    
    var managedObjectContext: NSManagedObjectContext!
    var locations = [Location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()
        
        if !locations.isEmpty {
            showLocations()
        }
    }
    
    // MARK: - Actions
    @IBAction func showUser() {
        let region = MKCoordinateRegion(
            center: mapView.userLocation.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    @IBAction func showLocations() {
        let theRegion = region(for: locations)
        mapView.setRegion(theRegion, animated: true)
    }
    
    // MARK: - Helper Methods
    func updateLocations() {
        mapView.removeAnnotations(locations)
        
        let entity = Location.entity()
        
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity
        
        locations = try! managedObjectContext.fetch(fetchRequest)
        mapView.addAnnotations(locations)
    }
    
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion
        
        switch annotations.count {
            case 0:
                region = MKCoordinateRegion(
                    center: mapView.userLocation.coordinate,
                    latitudinalMeters: 1000,
                    longitudinalMeters: 1000)
            case 1:
                let annotation = annotations[annotations.count - 1]
                region = MKCoordinateRegion(
                    center: annotation.coordinate,
                    latitudinalMeters: 1000,
                    longitudinalMeters: 1000)
            default:
                var topleft = CLLocationCoordinate2D(
                    latitude: -90,
                    longitude: 180)
                var bottomRight = CLLocationCoordinate2D(
                    latitude: 90,
                    longitude: -180)
                
                for annotation in annotations {
                    topleft.latitude = max(
                        topleft.latitude,
                        annotation.coordinate.latitude)
                    topleft.longitude = min(
                        topleft.longitude,
                        annotation.coordinate.longitude)
                    bottomRight.latitude = min(
                        bottomRight.latitude,
                        annotation.coordinate.latitude)
                    bottomRight.longitude = max(
                        bottomRight.longitude,
                        annotation.coordinate.longitude)
                }
                
                let center = CLLocationCoordinate2D(
                    latitude: topleft.latitude -
                        (topleft.latitude - bottomRight.latitude / 2),
                    longitude: topleft.longitude -
                        (topleft.longitude - bottomRight.longitude / 2))
                
                let extraSpace = 1.1
                let span = MKCoordinateSpan(
                    latitudeDelta: abs(topleft.latitude - bottomRight.latitude)
                        * extraSpace,
                    longitudeDelta: abs(topleft.longitude - bottomRight.longitude)
                        * extraSpace)
                
                region = MKCoordinateRegion(center: center, span: span)
        }
        return mapView.regionThatFits(region)
    }
}

extension MapViewController: MKMapViewDelegate{
}
