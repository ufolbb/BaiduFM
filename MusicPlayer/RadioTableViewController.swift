//
//  RadioTableViewController.swift
//  MusicPlayer
//
//  Created by 廖彬彬 on 16/4/3.
//  Copyright © 2016年 廖彬彬. All rights reserved.
//

import UIKit

class RadioTableViewController: UITableViewController {

    func loadChannelList(){
        
        HttpRequest.getChannelList{ (channel) -> Void in
            if(channel == nil)
            {
                print("getChannelList failed")
                let alertController = Common.getAlertController("发生异常", message: "加载电台频道列表失败！", buttontext: "确定")
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            PlayCenter.instance.channelInfoList = channel!
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置返回按钮
        let returnButton = UIButton()
        returnButton.setTitle("返回", forState: UIControlState.Normal)
        returnButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        returnButton.titleLabel?.font = UIFont(name: "STHeiti-Medium", size: 12)
        returnButton.sizeToFit()
        returnButton.addTarget(self, action: #selector(self.didReturnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        let leftBarButtonItem = UIBarButtonItem(customView: returnButton)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        
        //获取电台列表
        self.loadChannelList()
    }
    
    @IBAction func didReturnClicked(sender: UIButton) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        let playController: PlayTabBarController = self.tabBarController as! PlayTabBarController
        playController.show()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return PlayCenter.instance.channelInfoList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let channel = PlayCenter.instance.channelInfoList[indexPath.row]
        cell.textLabel!.text = channel.name
        
        return cell
    }
 
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if PlayCenter.instance.avPlayer.rate == 1.0 {
            PlayCenter.instance.avPlayer.pause()
        }
        
        PlayCenter.instance.selectChannel = PlayCenter.instance.channelInfoList[indexPath.row]
        PlayCenter.instance.loadSongList(PlayCenter.instance.selectChannel.id)

        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tabBarController?.selectedIndex = 3
    }
}
