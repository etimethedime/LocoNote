//
//  MapViewController.swift
//  LocoNote
//
//  Created by Mikiyas Mekasha on 4/29/25.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    var locationManager = CLLocationManager()
    var location: [Location] = []
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sgmtMapType: UISegmentedControl!
    
    @IBAction func mapTypeChanged(_ sender: Any) {
        switch sgmtMapType.selectedSegmentIndex{
        case 0:
            mapView.mapType = .standard
            break
        case 1:
            mapView.mapType = .satellite
            break
        default :
            break
        }
    }
    
    @IBAction func findUser(_ sender: Any) {
        mapView.showsUserLocation = true
            mapView.setUserTrackingMode(.follow, animated: true)
            if let userLocation = mapView.userLocation.location {
                let region = MKCoordinateRegion(center: userLocation.coordinate,
                                                latitudinalMeters: 1000,
                                                longitudinalMeters: 1000)
                mapView.setRegion(region, animated: true)
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization( )
        
        mapView.delegate = self
        
    }
    func mapView(_ mapView:MKMapView, didUpdate userLocation: MKUserLocation) {
        var span = MKCoordinateSpan()
        span.latitudeDelta = 0.2
        span.longitudeDelta = 0.2
        let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, span: span)
        mapView.setRegion(viewRegion, animated: true)
        let mp = MapPoint(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        mp.title = "You"
        mp.subtitle = "Are here"
        mapView.addAnnotation(mp)
        
    }
    override func viewWillAppear(_ animated: Bool){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Location")
        var fetchedObjects : [NSManagedObject] = []
        do {
            fetchedObjects = try context.fetch(request)
        }catch let error as NSError{
            print("Could not fetch. (error), (error.userInfo)")
        }
        location = fetchedObjects as! [Location]
        self.mapView.removeAnnotations(self.mapView.annotations)
        for loc in location {
            let annotation = MKPointAnnotation()
            annotation.title = loc.name
            annotation.coordinate = CLLocationCoordinate2D(
                latitude: loc.latitude,
                longitude: loc.longitude
            )
            self.mapView.addAnnotation(annotation)
        }
    }
    
    private func processAddressResponse(_ location: Location, withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if let error = error{
            print("Geocode Error: \(error)")
        }
        else {
            var bestMatch: CLLocation?
            if let placemarks = placemarks, placemarks.count > 0{
                bestMatch = placemarks.first?.location
            }
            if let coordinate = bestMatch?.coordinate {
                let mp = MapPoint(latitude:coordinate.latitude, longitude:coordinate.longitude)
                mp.title = location.name
                mp.subtitle = location.longitude.description + " " + location.latitude.description
                
            }
            else{
                print("Didnt find any matching locations")
            }
        }
    }
    
}
