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
    var locations: [Location] = []
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sgmtMapType: UISegmentedControl!
    
    
    @IBAction func findUser(_ sender: Any) {
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow,animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization( )
        
        mapView.delegate = self
        
        // Do any additional setup after loading the view.
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
        
        
    }
}
