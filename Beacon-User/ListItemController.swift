//
//  ListItemController.swift
//  Beacon-User
//
//  Created by SSLAB on 19/06/2017.
//  Copyright © 2017 SSLAB. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ListItemController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var imageView = UIImageView()
    
    var userInfo = Dictionary<String, Any>()
    @IBOutlet var homepageView: UIView!
    let list = ["首頁", "社交"]
    @IBOutlet var pairpageView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homepageView.frame = view.frame
        view.addSubview(homepageView)
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       // homepageView.frame = view.frame
       // view.addSubview(homepageView)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = list[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var tmpView: UIView!
        let workingView = view.subviews.last
        switch indexPath.row {
        case 0:
            tmpView = homepageView
        case 1:
            tmpView = pairpageView
        default:
            tmpView = homepageView
        }
        
        if workingView != tmpView {
            tmpView.frame = (workingView?.frame)!
            workingView?.removeFromSuperview()
            view.addSubview(tmpView)
            tmpView.subviews.last?.menu()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userinfo" {
            let nc = segue.destination as? UINavigationController
            if let vc = nc?.viewControllers[0] as? HomePageController {
                vc.userInfo = self.userInfo
                vc.tmpImg = self.imageView
            }
        }
        
    }
     

}
