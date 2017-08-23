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
    var userID = 0
    var userScore = 0
    var count = 0
    var catching = false
    var pairAction = true
    var inRegion = false
    var userInfo = Dictionary<String, Any>()
    var user = Auth.auth().currentUser
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "ownBeacon")

    @IBOutlet weak var Label: UILabel!
    
    @IBAction func startPairAction(_ sender: UIButton) {
        print("hello!")
        if(pairAction){
            self.Label.text = "正在確認你的位置..."
            self.userScore = self.userInfo["interestScore"] as! Int
            self.beaconManger.startRangingBeacons(in: self.region)
            self.pairAction = false
            sender.setTitle("結束配對", for: .normal)
        }else{
            
            self.beaconManger.stopMonitoring(for: self.region)
            self.beaconManger.stopRangingBeacons(in: self.region)
            self.Label.text = "配對已停止"
            self.pairAction = true
            sender.setTitle("尋找配對", for: .normal)
            self.ref.child("users").child("\(self.userID)").updateChildValues(["indoor": false])
        }
        
        //get estimote cloud beacons list
//        self.ownBeaconlistID = []
//        let Request = ESTRequestV2GetDevices()
//        Request.sendRequest { ( list: [ESTDeviceDetails]?, error: Error?) in
//            if list != nil {
//                for beaconList in list! {
//                    self.ownBeaconlistID.append(beaconList.identifier)
//                    print(beaconList.identifier)
//                }
//                self.deviceManger.startDeviceDiscovery(with: ESTDeviceFilterLocationBeacon(identifiers: self.ownBeaconlistID))
//                print("Start to scan...")
//            }
//        }
        
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
            //self.beaconManger.startRangingBeacons(in: self.region)
            self.Label.text = "Start Pair"
            self.beaconManger.startMonitoring(for: self.region)
            self.ref.child("users").child("\(self.userID)").updateChildValues(["indoor": true])
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
        inRegion = false
        self.beaconManger.stopRangingBeacons(in: self.region)
        self.ref.child("users").child("\(self.userID)").updateChildValues(["indoor": false])
        self.Label.text = "Leave the region"
        self.beaconManger.stopMonitoring(for: self.region)
    }
    
    func beaconManager(_ manager: Any, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        
        if !inRegion {
            inRegion = true
            self.Label.text = "尋找中..."
            self.beaconManger.startMonitoring(for: self.region)
            self.ref.child("users").child("\(self.userID)").updateChildValues(["indoor": true])
        }
        
        if(!self.catching){
            self.catching = true
        if let nearestBeacon = beacons.first {
            count += 1
            print(nearestBeacon.proximityUUID)
            print("\(count) @@=>\(nearestBeacon.major) \(nearestBeacon.minor)")
            
            if let getUserID = nearestBeacon.major as? Int {
                if(getUserID != self.userID){
                    ref.child("users").child("\(getUserID)").observeSingleEvent(of: .value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        let name = value?["name"] as! String
                        let score = value?["interestScore"] as! Int
                        print("ID:\(getUserID) scoore:\(String(describing: score))")
                        var pair = self.pairUser(IntrsScore: score)
                        if(pair.characters.count >= 7){
                            self.Label.text = "你與 \(String(describing: name)) 在\(pair)興趣相合！"
                        }
                        self.catching = false
                    })
                }
            }
            
            
//            if let temp = nearestBeacon.minor as? Int {
//                var pair = pairUser(IntrsScore: temp)
//                print("\(pair) \(pair.characters.count)")
//                
//                if(pair.characters.count >= 7){
//                    //興趣相符
//                    ref.child("users").child("\(nearestBeacon.major)").observeSingleEvent(of: .value, with: { (snapshot) in
//                        let value = snapshot.value as? NSDictionary
//                        let tempScore = value?["interestScore"] as? Int
//                        if( tempScore == Int(nearestBeacon.minor) && self.userID != Int(nearestBeacon.major)){
//                            //確認資料無誤差
//                            let name = value?["name"] as? String
//                            self.Label.text = "你與 \(String(describing: name!)) 在\(pair)興趣相合！"
//                        
//                        }
//                    })
//                    
//                }
//            }else{
//                self.Label.text = "Pair Error!!"
//            }
            
            
        }
        }
    }
    
    func pairUser (IntrsScore: Int) -> String{
        var scrA = IntrsScore
        var scrB = self.userScore
        var bitA = 0
        var bitB = 0
        var bits = 10000
        var userDiff = [0,0,0,0,0]
        var pairStr = ["休閒","運動","旅遊","音樂","美食"]
        var strPair = " "
        for i in 0...4 {
            bitA = scrA / bits
            bitB = scrB / bits
            let diff = abs(bitA - bitB)
            if(diff < 2){
                userDiff[i] = 1
            }
            scrA %= bits
            scrB %= bits
            bits /= 10
        }
        for i in 0...4 {
            if(userDiff[i] == 1){
                strPair += "\(pairStr[i]) "
            }
        }
        return strPair
    }
}
