//
//  ViewController.swift
//  Beacon-User
//
//  Created by SSLAB on 13/06/2017.
//  Copyright © 2017 SSLAB. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var homepageView: UIView!
    
    
    let list = ["home", "pair"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        homepageView.frame = view.frame
//        view.addSubview(homepageView)
//    }

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
        let tmpView: UIView!
        let workingView = view.subviews.last
        
        switch indexPath.row {
        case 0:
            tmpView = homepageView
        default:
            tmpView = homepageView
        }
        
        if workingView != tmpView {
            tmpView.frame = (workingView?.frame)!
            workingView?.removeFromSuperview()
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

