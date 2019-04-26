//
//  SettingsController.swift
//  Emma
//
//  Created by Bilvi Maria Joseph on 2019-03-15.
//  Copyright © 2019 Bilvi Maria Joseph. All rights reserved.
//


import UIKit
import CoreData
class SettingsViewController: UITableViewController {
    
    var alarmStatus = "Alarm On"
    
    @IBOutlet weak var alarmLabel: UILabel!
    @IBOutlet weak var alarmButton: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeAlarm()
    }
    
    func initializeAlarm(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Alarm")
        print(applicationDocumentsDirectory)
        do{
            let result = try managedContext.fetch(fetchRequest)
            if result.count>0{
                let value = result[0].value(forKey: "isOn") as! String
                if(value == "YES" || value == "Alarm On"){
                    alarmStatus = "Alarm On"
                    alarmButton.setOn(true, animated: true)
                }else if(value == "Alarm Off"){
                    alarmStatus = "Alarm Off"
                    alarmButton.setOn(false, animated: true)                }
                alarmLabel.text = alarmStatus
            }
        }catch{
            print("error while fetching from Alarm entity")
        }
    }
    
    @IBAction func `switch`(_ sender: UISwitch) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Alarm")
        if sender.isOn{
            alarmStatus = "Alarm On"
            do{
                let result = try managedContext.fetch(fetchRequest)
                if result.count>0{
                    result[0].setValue(alarmStatus, forKey: "isOn")
                    print("Updated")
                    alarmLabel.text = result[0].value(forKey: "isOn") as? String
                    print(applicationDocumentsDirectory)
                    do{
                        try managedContext.save()
                    }catch{
                        print("error for managedcontext.save")
                    }
                }
            }catch{
                print("error")
            }
         }
        else{
            alarmStatus = "Alarm Off"
            do{
                let result = try managedContext.fetch(fetchRequest)
                if result.count>0{
                    result[0].setValue(alarmStatus, forKey: "isOn")
                    print("Updated")
                    alarmLabel.text = result[0].value(forKey: "isOn") as? String
                    print(applicationDocumentsDirectory)
                    do{
                        try managedContext.save()
                    }catch{
                        print("error for managedcontext.save")
                    }
                    
                }
            }catch{
                print("error")
            }
        }
        
    }
    
    @IBAction func done() {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
}
