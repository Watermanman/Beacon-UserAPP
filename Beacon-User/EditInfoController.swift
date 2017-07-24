//
//  EditInfoController.swift
//  Beacon-User
//
//  Created by SSLAB on 2017/7/1.
//  Copyright © 2017年 SSLAB. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EditInfoController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ageSlider: UISlider!
    @IBOutlet weak var jobPickerTextField: UITextField!
  
    @IBOutlet weak var gender: UISegmentedControl!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UITextField!
    let job = ["服務業","軍公教","學生","上班族"]
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    var userImgString = ""
    var tmpImg = UIImageView()
    var userinfo = Dictionary<String, Any>()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = tmpImg.image
        self.userImgString = self.userinfo["image"] as? String ?? ""
        self.ageLabel.text = String(self.userinfo["age"] as? Int ?? 100)
        self.usernameLabel.text = self.userinfo["name"] as? String ?? ""
        self.jobPickerTextField.text = self.userinfo["job"] as? String ?? ""
        self.ageSlider.value = Float(self.ageLabel.text!)!
        let gender = userinfo["gender"] as! String
        if gender == "男"{
            self.gender.selectedSegmentIndex = 0
        }else{
            self.gender.selectedSegmentIndex = 1
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        let jobPickerview = UIPickerView()
        jobPickerview.delegate = self
        jobPickerTextField.inputView = jobPickerview
        // Do any additional setup after loading the view.
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
        jobPickerTextField.text = job[row]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func ageSlider(_ sender: UISlider) {
        let currentvalue = Int(sender.value)
        ageLabel.text = "\(currentvalue)"
    }
    
    @IBAction func editDone(){
        let user = Auth.auth().currentUser
        self.userinfo =
            [ "name": self.usernameLabel.text!,
              "age" : Int(self.ageLabel.text!) ?? 18,
              "job" : self.jobPickerTextField.text!,
              "image": self.userImgString,
              "gender": self.gender.titleForSegment(at: self.gender.selectedSegmentIndex) ?? 0,
              ]
        self.ref.child("users").child((user?.uid)!).updateChildValues(self.userinfo)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Editdone" {
            if let vc = segue.destination as? HomePageController{
                vc.userInfo = self.userinfo
                vc.tmpImg = self.imageView
            }
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
        let uniString = Auth.auth().currentUser?.uid ?? uniqueString
        // 當判斷有 selectedImage 時，我們會在 if 判斷式裡將圖片上傳
        if let selectedImage = selectedImageFromPicker {
//            let ai: UIActivityIndicatorView = UIActivityIndicatorView()
//            ai.hidesWhenStopped = true
//            ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//            ai.center = self.imageView.center
//            self.view.addSubview(ai)
//            ai.startAnimating()
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
                                        //ai.stopAnimating()
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
