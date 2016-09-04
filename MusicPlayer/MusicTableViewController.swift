//
//  MusicTableViewController.swift
//  MusicPlayer
//
//  Created by 廖彬彬 on 16/4/3.
//  Copyright © 2016年 廖彬彬. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class MusicTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var selectView: Int = 0
    
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView的设置
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        //let nib = UINib(nibName: "MusicTableViewCell", bundle: nil) //Cell文件名
        self.tableView.registerNib(UINib(nibName: "MusicTableViewCell", bundle: nil), forCellReuseIdentifier: "MusicTableViewCellID")
        self.tableView.registerNib(UINib(nibName: "MusicDownloadingCell", bundle: nil), forCellReuseIdentifier: "MusicDownloadingCellID")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        self.tableView.reloadData()
        
        self.setSelected()

        //设置返回按钮
        let returnButton = UIButton()
        returnButton.setTitle("返回", forState: UIControlState.Normal)
        returnButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        returnButton.titleLabel?.font = UIFont(name: "STHeiti-Medium", size: 12)
        returnButton.sizeToFit()
        returnButton.addTarget(self, action: #selector(self.didReturnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        let leftBarButtonItem = UIBarButtonItem(customView: returnButton)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        
        //设置SegmentedControl
        let midBarControl = UISegmentedControl(frame: CGRectMake(5, 10, 150, 30))
        midBarControl.insertSegmentWithTitle("已下载", atIndex: 0, animated: true)
        midBarControl.insertSegmentWithTitle("正在下载", atIndex: 1, animated: true)
        midBarControl.tintColor = UIColor.whiteColor()
        midBarControl.selectedSegmentIndex = 0
        midBarControl.addTarget(self, action: #selector(self.segmentValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.navigationItem.titleView = midBarControl
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.PlayStatus(_:)), name: "PlayStatusNotification", object: nil)
    }
    
    func setSelected() {
        dispatch_async(dispatch_get_main_queue()) {
            if self.selectView == 0 {
                //初始化当前播放的选中状态
                if PlayCenter.instance.selectChannel == nil {
                    let rowIndex = NSIndexPath(forRow: PlayCenter.instance.selectSongIndex, inSection: 0)
                    self.tableView.selectRowAtIndexPath(rowIndex, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
                }
            }
        }
    }
    
    //播放状态通知
    func PlayStatus(notification: NSNotification) {
        
        if notification.userInfo!.keys.contains("status") {
            let status = notification.userInfo!["status"] as! AVPlayerStatus.RawValue
            
            switch (status) {
            case AVPlayerStatus.ReadyToPlay.rawValue:
                self.setSelected()
                
            default:
                true
            }
        }
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.DownloadProgress(_:)), name: "DownloadProgressNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.DownloadStatus(_:)), name: "DownloadStatusNotification", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "DownloadProgressNotification", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "DownloadStatusNotification", object: nil)
    }
    
    func DownloadStatus(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            if self.selectView == 0 {
                return
            }
            
            let id = notification.userInfo!["id"] as! String
            let status = notification.userInfo!["status"] as! Bool
            
            if !DownloadCenter.instance.downloadingList.keys.contains(id) {
                self.tableView.reloadData()
                return
            }
            
            let ids = Array(DownloadCenter.instance.downloadingList.keys)
            let row: Int = ids.indexOf(id)!
            let indexPath = NSIndexPath.init(forRow: row, inSection: 0)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        
            if cell != nil {
                (cell as! MusicDownloadingCell).SetPause()
            }
        
            if status {
                self.tableView.reloadData()
            }
        }
    }
    
    func DownloadProgress(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            if self.selectView == 0 {
                return
            }
            
            let id = notification.userInfo!["id"] as! String
            let bytesRead = notification.userInfo!["bytesRead"] as! Int
            let totalBytesRead = notification.userInfo!["totalBytesRead"] as! Int
            let totalBytesExpectedToRead = notification.userInfo!["totalBytesExpectedToRead"] as! Int
        
            if !DownloadCenter.instance.downloadingList.keys.contains(id) {
                return
            }
            
            let ids = Array(DownloadCenter.instance.downloadingList.keys)
            let row: Int = ids.indexOf(id)!
            let indexPath = NSIndexPath.init(forRow: row, inSection: 0)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        
            if cell != nil {
                (cell as! MusicDownloadingCell).SetProgress(bytesRead, totalBytesRead: totalBytesRead, totalBytesExpectedToRead: totalBytesExpectedToRead)
            }
        }
    }

    @IBAction func segmentValueChanged(sender: UISegmentedControl) {
        self.selectView = sender.selectedSegmentIndex
        self.tableView.reloadData()
        
        self.setSelected()
    }
    
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.selectView == 0 {
            return DownloadCenter.instance.downloadedList.count
        }
        else if self.selectView == 1 {
            return DownloadCenter.instance.downloadingList.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.selectView == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("MusicTableViewCellID", forIndexPath: indexPath) as! MusicTableViewCell
            let ids = Array(DownloadCenter.instance.downloadedList.keys)
            let musicInfo = DownloadCenter.instance.downloadedList[ids[indexPath.row]]
            cell.id = (musicInfo?.id)!
            cell.titleLabel.text = musicInfo!.name
            cell.contentLabel.text = "  " + (musicInfo!.artistName == nil ? "未知" : musicInfo!.artistName!) + " ● " + (musicInfo!.albumName == nil ? "未知" : musicInfo!.albumName!)
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MusicDownloadingCellID", forIndexPath: indexPath) as! MusicDownloadingCell
            let ids = Array(DownloadCenter.instance.downloadingList.keys)
            let musicInfo = DownloadCenter.instance.downloadingList[ids[indexPath.row]]
            cell.selectionStyle = .None
            cell.id = (musicInfo?.id)!
            cell.progressBar.progress = musicInfo!.progress!.floatValue
            cell.contentLabel.text = musicInfo!.name
            
            let totalRead = String(format: "%.2f", Float(musicInfo!.bytesRead!) / 1024 / 1024)
            let fileLength = String(format: "%.2f", Float(musicInfo!.bytesTotal!) / 1024 / 1024)
            cell.infoLabel.text = "\(totalRead)M/\(fileLength)M"
            
            cell.SetPause()
            if DownloadCenter.instance.downloadRequset.keys.contains(cell.id) {
                if DownloadCenter.instance.downloadRequset[cell.id]!.task.state == .Running {
                    cell.SetRunning()
                }
            }
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        if self.selectView == 0 {
            if PlayCenter.instance.avPlayer.rate == 1.0 {
                PlayCenter.instance.avPlayer.pause()
            }
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! MusicTableViewCell
            let musicInfo = DownloadCenter.instance.downloadedList[cell.id]
            
            PlayCenter.instance.selectChannel = nil
            PlayCenter.instance.loadSongList("")
            
            PlayCenter.instance.selectSongIndex = PlayCenter.instance.songList.indexOf(musicInfo!.id!)!
            PlayCenter.instance.playWithUrl(musicInfo!.id!, url: musicInfo!.url!)
        }
        
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.selectView == 0 {
            self.tabBarController?.selectedIndex = 3
        }
        else if self.selectView == 1 {
            //let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            //cell?.selected = false
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .Normal, title: "删除") { action, index in
            var id: String
            if self.selectView == 0 {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! MusicTableViewCell
                id = cell.id
            }
            else {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! MusicDownloadingCell
                id = cell.id
            }
            
            DownloadCenter.instance.DeleteMusic(id)
            self.tableView.reloadData()
        }
        delete.backgroundColor = UIColor.redColor()
        
        return [delete]
    }
}