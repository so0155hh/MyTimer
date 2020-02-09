//
//  SettingViewController.swift
//  MyTimer
//
//  Created by 桑原望 on 2020/01/16.
//  Copyright © 2020 MySwift. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    let settingArray : [Int] = [12,24,30]
    let settingKey = "timer_value"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timerSettingPicker.delegate = self
        timerSettingPicker.dataSource = self
      
        
        
        let userDefaults = UserDefaults.standard
        let timerValue = userDefaults.integer(forKey: settingKey)
        
        for row in 0..<settingArray.count {
            if settingArray[row] == timerValue {
                timerSettingPicker.selectRow(timerValue, inComponent: 0, animated: false)
            }
        }
        
        if  timerValue == 12 {
            timerSettingPicker.selectRow(0, inComponent: 0, animated: false)
        } else if timerValue == 24 {
            timerSettingPicker.selectRow(1, inComponent: 0, animated: false)
        } else if timerValue == 30 {
            timerSettingPicker.selectRow(2, inComponent: 0, animated: false)
        }
     
    }
    @IBOutlet weak var timerSettingPicker: UIPickerView!
    
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBAction func cancelReturn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return settingArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(settingArray[row])
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(settingArray[row], forKey: settingKey)
        userDefaults.synchronize()
    }
   
}
