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



class PairPageController: UIViewController , ESTDeviceManagerDelegate, ESTDeviceConnectableDelegate, ESTBeaconManagerDelegate{
    
    var deviceManger: ESTDeviceManager!
    var beaconManger = ESTBeaconManager()
    var ownCLBeacon: Array<CLBeaconRegion>! = []
    var ownBeaconlistID: Array<String>! = []
    var ref = Database.database().reference()
    var user = Auth.auth().currentUser
    
    @IBOutlet weak var Label: UILabel!
    
    @IBAction func startPairAction(_ sender: Any) {
        print("hello!")
        //get estimote cloud beacons list
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
        self.beaconManger.startMonitoring(for: CLBeaconRegion(
            proximityUUID: UUID(uuidString: "AAA07F30-F5F8-466E-AFF9-25556B57FE6D")!,major: 36, minor: 35903,identifier: "monitored region"))
        
        
    }

    //discover device
    func deviceManager(_ manager: ESTDeviceManager, didDiscover devices: [ESTDevice]) {
        guard let beacon = devices.first as? ESTDeviceLocationBeacon else { return }
        
        print("Get beacon ID: \(beacon.identifier)")
        
        
        self.deviceManger.stopDeviceDiscovery()
        
        self.ref.child("users").child((user?.uid)!).updateChildValues(["indoor": true])
        
        beacon.delegate = self

        beacon.connect()
    }
    
    func estDeviceConnectionDidSucceed(_ device: ESTDeviceConnectable) {
        print("Connected")
        guard let beacon_connected = device as? ESTDeviceLocationBeacon else { return }
        print("after connect:\(beacon_connected.settings?.iBeacon.major.getValue())")
        beacon_connected.settings?.iBeacon.major.readValue(completion: { (_ major: ESTSettingIBeaconMajor?, _ error: Error?) in
            print(major?.getValue())
        })
    }
    
    func estDevice(_ device: ESTDeviceConnectable,
                   didFailConnectionWithError error: Error) {
        print("Connnection failed with error: \(error)")
    }
    
    func estDevice(_ device: ESTDeviceConnectable,
                   didDisconnectWithError error: Error?) {
        print("Disconnected")
        // disconnection can happen via the `disconnect` method
        //     => in which case `error` will be nil
        // or for other reasons
        //     => in which case `error` will say what went wrong
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
        print("leave@@")
        self.Label.text = "Leave the region"
    }
}
