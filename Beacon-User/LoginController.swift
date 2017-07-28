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

class LoginController: UIViewController {
    @IBOutlet weak var loginAI: UIActivityIndicatorView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let imageView = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginAI.hidesWhenStopped = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
//                    ref.child("UID2NumID").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
//                        let NumID = snapshot.value as? NSDictionary ?? [:]
//                        if NumID.count < 1 {
//                            //New User
//                        }else{
//                            //Extied User
//                            
//                            ref.child("users").child(NumID)
//                        }
//                    })
                    ref.child("users").child((user?.uid)!).observeSingleEvent(of: .value, with: { (DataSnapshot) in
                        let userinfo = DataSnapshot.value as? NSDictionary ?? [:]
                        print(userinfo.count)
                        if userinfo.count < 1 {
                            //new user
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Welcome")
                            self.present(vc!, animated: true, completion: nil)
                            UIApplication.shared.endIgnoringInteractionEvents()
                            //self.performSegue(withIdentifier: "Welcome", sender: Any?.self)
                        }else{
                            //Extied user
                            //get userinfo to next page

//                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "List")
//                            self.present(vc!, animated: true, completion: nil)
                            
                            ref.child("users").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
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
                                    self.performSegue(withIdentifier: "List", sender: userinfo)
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                }
                                
                                
                            })
                           
                        }
                    })
                    
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
