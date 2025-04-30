//
//  LocationTableViewController.swift
//  LocoNote
//
//  Created by Ezra Degafe on 4/29/25.
//

import UIKit
import CoreData

class LocationTableViewController: UITableViewController {
    var locations: [NSManagedObject] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
        

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    override func viewWillAppear(_ animated: Bool) {
        loadDataFromDataBase()
        tableView.reloadData()
    }
    
    func loadDataFromDataBase() {
        let settings = UserDefaults.standard
        let sortField = settings.string(forKey: Constants.kSortField) ?? "city"
        let sortAscending = settings.bool(forKey: Constants.kSortDirectionAscending)
        
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Location")
        
        let sortDescriptor = NSSortDescriptor(key: sortField, ascending: sortAscending)
        request.sortDescriptors = [sortDescriptor]
        
        print("Sorting by \(sortField), ascending: \(sortAscending)")
        
        do {
            locations = try context.fetch(request)
            print("Loaded \(locations.count) contacts from core data")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        let location = locations[indexPath.row] as? Location
        cell.textLabel?.text = location?.name
        cell.detailTextLabel?.text = location?.city
        cell.accessoryType = UITableViewCell.AccessoryType.detailDisclosureButton
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contact = locations[indexPath.row] as? Location
            let context = appDelegate.persistentContainer.viewContext
            context.delete(contact!)
            do {
                try context.save()
            } catch {
                fatalError("Error deleting contact: \(error)")
            }
            loadDataFromDataBase()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLocation = locations[indexPath.row] as? Location
        let name = selectedLocation!.name!
        let actionHandler = { (action: UIAlertAction!) -> Void in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LocationController") as! AddLocationViewController
            controller.currentLocation = selectedLocation
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
        let alertController = UIAlertController(
            title: "Location Selected",
            message: "Selected: \(name) at \(indexPath.row)",
            preferredStyle: .actionSheet
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let detailsAction = UIAlertAction(title: "Show details", style: .default, handler: actionHandler)
        
        alertController.addAction(cancelAction)
        alertController.addAction(detailsAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let locationController = segue.destination as! AddLocationViewController
            let selectedRow = self.tableView.indexPath(for: sender as! UITableViewCell)?.row
            let selectedLocation = locations[selectedRow!] as? Location
            locationController.currentLocation = selectedLocation!
            
            print("Segue to EditLocation — Sending Location: \(selectedLocation?.name ?? "nil") | City: \(selectedLocation?.city ?? "nil")")
        }
    }

}
