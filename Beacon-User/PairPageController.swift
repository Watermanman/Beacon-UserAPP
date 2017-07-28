//
//  PairPageController.swift
//  Beacon-User
//
//  Created by SSLAB on 19/06/2017.
//  Copyright © 2017 SSLAB. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth



class PairPageController: UIViewController , ESTDeviceManagerDelegate, ESTBeaconManagerDelegate{
    
    var deviceManger: ESTDeviceManager!
    var beaconManger = ESTBeaconManager()
    var ownDLBeacon: Array<ESTDeviceLocationBeacon>! = []
    var ownBeaconlistID: Array<String>! = []
    var ref = Database.database().reference()
    var user = Auth.auth().currentUser
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "ownBeacon")

    @IBOutlet weak var Label: UILabel!
    
    @IBAction func startPairAction(_ sender: Any) {
        print("hello!")
        self.Label.text = "正在確認你的位置..."
        //get estimote cloud beacons list
        self.ownBeaconlistID = []
        let Request = ESTRequestV2GetDevices()
        Request.sendRequest { ( list: [ESTDeviceDetails]?, error: Error?) in
            if list != nil {
                for beaconList in list! {
                    self.ownBeaconlistID.append(beaconList.identifier)
                    print(beaconList.identifier)
                }
                self.deviceManger.startDeviceDiscovery(with: ESTDeviceFilterLocationBeacon(identifiers: self.ownBeaconlistID))
                print("Start to scan...")
            }
        }
        
    }
    @IBAction func menuClick(_ sender: Any) {
        navigationController?.view.menu()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.deviceManger = ESTDeviceManager()
        self.deviceManger.delegate = self
        
        self.beaconManger.delegate = self
        self.beaconManger.requestAlwaysAuthorization()
        
//        self.beaconManger.startMonitoring(for: CLBeaconRegion(
//            proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!,major: 20 , minor: 666,identifier: "monitored region"))
        
        //self.beaconManger.startMonitoring(for: self.region)
        
    }

    //discover device
    func deviceManager(_ manager: ESTDeviceManager, didDiscover devices: [ESTDevice]) {
        guard let beacon = devices.first as? ESTDeviceLocationBeacon else { return }
        self.deviceManger.stopDeviceDiscovery()
        
        print("Get beacon ID: \(beacon.identifier)")
        if self.ownBeaconlistID.count > 1 {
            print(ownBeaconlistID)
            if self.ownBeaconlistID.contains(beacon.identifier) {
                self.ownBeaconlistID = self.ownBeaconlistID.filter{ $0 != beacon.identifier }
                self.deviceManger.startDeviceDiscovery(with: ESTDeviceFilterLocationBeacon(identifiers: self.ownBeaconlistID))
            }
        }else{
            //Start to pair
            self.beaconManger.startRangingBeacons(in: self.region)
            self.Label.text = "Start Pair"
            self.beaconManger.startMonitoring(for: self.region)
            self.ref.child("users").child((user?.uid)!).updateChildValues(["indoor": true])
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.Label.text = "startRanging"
//        self.beaconManger.startRangingBeacons(in: self.region)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func beaconManager(_ manager: Any, didEnter region: CLBeaconRegion) {
        
        print("enter@@")
        self.Label.text = "Enter the region"
        
    }
    
    func beaconManager(_ manager: Any, didExitRegion region: CLBeaconRegion) {
        self.ref.child("users").child((user?.uid)!).updateChildValues(["indoor": false])
        self.beaconManger.stopRangingBeacons(in: self.region)
        
        self.Label.text = "Leave the region"
        self.beaconManger.stopMonitoring(for: self.region)
    }
    
    func beaconManager(_ manager: Any, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        if let nearestBeacon = beacons.first {
            print(nearestBeacon.proximityUUID)
            print("@@=>\(nearestBeacon.major) \(nearestBeacon.minor)")
            self.Label.text = "\(nearestBeacon.major) \(nearestBeacon.minor)"
            
            
        }
        
    }
}
