//
//  EditContactsViewController.swift
//  Emma
//
//  Created by Bilvi Maria Joseph on 2019-02-28.
//  Copyright © 2019 Bilvi Maria Joseph. All rights reserved.
//


import UIKit
import Contacts
import ContactsUI
import CoreData

class EditContactsViewController: UITableViewController, CNContactPickerDelegate {
    var managedObjectContext: NSManagedObjectContext!
    var contactList : [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchEmergencyContactList()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = contactList[indexPath.row]
        cell.textLabel?.text = item.value(forKey: "name") as? String
        cell.detailTextLabel?.text = item.value(forKey: "phoneNumber") as? String
        return cell
    }
    //Mark: -swipe to delete row new
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let manageContext = appDelegate.persistentContainer.viewContext
            manageContext.delete(self.contactList[indexPath.row])
            do{
                try manageContext.save()
                manageContext.refreshAllObjects()
                self.contactList.removeAll()
                self.fetchEmergencyContactList()
                tableView.reloadData()
            }catch{
                print("Could not save after deleting row ")
            }
            
        }
    }
    
    func fetchEmergencyContactList(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let manageContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contact")
        
        do {
            contactList = try manageContext.fetch(fetchRequest)
        } catch let err as NSError{
            print("Failed to Fetch \(err)")
        }
    }

    @IBAction func addContact(_ sender: Any) {
        let entityType = CNEntityType.contacts
        let authStatus = CNContactStore.authorizationStatus(for: entityType)
        
        if authStatus == CNAuthorizationStatus.notDetermined{
            let contactStore = CNContactStore.init()
            contactStore.requestAccess(for: entityType) { (success, nil) in
                if success{
                    self.openContacts()
                }
                else{
                    print("Not Authorized")
                }
            }
        }
        else if authStatus == CNAuthorizationStatus.authorized{
            openContacts()
        }
    }
    
    func openContacts(){
        let contactPicker = CNContactPickerViewController.init()
        contactPicker.delegate = self
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        //ToDo:- dismiss had one more argument. Have to check that
        picker.dismiss(animated: true) {
            
        }
    }
    // MARK: - Selecting Single Contact
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let fullName = "\(contact.givenName) \(contact.familyName)"
        var phone = "Not Available"
        if !contact.phoneNumbers.isEmpty{
            let phoneString = (((contact.phoneNumbers[0] as AnyObject).value(forKey: "labelValuePair") as AnyObject).value(forKey: "value") as AnyObject).value(forKey: "stringValue")
            //ToDO: -Optional so do accordingly
            phone = phoneString as! String
        }
        let currentContactName = fullName
        
        let currentContactPhone = phone
        
        let newRowIndex = contactList.count
        self.save(currentContactName,currentContactPhone)
        //self.contactList1.append(currentContactItem)
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        
    }
    
    func save(_ contactName: String, _ contactPhone: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Contact", in: managedContext)!
        let singleContact = NSManagedObject(entity: entity, insertInto: managedContext)
        singleContact.setValue(contactName, forKey: "name")
        singleContact.setValue(contactPhone, forKey: "phoneNumber")
        
        do{
            try
                managedContext.save()
            print("Saved")
            print(applicationDocumentsDirectory)
                contactList.append(singleContact)
        }catch let err as NSError{
            print("Failed to save \(err)")
        }
    }
    
    @IBAction func done() {    
          navigationController?.popViewController(animated: true)
    }
}
