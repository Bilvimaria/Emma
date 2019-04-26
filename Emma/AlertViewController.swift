//
//  ViewController.swift
//  Emma
//
//  Created by Bilvi Maria Joseph on 2019-02-/Users/bilvimariajoseph/Documents/iOS/Project Practise/Emma/Emma/GuidelineViewController.swift27.
//  Copyright © 2019 Bilvi Maria Joseph. All rights reserved.
//
import UIKit
import CoreLocation
import MessageUI
import CoreData
import AVFoundation

class AlertViewController: UIViewController, CLLocationManagerDelegate, MFMessageComposeViewControllerDelegate {

    //Mark:- AlertButton
    @IBOutlet weak var alertButton: UIButton!
    var isButtonClicked : Bool = false

    //Mark:- Alarm
    var audioPlayer = AVAudioPlayer()
    var alarmStatus : String = "Alarm Off"
    
     //Mark: - CoreData
    var managedObjectContext: NSManagedObjectContext!
    var contactList : [NSManagedObject] = []
    
    //Mark:- Location
    var addressString : String = ""
    var location: CLLocation?
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    var timer: Timer?
    var updatingLocation = false
    var lastLocationError: Error?
    let locationManager = CLLocationManager()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = UIColor(red:0.78, green:0.91, blue:0.89, alpha:1.0)
        fetchEmergencyContacts()
        setAlarm()
        setAudioPlayer()
        resetAlarm()
        alertButton.isUserInteractionEnabled = true
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        alertButton.addGestureRecognizer(longPress)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red:0.78, green:0.91, blue:0.89, alpha:1.0)
        fetchEmergencyContacts()
        setAlarm()
        setAudioPlayer()
        alertButton.isUserInteractionEnabled = true
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        alertButton.addGestureRecognizer(longPress)
    }
    
    //Mark:- Alert
    @IBAction func startAlert(){
        changeColor()
        alert()
        changeText()
    }
    
    //MARK:- Button Long press
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            callPhone()
            
        }
    }
    
    //Mark:- Button Shake
    override func becomeFirstResponder() -> Bool {
        return true
    }
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            alert()
            changeColor()
            changeText()
        }
    }
    
    //Mark: - Emergency Contacts
    func fetchEmergencyContacts(){
        let appDelegateforContact = UIApplication.shared.delegate as! AppDelegate
        let manageContextforContact = appDelegateforContact.persistentContainer.viewContext
        let fetchRequestforContact = NSFetchRequest<NSManagedObject>(entityName: "Contact")
        manageContextforContact.refreshAllObjects()
        
        do {
            contactList = try manageContextforContact.fetch(fetchRequestforContact)
        } catch let err as NSError{
            print("Failed to Fetch \(err)")
        }
    }
    
    func alert(){
        getLocation()
        toggleIsButtonClicked()
        resetAlarm()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.SMS()
        }
        sendSMS()
    }
    
    // MARK: - Location
    func getLocation(){
        //Authorization
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        if (error as NSError).code ==
            CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                stopLocationManager()
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            if !performingReverseGeocoding {
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: { placemarks, error in
                    self.lastGeocodingError = error
                    if error == nil, let p = placemarks, !p.isEmpty {
                        self.placemark = p.last!
                    } else {
                        self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.convertToAddress()
                })
            }
        } else if distance < 1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {
                print("*** Force done!")
                stopLocationManager()
            }
        }
    }
    
    // MARK:- Helper Methods for Location
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func convertToAddress() {
        if location != nil {
            if let placemark = placemark {
                addressString = string(from: placemark)
            } else if performingReverseGeocoding {
                addressString = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressString = "Error Finding Address"
            } else {
                addressString = "No Address Found"
            }
            
        } else {
            addressString = "Could not Find Address"
        }
    }
    
    //Mark:-start location manager
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        }
    }
    
    //Mark:- Stoplocation manager
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    //Mark :- Stoplocation manager
    @objc func didTimeOut() {
        print("*** Time out")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
        }
    }
    
    //To Do:- String Method : need to check the reverse geocoding again and and update the code
    func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        if let s = placemark.subThoroughfare {
            line1 += s + " "
        }
        if let s = placemark.thoroughfare {
            line1 += s
        }
        var line2 = ""
        if let s = placemark.locality {
            line2 += s + " "
        }
        if let s = placemark.administrativeArea {
            line2 += s + " "
        }
        if let s = placemark.postalCode {
            line2 += s
        }
        return line1 + "\n" + line2
    }
    
    // MARK:- SMS
    func sendSMS() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.SMS()
        }
    }
    
    func SMS() {
        if isButtonClicked{
            if contactList.isEmpty{
                showAlertPopUp()
            }else{
                if MFMessageComposeViewController.canSendText(){
                    
                    let controller = MFMessageComposeViewController()
                    controller.body = "I am at risk at \(self.addressString)"
                    controller.recipients = []
                    for contact in contactList{
                        controller.recipients?.append(contact.value(forKey: "phoneNumber") as! String)
                    }
                    controller.messageComposeDelegate = self
                    self.present(controller,animated:true,completion:nil)
                }else{
                    print("***can't send message***")
                }
                sendSMS()
            }
        }
    }
    // Dismisses the message composer when message sending is finished
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Helper Methods for Alert Button Apperance
    func changeColor(){
        if alertButton.currentBackgroundImage == UIImage(named: "orange"){
            alertButton.setBackgroundImage(UIImage(named: "green"), for: .normal)
        }
        else{
            alertButton.setBackgroundImage(UIImage(named: "orange"), for: .normal)
        }
    }
    
    func changeText(){
        if(isButtonClicked){
            alertButton.setTitle("Stop", for: .normal)
        }else{
           alertButton.setTitle("Alert", for: .normal)
        }
    }
    
    func  toggleIsButtonClicked(){
        if isButtonClicked {
            isButtonClicked = false
        }else{
            isButtonClicked = true
        }
    }

    //Mark: - Alarm
    func setAudioPlayer(){
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Siren", ofType: "mp3")!))
            audioPlayer.prepareToPlay()
            audioPlayer.numberOfLoops = -1
            audioPlayer.setVolume(1.0, fadeDuration: 0.1)
            let audioSession = AVAudioSession.sharedInstance()
            
            do{
                try audioSession.setCategory(.playback, mode: .default)
            }catch{
                print("error in loading category \(error)")
            }
        }catch {
            print("could not load audio player \(error)")
        }
    }
    
    func setAlarm(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Alarm")
        do{
            let result = try managedContext.fetch(fetchRequest)
            if result.count>0{
                alarmStatus = result[0].value(forKey: "isOn") as! String
                print("Updated after fetching in setalarm")
                print(applicationDocumentsDirectory)
            }else{
                let entity = NSEntityDescription.entity(forEntityName: "Alarm", in: managedContext)!
                let singleItem = NSManagedObject(entity: entity, insertInto: managedContext)
                singleItem.setValue("Alarm Off", forKey: "isOn")
                do{
                    try
                        managedContext.save()
                    print("Saved")
                    let result = try managedContext.fetch(fetchRequest)
                    alarmStatus = result[0].value(forKey: "isOn") as! String
//                    if test.count>0{
//                        alarmStatus = test[0].value(forKey: "isOn")as! String
//                    }
                     print("Updated after creating in set alarm")
                    print(applicationDocumentsDirectory)
                }catch let err as NSError{
                    print("Failed to add alarm \(err)")
                }
            }
        }catch{
            print("error")
        }
    }
    
    func  resetAlarm(){
        if isButtonClicked{
            startAudio()
        }
        else{
            stopAudio()
        }
    }
    
   func startAudio(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Alarm")
        do{
            let test = try managedContext.fetch(fetchRequest)
            if test.count>0{
                let temp = test[0].value(forKey: "isOn") as! String
                if temp == "Alarm On" {
                    // audioPlayer.setVolume(0.8, fadeDuration: 0.1)
                    audioPlayer.play()
                }
                print(applicationDocumentsDirectory)
            }
            alarmStatus = test[0].value(forKey: "isOn") as! String
        }catch{
            print("Error")
        }
    }
    
 func stopAudio(){
        if audioPlayer.isPlaying && !isButtonClicked{
            audioPlayer.stop()
            
        }
    }
    func callPhone() {
        if let url = URL(string: "tel:7053135306") {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    func showAlertPopUp() {
        let title = "Warning"
        let message = "You haven't selected emergency contacts. Add emergency contacts list before you tap the button"
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default,
                                   handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
