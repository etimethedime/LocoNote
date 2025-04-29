//
//  SettingsViewController.swift
//  LocoNote
//
//  Created by Ezra Degafe on 4/29/25.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var switchAsc: UISwitch!
    let sortOrderItems: Array<String> = ["name", "city", "birthday"]
    override func viewDidLoad() {
        super.viewDidLoad()

    }
 

}
