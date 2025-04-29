//
//  SettingsViewController.swift
//  LocoNote
//
//  Created by Ezra Degafe on 4/29/25.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{

    

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var switchAsc: UISwitch!
    let sortOrderItems: Array<String> = ["city", "date", "name"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortOrderItems.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sortOrderItems[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let sortField = sortOrderItems[row]
        let settings = UserDefaults.standard
        settings.set(sortField, forKey: Constants.kSortField)
        settings.synchronize()
    }
    
    @IBAction func sortDirectionChanged(_ sender: Any) {
        let settings = UserDefaults.standard//Log the switch value
        settings.set(switchAsc.isOn, forKey: Constants.kSortDirectionDescending)
        print("Switch state is \(switchAsc.isOn)")
        settings.synchronize()
    }
    

}
