//
//  TestingViewController.swift
//  Emma
//
//  Created by Bilvi Maria Joseph on 2019-02-28.
//  Copyright © 2019 Bilvi Maria Joseph. All rights reserved.
//

import UIKit

class TestingViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    var tableArray = ["Edit Contacts List", "Update Profile", "Table View Trial"]
    var segueIdentifiers = ["A", "B", "C"]
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return tableArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = tableArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
performSegue(withIdentifier: segueIdentifiers[indexPath.row], sender: self)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
