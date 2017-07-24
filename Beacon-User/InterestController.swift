//
//  InterestController.swift
//  Beacon-User
//
//  Created by SSLAB on 2017/7/2.
//  Copyright © 2017年 SSLAB. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class InterestController: UIViewController {
    @IBOutlet weak var waitAI: UIActivityIndicatorView!

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var scoreSegment: UISegmentedControl!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    let imageView = UIImageView()
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    var questionNum = 0
    var interestValue = [0,0,0,0,0]
    let interestTitle = ["休閒","運動","旅遊","音樂","美食"]
    let interestContent = ["歌唱   閱讀   上網\n\n電視   聊天",
                           "球類   健身   游泳\n\n慢跑   登山",
                           "山景   海灘   風景\n\n血拼   異國",
                           "流行音樂   古典音樂   民族音樂\n\n自然風音樂   非主流音樂",
                           " 咖啡廳   中式料理   西式料理\n\n日式料理   異國料理"]
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.titleLabel.text = "Ｑ：請問您對於\(self.interestTitle[questionNum])，下面有幾項內容是您感興趣的？"
        self.contentLabel.text = self.interestContent[questionNum]
        self.waitAI.hidesWhenStopped = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        if self.questionNum == 3 {
            self.nextButton.setTitle("完成", for: .normal)
        }
        self.interestValue[questionNum] = self.scoreSegment.selectedSegmentIndex
        self.questionNum += 1
        if self.questionNum < 5 {
            self.titleLabel.text = "Ｑ：請問您對於\(self.interestTitle[questionNum])，下面有幾項內容是您感興趣的？"
            self.contentLabel.text = self.interestContent[questionNum]
            self.scoreSegment.selectedSegmentIndex = 0
        }else{
            //question done
            var interestScore = 0;
            var digitNum = 10000
            for k in self.interestValue {
                interestScore += k*digitNum
                digitNum /= 10
            }
            print(interestScore)
            
            //save info to database and get some value
            self.waitAI.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            ref.child("users").child((user?.uid)!).updateChildValues(["interestScore": interestScore])
            
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
                                self.waitAI.stopAnimating()
                                UIApplication.shared.endIgnoringInteractionEvents()
                                self.performSegue(withIdentifier: "Golist", sender: userinfo)
                            }
                        }
                    }).resume()
                }
            })
            //Go to ListController(Homepage)
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Golist" {
            let vc = segue.destination as! ListItemController
            vc.userInfo = sender as! Dictionary
            vc.imageView = self.imageView
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
