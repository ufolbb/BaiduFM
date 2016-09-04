//
//  MainViewController.swift
//  MusicPlayer
//
//  Created by 廖彬彬 on 16/4/14.
//  Copyright © 2016年 廖彬彬. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        let leftBarButton = UIButton()
        leftBarButton.setTitle("本地音乐", forState: UIControlState.Normal)
        leftBarButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        leftBarButton.titleLabel?.font = UIFont(name: "STHeiti-Medium", size: 12)
        leftBarButton.sizeToFit()
        leftBarButton.addTarget(self, action: #selector(self.didLeftBarButtonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButton)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        
        let rightBarButton = UIButton()
        rightBarButton.setTitle("网络电台", forState: UIControlState.Normal)
        rightBarButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        rightBarButton.titleLabel?.font = UIFont(name: "STHeiti-Medium", size: 12)
        rightBarButton.sizeToFit()
        rightBarButton.addTarget(self, action: #selector(self.didRightBarButtonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        let rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @IBAction func didLeftBarButtonClicked(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pushViewController = storyboard.instantiateViewControllerWithIdentifier("MusicTableViewController")
        self.navigationController?.pushViewController(pushViewController, animated: true)
    }
    
    @IBAction func didRightBarButtonClicked(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pushViewController = storyboard.instantiateViewControllerWithIdentifier("RadioTableViewController")
        self.navigationController?.pushViewController(pushViewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        let playController: PlayTabBarController = self.tabBarController as! PlayTabBarController
        playController.show()
    }
}