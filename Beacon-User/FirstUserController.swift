//
//  FirstUserController.swift
//  Beacon-User
//
//  Created by SSLAB on 14/06/2017.
//  Copyright © 2017 SSLAB. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FBSDKLoginKit


class FirstUserController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var ref = Database.database().reference()
    @IBOutlet weak var jobPickerTextField: UITextField!
    let job = ["服務業","軍公教","學生","上班族"]
    var currentUserNum = 0
    var userID = 0
    var userLikes: Array<String> = []
    var userImgString = ""
    let currentUser = Auth.auth().currentUser
    @IBOutlet weak var gender: UISegmentedControl!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var ageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let jobPickerview = UIPickerView()
        jobPickerview.delegate = self
        jobPickerTextField.text = job[0]
        jobPickerTextField.inputView = jobPickerview
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        
        //Facebook login
        if let fbname = self.currentUser?.displayName {
            self.usernameLabel.text = fbname
        }
//        if let photoUrl = self.currentUser?.photoURL {
//            print(photoUrl)
//        }
        
        //================Info of Facebook==================
        if((FBSDKAccessToken.current()) != nil){
            //Get User Personal Info
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, first_name, last_name, email, gender"]).start(completionHandler: { (connection, userResult, error) in
                if(error == nil){
                    let fbUserInfo = userResult as! NSDictionary
                    //let name = fbUserInfo["name"] as! String
                    let fbUserID = fbUserInfo["id"] as! String
                    print(fbUserInfo)
                    
                    //Get User Likes
                    FBSDKGraphRequest(graphPath: "/\(fbUserID)/likes?limit=1000", parameters: ["fields" : "id,fan_count"], httpMethod: "GET").start(completionHandler: { (_ connection, result, error) in
                        if(error == nil){
                            
                            let result:Dictionary<String, AnyObject> = result as! Dictionary<String, AnyObject>
                            let arry = result["data"] as! NSArray
                            if arry.count > 0 {
                                for i in 0...arry.count - 1 {
                                    let fans = arry[i] as! NSDictionary
                                    if fans["fan_count"] as! Int > 1000000 {
                                        self.userLikes.append(fans["id"] as! String)
                                    }
                                }
                                if let nextCursor = result["paging"]!["next"]! as? String {
                                    self.parseUserlikes(nextpath: nextCursor)
                                }
                            }
                        }else{
                            print("\(String(describing: error?.localizedDescription))")
                        }
                    })
                    
                    

                }
            })
            
            
        }
    }
    
    
    func parseUserlikes(nextpath: String) {
        
        let url = URL(string: nextpath)
        let task = URLSession.shared.dataTask(with: url!)
        {(data, response, error) in
            guard let data = data, error == nil else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                
                let result:Dictionary<String, AnyObject> = json as Dictionary<String, AnyObject>
                
                let arry = result["data"] as! NSArray
                
                if( arry.count > 0 ){
                    for i in 0...arry.count - 1 {
                        let fans = arry[i] as! NSDictionary
                        if fans["fan_count"] as! Int > 1000000 {
                            //print(fans["id"]!)
                            self.userLikes.append(fans["id"] as! String)
                        }
                    }
                }
                
                if result["paging"] as? NSDictionary != nil {
                    if let nextCursor = result["paging"]!["next"]! as? String {
                        self.parseUserlikes(nextpath: nextCursor)
                    }else{
                        print(self.userLikes)
                        print(self.userLikes.count)
                    }
                }else{
                    print(self.userLikes)
                    print(self.userLikes.count)
                }
                
            } catch let error as NSError {
                print(error)
            }
            
        }
        task.resume()
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return job.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return job[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.jobPickerTextField.text = job[row]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    @IBAction func ageSlider(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        ageLabel.text = "\(currentValue)"
        
    }
    @IBAction func createUserData(){
        if self.usernameLabel.text == ""{
            let alertController = UIAlertController(title: "Error", message: "Please enter your username", preferredStyle: .alert)
            let delfaulAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(delfaulAction)
            present(alertController, animated: true, completion: nil)
        }else{
            let user = Auth.auth().currentUser
            let userinfo: Dictionary<String, Any> =
                [ "name": self.usernameLabel.text!,
                  "age" : Int(self.ageLabel.text!) ?? 18,
                  "job" : self.jobPickerTextField.text!,
                  "gender": self.gender.titleForSegment(at: self.gender.selectedSegmentIndex) ?? 0,
                  "image": self.userImgString,
                  "interestScore": 0,
                  "indoor": false,
                  "dirty" : false,
                  "userlike": self.userLikes]
       
            //create UserID in table
            self.ref.child("userNum").observeSingleEvent(of: .value, with: { (snapshot) in
                self.currentUserNum = snapshot.value as! Int
                self.userID = self.currentUserNum + 1
                self.ref.child("userNum").setValue(self.userID)
                self.ref.child("UID2NumID").child((user?.uid)!).setValue(self.userID)
                self.ref.child("users").child("\(self.userID)").setValue(userinfo)
                
                self.performSegue(withIdentifier: "Interest", sender: userinfo)
            })
            
            
            
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //undo
        if segue.identifier == "Golist" {
            let vc = segue.destination as! ListItemController
            vc.userInfo = sender as! Dictionary
            vc.imageView = self.imageView
            vc.userID = self.userID
        }
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //let tappedImage = tapGestureRecognizer.view as! UIImageView
        print("touch image")
        // 建立一個 UIImagePickerController 的實體
        let imagePickerController = UIImagePickerController()
        
        // 委任代理
        imagePickerController.delegate = self
        
        // 建立一個 UIAlertController 的實體
        // 設定 UIAlertController 的標題與樣式為 動作清單 (actionSheet)
        let imagePickerAlertController = UIAlertController(title: "上傳圖片", message: "請選擇要上傳的圖片", preferredStyle: .actionSheet)
        
        // 建立三個 UIAlertAction 的實體
        // 新增 UIAlertAction 在 UIAlertController actionSheet 的 動作 (action) 與標題
        let imageFromLibAction = UIAlertAction(title: "照片圖庫", style: .default) { (Void) in
            
            // 判斷是否可以從照片圖庫取得照片來源
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
                // 如果可以，指定 UIImagePickerController 的照片來源為 照片圖庫 (.photoLibrary)，並 present UIImagePickerController
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let imageFromCameraAction = UIAlertAction(title: "相機", style: .default) { (Void) in
            
            // 判斷是否可以從相機取得照片來源
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                // 如果可以，指定 UIImagePickerController 的照片來源為 照片圖庫 (.camera)，並 present UIImagePickerController
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        
        // 新增一個取消動作，讓使用者可以跳出 UIAlertController
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (Void) in
            imagePickerAlertController.dismiss(animated: true, completion: nil)
        }
        
        // 將上面三個 UIAlertAction 動作加入 UIAlertController
        imagePickerAlertController.addAction(imageFromLibAction)
        imagePickerAlertController.addAction(imageFromCameraAction)
        imagePickerAlertController.addAction(cancelAction)
        
        // 當使用者按下 uploadBtnAction 時會 present 剛剛建立好的三個 UIAlertAction 動作與
        present(imagePickerAlertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        // 取得從 UIImagePickerController 選擇的檔案
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = pickedImage
        }
        
        // 可以自動產生一組獨一無二的 ID 號碼，方便等一下上傳圖片的命名
        let uniqueString = NSUUID().uuidString
        let uniString = currentUser?.uid ?? uniqueString
        // 當判斷有 selectedImage 時，我們會在 if 判斷式裡將圖片上傳
        if let selectedImage = selectedImageFromPicker {
            UIApplication.shared.beginIgnoringInteractionEvents()
            self.imageView.image = #imageLiteral(resourceName: "loading")
            let storageRef = Storage.storage().reference().child("UserImages").child("\(uniString).png")
            if let uploadData = UIImagePNGRepresentation(selectedImage) {
                storageRef.putData(uploadData, metadata: nil, completion: { (data, error) in
                    
                    if error != nil {
                        print("Error: \(error!.localizedDescription)")
                        return
                        
                    }else{
                        //get image URL
                        if let imageString = data?.downloadURL()?.absoluteString {
                            self.userImgString = imageString
                            print("Photo Url: \(imageString)")
                            URLSession.shared.dataTask(with: URL(string: imageString)!, completionHandler: { (data, response, error) in
                                
                                if error != nil {
                                    print(error!.localizedDescription)
                                }else if let imgdata = data {
                                    DispatchQueue.main.sync {
                                        self.imageView.image = UIImage(data: imgdata)
                                        UIApplication.shared.endIgnoringInteractionEvents()
                                    }
                                }
                            }).resume()
                        }
                    }
                })
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
}
