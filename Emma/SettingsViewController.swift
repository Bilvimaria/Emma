//
//  SettingsViewController.swift
//  Emma
//
//  Created by Bilvi Maria Joseph on 2019-02-28.
//  Copyright © 2019 Bilvi Maria Joseph. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var rowchecked: Bool = true
    var contentArray = ["Edit Contacts List", "Update Profile"]
    var segueIdentifiers = ["EditContacts", "UserInfo"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return contentArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsViewCell", for: indexPath)
        //cell.textLabel?.text = tableArray[indexPath.row]
        //return cell

        let label = cell.viewWithTag(1000) as! UILabel
        
        //use the below line instead of if-else if if no alarm is needed
        //label.text = contentArray[indexPath.row]
        
        if indexPath.row == 0 {
            label.text = contentArray[indexPath.row]
        } else if indexPath.row == 1 {
            label.text = contentArray[indexPath.row]
        } else if indexPath.row == 2 {
            label.text = "Alarm"
            cell.accessoryType = .checkmark
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        //use the below line instead of if-else if if no alarm is needed
       // performSegue(withIdentifier: segueIdentifiers[indexPath.row], sender: self)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsViewCell", for: indexPath)

        if indexPath.row == 0 {
            performSegue(withIdentifier: segueIdentifiers[indexPath.row], sender: self)
        } else if indexPath.row == 1 {
            performSegue(withIdentifier: segueIdentifiers[indexPath.row], sender: self)
            
            // TO DO : Need Correction
            
        } else if indexPath.row == 2 {
            rowchecked = !rowchecked
            if rowchecked {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
          tableView.deselectRow(at: indexPath, animated: true)
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
