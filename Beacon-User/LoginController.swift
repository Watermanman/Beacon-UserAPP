//
//  LoginController.swift
//  Beacon-User
//
//  Created by SSLAB on 14/06/2017.
//  Copyright © 2017 SSLAB. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit

class LoginController: UIViewController {
    @IBOutlet weak var loginAI: UIActivityIndicatorView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let imageView = UIImageView()
    var currentUserNum = 0
    var userID = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginAI.hidesWhenStopped = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func facebookLogin(sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "user_likes"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                
//                if((FBSDKAccessToken.current()) != nil){
//                    FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, first_name, last_name, email, gender, age_range"]).start(completionHandler: { (connection, userResult, error) in
//                        if(error == nil){
//                            
//                            let fbUserInfo = userResult as? NSDictionary
//                            print(fbUserInfo)
//                            
//    
//                        }
//                        
//                    })
//                    
//                    FBSDKGraphRequest(graphPath: "/1524655197596107/likes", parameters: ["fields" : "data"], httpMethod: "GET").start(completionHandler: { (_ connection, result, error) in
//                        if(error == nil){
//                            print(result)
//                        }else{
//                            print("\(error?.localizedDescription)")
//                        }
//                    })
//                   
//                    
//                }
                
                // Present the main view
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Welcome")
                self.present(vc!, animated: true, completion: nil)
                
            })
            
        }   
    }
    
    @IBAction func checkAcCountAction(){
        view.endEditing(true)

        
        if self.emailTextField.text == "" || self.passwordTextField.text == ""{
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            let delfaulAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(delfaulAction)
            present(alertController, animated: true, completion: nil)
        }else{
        
            self.loginAI.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                if error == nil {
                    //successfully
                    print("LOGIN")
                    
//                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Welcome")
//                    self.present(vc!, animated: true, completion: nil)
                    
                    let ref = Database.database().reference()
                ref.child("UID2NumID").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                        let value = snapshot.value as? Int ?? -1
                    
                        if value < 0 {
                            //New User
                            
//                            //create UserID in table
//                            ref.child("userNum").observeSingleEvent(of: .value, with: { (snapshot) in
//                                self.currentUserNum = snapshot.value as! Int
//                                ref.child("userNum").setValue(self.currentUserNum + 1)
//                                ref.child("UID2NumID").child((user?.uid)!).setValue(self.currentUserNum + 1)
//                            })
                    
                           
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Welcome")
                            self.present(vc!, animated: true, completion: nil)
                            UIApplication.shared.endIgnoringInteractionEvents()
                        }else{
                            //Extied User
                            self.userID = value
                            ref.child("users").child("\(self.userID)").observeSingleEvent(of: .value, with: { (snapshot) in
                                // Get user value
                                let userinfo = snapshot.value as? NSDictionary
                                
                                let imageString = userinfo?["image"] as? String ?? ""
                                if imageString != "" {
                                    URLSession.shared.dataTask(with: URL(string: imageString)!, completionHandler: { (data, response, error) in
                                        
                                        if error != nil {
                                            print(error!.localizedDescription)
                                        }else if let imgdata = data {
                                            DispatchQueue.main.sync {
                                                self.imageView.image = UIImage(data: imgdata)
                                                self.loginAI.stopAnimating()
                                                UIApplication.shared.endIgnoringInteractionEvents()
                                                self.performSegue(withIdentifier: "List", sender: userinfo)
                                            }
                                        }
                                    }).resume()
                                }else{
                                    self.imageView.image = #imageLiteral(resourceName: "user3")
                                    self.loginAI.stopAnimating()
                                    self.performSegue(withIdentifier: "List", sender: userinfo)
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                }
                            })
                            
                        }
                    })
                
//                    ref.child("users").child((user?.uid)!).observeSingleEvent(of: .value, with: { (DataSnapshot) in
//                        let userinfo = DataSnapshot.value as? NSDictionary ?? [:]
//                        print(userinfo.count)
//                        if userinfo.count < 1 {
//                            //new user
//                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Welcome")
//                            self.present(vc!, animated: true, completion: nil)
//                            UIApplication.shared.endIgnoringInteractionEvents()
//                            //self.performSegue(withIdentifier: "Welcome", sender: Any?.self)
//                        }else{
//                            //Extied user
//                            //get userinfo to next page
//                            
//                            ref.child("users").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
//                                // Get user value
//                                let userinfo = snapshot.value as? NSDictionary
//                                
//                                let imageString = userinfo?["image"] as? String ?? ""
//                                if imageString != "" {
//                                    URLSession.shared.dataTask(with: URL(string: imageString)!, completionHandler: { (data, response, error) in
//                                        
//                                        if error != nil {
//                                            print(error!.localizedDescription)
//                                        }else if let imgdata = data {
//                                            DispatchQueue.main.sync {
//                                                self.imageView.image = UIImage(data: imgdata)
//                                                self.loginAI.stopAnimating()
//                                                UIApplication.shared.endIgnoringInteractionEvents()
//                                                self.performSegue(withIdentifier: "List", sender: userinfo)
//                                            }
//                                        }
//                                    }).resume()
//                                }else{
//                                    self.imageView.image = #imageLiteral(resourceName: "user3")
//                                    self.performSegue(withIdentifier: "List", sender: userinfo)
//                                    UIApplication.shared.endIgnoringInteractionEvents()
//                                }
//                                
//                                
//                            })
//                           
//                        }
//                    })
                    
                }else{
                    self.loginAI.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "List" {
            let vc = segue.destination as! ListItemController
            vc.userInfo = sender as! Dictionary
            vc.imageView = self.imageView
            vc.userID = self.userID
        }
        
    }
//    @IBAction func check1(_ sender: UIButton) {
//        if sender.isSelected {
//            sender.isSelected = false
//            sender.backgroundImage(for: UIControlState.normal)
//        }else{
//            sender.isSelected = true
//            sender.backgroundImage(for: UIControlState.selected)
//        }
//    }
    
    @IBAction func resetPassword(_ sender: Any) {
        if self.emailTextField.text == "" {
            let alertController = UIAlertController(title: "Oops!", message: "Please enter an email.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            Auth.auth().sendPasswordReset(withEmail: self.emailTextField.text!, completion: { (error) in
                
                var title = ""
                var message = ""
                
                if error != nil {
                    title = "Error!"
                    message = (error?.localizedDescription)!
                } else {
                    title = "Success!"
                    message = "Password reset email sent."
                    self.emailTextField.text = ""
                }
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            })
        }
    }
    
}
