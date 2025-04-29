//
//  AddLocationViewController.swift
//  LocoNote
//
//  Created by Cosmas Obi on 4/29/25.
//

import UIKit
import CoreData
import AVFoundation
import CoreLocation

class AddLocationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    var currentLocation: Location?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var geoCoder = CLGeocoder()
    var locationManager: CLLocationManager!

    @IBOutlet weak var sgmtEditMode: UISegmentedControl!
    
    @IBOutlet weak var txtLocation: UITextField!
    
    @IBOutlet weak var imgLocation: UIImageView!
    
    @IBOutlet weak var lblLatitude: UILabel!
    
    @IBOutlet weak var lblLongitude: UILabel!
    
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    @IBOutlet weak var btnDeviceCoordinates: UIButton!
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func changePicture(_ sender: Any) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) != AVAuthorizationStatus.authorized {
            let alertController = UIAlertController(title: "Camera Access Denied", message: "In order to take pictures, you need to allow the app to access the camera in the Settings.", preferredStyle: .alert)
            let actionSettings = UIAlertAction(title: "Settings", style: .default) { (action) in
                self.openSettings()
            }
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(actionSettings)
            alertController.addAction(actionCancel)
            present(alertController, animated: true, completion: nil)
        }
        
        else {
            if UIImagePickerController .isSourceTypeAvailable(.camera) {
                let cameraController = UIImagePickerController()
                cameraController.sourceType = .camera
                cameraController.cameraCaptureMode = .photo
                cameraController.delegate = self
                cameraController.allowsEditing = true
                self.present(cameraController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func changeEditMode(_ sender: Any) {
        
        if sgmtEditMode.selectedSegmentIndex == 0{ //View Mode
            txtLocation.isUserInteractionEnabled = false
            txtLocation.borderStyle = .none
        }
        else{                                      //Edit Mode
            txtLocation.isUserInteractionEnabled = true
            txtLocation.borderStyle = .roundedRect
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(self.saveLocation)
        )
    }
    
    @objc func saveLocation(){
        view.endEditing(true)
     if currentLocation == nil {
              print("❌ currentLocation is nil. No contact to save.")
          } else {
              print("✅ currentLocation exists. Proceeding to save:")
              print("Location name: \(currentLocation?.name ?? "nil")")
          }
        print("🔎 Location TextField Values:")
        print("Name: \(txtLocation.text ?? "nil")")
        print("Latitude: \(lblLatitude.text ?? "nil")")
        print("Longitude: \(lblLongitude.text ?? "nil")")
        print("City: \(lblCity.text ?? "nil")")
        print("Date: \(lblDate.text ?? "nil")")
        if currentLocation == nil {
            let context = appDelegate.persistentContainer.viewContext
            currentLocation = Location(context: context)
        }
        currentLocation?.name = txtLocation.text
        if let latText = lblLatitude.text, let latitude = Double(latText) {
            currentLocation?.latitude = latitude
        }

        if let lonText = lblLongitude.text, let longitude = Double(lonText) {
            currentLocation?.longitude = longitude
        }
        currentLocation?.city = lblCity.text
        currentLocation?.date = lblDate.text
        currentLocation?.image = imgLocation.image?.jpegData(compressionQuality: 0.8)
        appDelegate.saveContext()
        sgmtEditMode.selectedSegmentIndex = 0
        changeEditMode(self)
    }
    func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.openURL(settingsUrl)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            
            imgLocation.contentMode = .scaleAspectFit
            imgLocation.image = image
            if currentLocation == nil {
                let context = appDelegate.persistentContainer.viewContext
                currentLocation = Location(context: context)
            }
            currentLocation?.image = image.jpegData(compressionQuality: 1.0)
        }
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func deviceCoordinates(_ sender: Any) {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func locationManager (_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print ("Permission Granted")
        }
        else {
            print("Permission NOT Granted")
        }
    }
    
    func locationManager (_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let eventDate = location.timestamp
            let howRecent = eventDate.timeIntervalSinceNow
            if Double(howRecent) < 15.0 {
                let coordinate = location.coordinate
                lblLatitude.text = String(format: "%g\u{00B0}", coordinate.latitude)
                lblLongitude.text = String(format: "%g\u{00B0}", coordinate.longitude)
                lblAccuracy.text = String(format: "%gm", location.horizontalAccuracy)
            }
        }
    }
    

}
