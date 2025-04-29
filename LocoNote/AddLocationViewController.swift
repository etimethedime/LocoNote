//
//  AddLocationViewController.swift
//  LocoNote
//
//  Created by Cosmas Obi on 4/29/25.
//

import UIKit
import CoreData
import AVFoundation

class AddLocationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var currentLocation: Location?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var sgmtEditMode: UISegmentedControl!
    
    @IBOutlet weak var txtLocation: UITextField!
    
    @IBOutlet weak var imgLocation: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
