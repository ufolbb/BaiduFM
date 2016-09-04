//
//  PlayController.swift
//  MusicPlayer
//
//  Created by 廖彬彬 on 16/4/13.
//  Copyright © 2016年 廖彬彬. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class PlayTabBarController: UITabBarController, UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate {
    
    var myView: UIView!
    var songImgButton: UIButton!
    var artistLabel: UILabel!
    var songNameLabel: UILabel!
    var playButton: UIButton!
    var musicListButton: UIButton!
    
    var musicListBackView: UIView!
    var musicListFrontView: UIView!
    var toolBar: UIToolbar!
    var closeButton: UIButton!
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //加载本地音乐到播放列表
        PlayCenter.instance.loadSongList("")
        
        //初始化音乐播放视图控制器
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let playMusicViewController = storyboard.instantiateViewControllerWithIdentifier("PlayMusicViewController")
        let navPlayMusicController = UINavigationController(rootViewController: playMusicViewController)
        navPlayMusicController.title="音乐播放"
        self.viewControllers?.append(navPlayMusicController)
        
        self.initPlayControllerView()
        self.initMusicListView()
        
        self.showInfo()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.PlayStatus(_:)), name: "PlayStatusNotification", object: nil)
    }
    
    func initPlayControllerView() {
        //删除现有的tabBar
        let rect = self.tabBar.frame
        self.tabBar.removeFromSuperview()
        
        self.myView = UIView(frame: CGRectMake(rect.origin.x, rect.origin.y - 10, rect.size.width, rect.size.height + 10));
        self.myView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        self.view.addSubview(self.myView)
        
        let commonLength = self.myView.frame.size.height - 10
        
        //歌曲图片
        self.songImgButton = UIButton(type: UIButtonType.Custom)
        self.songImgButton.frame = CGRectMake(10, 5, commonLength, commonLength);
        self.songImgButton.setImage(UIImage(named: "noimage"), forState: UIControlState.Normal)
        //把Button设置为圆形
        self.songImgButton.layer.cornerRadius = self.songImgButton.frame.size.width / 2
        self.songImgButton.clipsToBounds = true;
        //设置Button边框颜色和宽度
        self.songImgButton.layer.borderWidth = 1;
        self.songImgButton.layer.borderColor = UIColor.whiteColor().CGColor;
        self.songImgButton.addTarget(self, action: #selector(self.didSongImgClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.myView.addSubview(self.songImgButton)
        
        //显示歌曲列表按钮
        self.musicListButton = UIButton(type: UIButtonType.Custom)
        self.musicListButton.setImage(UIImage(named: "queue_music"), forState: UIControlState.Normal)
        self.musicListButton.frame = CGRectMake(self.myView.frame.size.width - self.myView.frame.size.height, 5, commonLength, commonLength);
        self.musicListButton.addTarget(self, action: #selector(self.didShowMusicListClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.myView.addSubview(self.musicListButton)
        
        //播放按钮
        self.playButton = UIButton(type: UIButtonType.Custom)
        self.playButton.setImage(UIImage(named: "play_arrow"), forState: UIControlState.Normal)
        self.playButton.frame = CGRectMake(self.musicListButton.frame.origin.x - commonLength - 5, 5, commonLength, commonLength);
        self.playButton.addTarget(self, action: #selector(self.didPlayClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.myView.addSubview(self.playButton)
        
        //歌手标签
        self.artistLabel = UILabel()
        self.artistLabel.frame = CGRectMake(commonLength + 20, 10, self.myView.frame.size.width - 2 * commonLength - 40, commonLength / 2 - 5);
        self.artistLabel.font.fontWithSize(16)
        self.myView.addSubview(self.artistLabel)
        
        //歌曲名
        self.songNameLabel = UILabel()
        self.songNameLabel.frame = CGRectMake(commonLength + 20, 5 + commonLength / 2, self.myView.frame.size.width - 2 * commonLength - 40, commonLength / 2 - 5);
        self.songNameLabel.font = UIFont(name: "Helvetica", size: 14)
        self.songNameLabel.textColor = UIColor.darkGrayColor()
        self.myView.addSubview(self.songNameLabel)
    }
    
    func initMusicListView() {
        let rect = UIScreen.mainScreen().bounds
        self.musicListBackView = UIView(frame: CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height));
        self.musicListBackView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        self.view.addSubview(self.musicListBackView)
        
        self.musicListFrontView = UIView(frame: CGRectMake(rect.origin.x, rect.size.height * 0.4, rect.size.width, rect.size.height * 0.6));
        self.musicListFrontView.alpha = 0.92
        self.musicListBackView.addSubview(self.musicListFrontView)
        self.musicListBackView.hidden = true
        
        //工具栏
        self.toolBar = UIToolbar(frame: CGRectMake(0, 0, self.musicListFrontView.frame.width, 40))
        self.toolBar.backgroundColor = UIColor.grayColor()
        self.musicListFrontView.addSubview(self.toolBar)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.FlexibleSpace, target:self, action:nil)
        
        let titleLabel = UILabel(frame: CGRectMake(0, 0, 100, 40))
        titleLabel.font = UIFont(name: "Helvetica", size: 20)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.text = "播放列表"
        let titleItem = UIBarButtonItem(customView: titleLabel)
        
        //let clearButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
        //clearButton.setTitle("清空", forState: UIControlState.Normal)
        //let barBtnItem1 = UIBarButtonItem(customView: clearButton)
        
        //let barBtnItem2 = UIBarButtonItem(title: "功能2", style:UIBarButtonItemStyle.Plain, target:self, action:"barBtnItemClicked:")
        
        self.toolBar.items = [flexibleSpace, titleItem, flexibleSpace]
    
        //设置关闭按钮
        self.closeButton = UIButton(frame: CGRectMake(0, self.musicListFrontView.frame.height - 40, self.musicListFrontView.frame.width, 40))
        self.closeButton.titleLabel!.font = UIFont(name: "Helvetica", size: 14)
        self.closeButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.closeButton.backgroundColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        self.closeButton.setTitle("关闭", forState:UIControlState.Normal)
        self.closeButton.addTarget(self, action: #selector(self.didCloseClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.musicListFrontView.addSubview(self.closeButton)
        
        //tableView的设置
        self.tableView.frame = CGRectMake(0, self.toolBar.frame.height, self.musicListFrontView.frame.width, self.musicListFrontView.frame.height - self.closeButton.frame.height - self.toolBar.frame.height)
        self.tableView.registerNib(UINib(nibName: "MusicListViewCell", bundle: nil), forCellReuseIdentifier: "MusicListViewCellID")
        self.tableView.allowsMultipleSelection = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.musicListFrontView.addSubview(self.tableView)
        self.tableView.reloadData()
        
        let recognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.handletapPressGesture(_:)))
        recognizer.delegate = self
        self.musicListBackView.addGestureRecognizer(recognizer)
    }
    
    func showMusicList() {
        self.hide()
        
        self.musicListBackView.hidden = false
        
        self.tableView.reloadData()
        self.setSelected()
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.musicListFrontView.frame.origin.y = self.musicListBackView.frame.height * 0.4
            }, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.selectedViewController?.viewWillAppear(animated)
        
        self.showInfo()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "PlayStatusNotification", object: nil)
    }
    
    @IBAction func handletapPressGesture(recognizer: UITapGestureRecognizer) {
        self.show()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        let touchPoint = touch.locationInView(self.musicListBackView)
        if(touchPoint.y < self.musicListFrontView.frame.origin.y) {
            return true
        }
        return false
    }
    
    @IBAction func didReturnClicked(sender: UIButton) {
        self.selectedIndex = 0
    }

    @IBAction func didSongImgClicked(sender: UIButton) {
        self.selectedIndex = 3
    }
    
    @IBAction func didShowMusicListClicked(sender: UIButton) {
        self.showMusicList()
    }
    
    @IBAction func didPlayClicked(sender: UIButton) {
        PlayCenter.instance.playOrPause()
    }
    
    @IBAction func didCloseClicked(sender: UIButton) {
        self.show()
    }
    
    func setSelected() {
        if !self.musicListBackView.hidden {
            dispatch_async(dispatch_get_main_queue()) {
                //初始化当前播放的选中状态
                let rowIndex = NSIndexPath(forRow: PlayCenter.instance.selectSongIndex, inSection: 0)
                self.tableView.selectRowAtIndexPath(rowIndex, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
            
            }
        }
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        switch (event!.subtype) {
        case UIEventSubtype.RemoteControlPlay:
            //RemoteControl播放
            PlayCenter.instance.playOrPause()
            break
            
        case UIEventSubtype.RemoteControlPause:
            //RemoteControl暂停
            PlayCenter.instance.playOrPause()
            break
            
        case UIEventSubtype.RemoteControlPreviousTrack:
            //RemoteControl上一首
            PlayCenter.instance.playPre()
            break
            
        case UIEventSubtype.RemoteControlNextTrack:
            //RemoteControl下一首
            PlayCenter.instance.playNext()
            break
            
        case UIEventSubtype.RemoteControlTogglePlayPause:
            //RemoteControl耳机播放／暂停
            PlayCenter.instance.playOrPause()
            break
            
        default:
            true
        }
    }
    
    func resetUI(){
        self.playButton.setImage(UIImage(named: "play_arrow"), forState: UIControlState.Normal)
        self.songImgButton.setImage(UIImage(named: "noimage"), forState: UIControlState.Normal)
        self.artistLabel.text = ""
        self.songNameLabel.text = ""
    }
    
    func showInfo() {
        self.resetUI()
        
        if PlayCenter.instance.songList.count == 0 {
            return
        }
        
        let songId = PlayCenter.instance.songList[PlayCenter.instance.selectSongIndex]
        
        if songId.isEmpty{
            return
        }
        
        if (PlayCenter.instance.avPlayer.rate == 1.0) {
            self.playButton.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
        } else {
            self.playButton.setImage(UIImage(named: "play_arrow"), forState: UIControlState.Normal)
        }
        
        let songInfo = PlayCenter.instance.songInfoList[songId]
        
        self.artistLabel.text = songInfo?.artistName
        self.songNameLabel.text = songInfo?.name
        if PlayCenter.instance.selectChannel == nil {
            //初始化歌手图片
            let imgData = DownloadCenter.instance.downloadedList[songId]?.picRadio
            if imgData != nil {
                self.songImgButton.setImage(UIImage(data: imgData!), forState: UIControlState.Normal)
            }
            else {
                self.songImgButton.setImage(UIImage(named: "noimage"), forState: UIControlState.Normal)
            }
        }
        else {
            //初始化歌手图片
            HttpRequest.getImage(songInfo!.songPicSmall) { (imgData) in
                if imgData != nil {
                    self.songImgButton.setImage(UIImage(data: imgData!), forState: UIControlState.Normal)
                }
                else {
                    self.songImgButton.setImage(UIImage(named: "noimage"), forState: UIControlState.Normal)
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
                print("ReadyToPlay")
                self.showInfo()
                self.setSelected()
                
            case AVPlayerStatus.Failed.rawValue:
                print("Failed to load video")
                
            case AVPlayerStatus.Unknown.rawValue:
                print("Unknown")
                
            default:
                true
            }
        }
        else if notification.userInfo!.keys.contains("rate") {
            //播放状态
            let rate = notification.userInfo!["rate"] as! Float
            if (rate == 1.0) {
                self.playButton.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
            } else {
                self.playButton.setImage(UIImage(named: "play_arrow"), forState: UIControlState.Normal)
            }
        }
    }
    
    func hide()
    {
        self.tabBar.hidden = true
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.myView.frame.origin.y = UIScreen.mainScreen().bounds.height
            }, completion: nil)
    }
    
    func show()
    {
        self.tabBar.hidden = false
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.musicListFrontView.frame.origin.y = self.musicListBackView.frame.height
            }, completion: nil)
        self.musicListBackView.hidden = true
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.myView.frame.origin.y = UIScreen.mainScreen().bounds.height - self.myView.frame.height
            }, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return PlayCenter.instance.songList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MusicListViewCellID", forIndexPath: indexPath) as! MusicListViewCell
        let id = PlayCenter.instance.songList[indexPath.row]
        cell.id = id
        cell.titleLabel.text = PlayCenter.instance.songInfoList[id]!.name
        cell.contentLabel.text = " - " + (PlayCenter.instance.songInfoList[id]?.artistName == nil ? "未知" : PlayCenter.instance.songInfoList[id]!.artistName)
        
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if PlayCenter.instance.avPlayer.rate == 1.0 {
            PlayCenter.instance.avPlayer.pause()
        }
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! MusicListViewCell
            
        PlayCenter.instance.selectSongIndex = PlayCenter.instance.songList.indexOf(cell.id)!
        let url = PlayCenter.instance.songLinkList[cell.id]!.songLink
        
        PlayCenter.instance.playWithUrl(cell.id, url: url)
        
        return indexPath
    }
    
}