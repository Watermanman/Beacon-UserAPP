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

class EditInfoController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var ageSlider: UISlider!
    @IBOutlet weak var jobPickerTextField: UITextField!
  
    @IBOutlet weak var gender: UISegmentedControl!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UITextField!
    let job = ["服務業","軍公教","學生","上班族"]
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    var userinfo = Dictionary<String, Any>()
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
              "gender": self.gender.titleForSegment(at: self.gender.selectedSegmentIndex) ?? 0,
              ]
        self.ref.child("users").child((user?.uid)!).updateChildValues(self.userinfo)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Editdone" {
            if let vc = segue.destination as? HomePageController{
                vc.userInfo = self.userinfo
            }
        }
    }

}
