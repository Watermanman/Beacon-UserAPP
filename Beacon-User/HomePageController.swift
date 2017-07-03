//
//  HomePageController.swift
//  Beacon-User
//
//  Created by SSLAB on 14/06/2017.
//  Copyright © 2017 SSLAB. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class HomePageController: UIViewController {
    
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var featureLabel: UILabel!
    var userInfo = Dictionary<String, Any>()

    override func viewDidLoad() {
      
        super.viewDidLoad()
        print(userInfo)
        self.usernameLabel.text = userInfo["name"] as? String ?? ""
        self.jobLabel.text = userInfo["job"] as? String ?? ""
        let age = userInfo["age"] as? Int ?? 100
        let gender = userInfo["gender"] as? String ?? ""
        self.featureLabel.text = String(gender) + "性 " + String(age) + "歲"

        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Goedit" {
            let vc = segue.destination as? EditInfoController
            vc?.userinfo = self.userInfo
        }
    }
    
    @IBAction func menuClick(_ sender: Any) {
        navigationController?.view.menu()
    }
    @IBAction func logOutAction(_ sender: Any) {
        let user = Auth.auth()
        
        if user.currentUser != nil {
            do{
                try user.signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login")
                present(vc, animated: true, completion: nil)
            }catch let error as NSError{
                print(error.localizedDescription)
            }
        }
    }
    
    
}
