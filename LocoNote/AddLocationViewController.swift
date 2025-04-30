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
    
    @IBOutlet weak var btnLocationImage: UIButton!
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        if let location = currentLocation {
            txtLocation.text = location.name
            lblCity.text = location.city
            lblLatitude.text = String(location.latitude)
            lblLongitude.text = String(location.longitude)
            lblDate.text = location.date
            if let imageData = location.image {
                imgLocation.image = UIImage(data: imageData)
            }
        }
        sgmtEditMode.selectedSegmentIndex = 0
        changeEditMode(sgmtEditMode!)
    }

    
    
    
    @IBAction func changePicture(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let cameraController = UIImagePickerController()
            cameraController.sourceType = .camera
            cameraController.cameraCaptureMode = .photo
            cameraController.delegate = self
            cameraController.allowsEditing = true
            self.present(cameraController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            
            imgLocation.contentMode = .scaleAspectFill
            imgLocation.image = image
            if currentLocation == nil {
                let context = appDelegate.persistentContainer.viewContext
                currentLocation = Location(context: context)
            }
            currentLocation?.image = image.jpegData(compressionQuality: 1.0)
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        lblDate.text = formatter.string(from: Date())
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeEditMode(_ sender: Any) {
        
        if sgmtEditMode.selectedSegmentIndex == 0 { //View Mode
            txtLocation.isUserInteractionEnabled = false
            txtLocation.borderStyle = .none
            navigationItem.rightBarButtonItem = nil
            btnLocationImage.isEnabled = false
            btnLocationImage.isHidden = true
            btnDeviceCoordinates.isEnabled = false
            btnDeviceCoordinates.isHidden = true
        }
        else{                                      //Edit Mode
            txtLocation.isUserInteractionEnabled = true
            txtLocation.borderStyle = .roundedRect
            btnLocationImage.isEnabled = true
            btnLocationImage.isHidden = false
            btnDeviceCoordinates.isEnabled = true
            btnDeviceCoordinates.isHidden = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .save,
                target: self,
                action: #selector(self.saveLocation)
            )
        }
        
    }
    
    @objc func saveLocation(){
        view.endEditing(true)
        if currentLocation == nil {
            let context = appDelegate.persistentContainer.viewContext
            currentLocation = Location(context: context)
        }
        currentLocation?.name = txtLocation.text
        currentLocation?.city = lblCity.text
        currentLocation?.date = lblDate.text
        currentLocation?.image = imgLocation.image?.jpegData(compressionQuality: 0.8)
        appDelegate.saveContext()
        sgmtEditMode.selectedSegmentIndex = 0
        changeEditMode(self)
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
                currentLocation?.latitude = coordinate.latitude
                currentLocation?.longitude = coordinate.longitude
            }
        }
    }
    

}
