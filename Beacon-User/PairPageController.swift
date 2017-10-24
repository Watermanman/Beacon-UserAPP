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
    var userAge = 0 //feature1
    var userScore = 0 //feature2
    var userLike: Array<String> = [] //feature3
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
            ref.child("users").child("\(self.userID)").observeSingleEvent(of: .value, with: { (snapshot) in
                self.userInfo = snapshot.value as! Dictionary<String, Any>
                self.userAge = self.userInfo["age"] as! Int
                self.userScore = self.userInfo["interestScore"] as! Int
                self.userLike = self.userInfo["userlike"] as! Array<String>
                self.beaconManger.startRangingBeacons(in: self.region)
                self.pairAction = false
                sender.setTitle("結束配對", for: .normal)
            })
        }else{
            self.beaconManger.stopMonitoring(for: self.region)
            self.beaconManger.stopRangingBeacons(in: self.region)
            self.Label.text = "配對已停止"
            self.pairAction = true
            self.inRegion = false
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
        //check someone pair witn me
        //...
        
        
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
                            let age = value?["age"] as! Int
                            let name = value?["name"] as! String
                            let score = value?["interestScore"] as! Int
                            var featureA = 0
                            var featureB = 0
                            var featureC = 0
                            
                            print("ID:\(getUserID) scoore:\(String(describing: score))")
                            
                            // FeatureA(Age)
                            let ageDiff = abs(self.userAge - age)
                            
                            switch ageDiff {
                            case 0...5:
                                featureA = 5
                            case 6...10:
                                featureA = 4
                            case 11...15:
                                featureA = 3
                            case 16...20:
                                featureA = 2
                            case 21...100:
                                featureA = 1
                            default:
                                featureA = 0
                            }
                            
                            // FeatureB(InterestScore)
                            var (pairString, pairInt) = self.pairUser(IntrsScore: score)
                            featureB = pairInt
                            
                            //                        if(pairInt >= 2){
                            //                            self.Label.text = "你與 \(String(describing: name)) 在\(pairString)興趣相合！"
                            //                        }
                            
                            //FeatureC(Facebook Like)
                            //Calculate Jacard similarity
                            var interaction = 0
                            var union = 0
                            var jacard = 0.0
                            if let arry = value?["userlike"] {
                                let like = arry as! Array<String>
                                union = like.count + self.userLike.count
                                for i in self.userLike {
                                    for k in like {
                                        if(i == k ){
                                            interaction += 1
                                            print("\(i)")
                                        }
                                    }
                                }
                            }else{
                                interaction = 0
                            }
                            if( union != 0){
                                jacard = Double(interaction / union)
                            }
                            
                            
                            
                            // Similarity
                            let similarity = Double(featureB) + jacard
                            print(similarity)
                            
                            if similarity > 1 {
                                self.Label.text = "你與 \(String(describing: name)) 在\(pairString)興趣相合！"
                                
                                let alertController = UIAlertController(title: "配對成功", message: "你要傳送要求給\(name)嗎？", preferredStyle: .alert)
                                let okayAction = UIAlertAction(title: "好", style: .default, handler: { (action)
                                    in
                                    self.ref.child("pair").child("\(self.userID)").setValue("\(getUserID)")
                                    self.catching = false
                                })
                                let cancelAction = UIAlertAction(title: "不要", style: .cancel, handler: { (action) in
                                    self.catching = false
                                })
                                alertController.addAction(okayAction)
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                            //self.catching = false
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
    
    func checkIndoor(){
        //Checking ever X second
    }
    
    func pairUser (IntrsScore: Int) -> (insterStrig: String, insterCount: Int){
        var scrA = IntrsScore
        var scrB = self.userScore
        var bitA = 0
        var bitB = 0
        var bits = 10000
        var count = 0
        var distance = 0.0
        var userDiff = [0,0,0,0,0]
        var pairStr = ["休閒","運動","旅遊","音樂","美食"]
        var strPair = " "
        for i in 0...4 {
            bitA = scrA / bits
            bitB = scrB / bits
            
            //get similar interesting
            let diff = abs(bitA - bitB)
            if(diff < 2){
                userDiff[i] = 1
            }
            
            //calculate 歐式距離
            distance += pow(Double(diff), 2.0)
            
            
            
            scrA %= bits
            scrB %= bits
            bits /= 10
        }
        var Euclidean = sqrt(distance)
        print ("\(Euclidean)")
        //get similar interesting info of String
        for i in 0...4 {
            if(userDiff[i] == 1){
                strPair += "\(pairStr[i]) "
                count += 1
            }
        }
        return (strPair, count)
    }
}
