//
//  PlayRadioViewController.swift
//  MusicPlayer
//
//  Created by 廖彬彬 on 16/4/3.
//  Copyright © 2016年 廖彬彬. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class PlayMusicViewController: UIViewController {

    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var artistImageView: UIImageView!
    @IBOutlet weak var progressSlider: UISlider!
    
    @IBOutlet weak var songTimeLengthLabel: UILabel!
    @IBOutlet weak var songTimePlayLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var lrcTableView: UITableView!
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var beginDrag: Bool = false

    var playbackObserver: AnyObject!

    var lrcIndex: Int = 0
    func showLrc(curTime:Int) {
        if PlayCenter.instance.selectLrc.count > 0 && self.lrcTableView.numberOfRowsInSection(0)  > 0 {
            //字幕同步显示
            let lrcRowIndex = Common.currentLrcIndexByTime(curTime, lrcArray: PlayCenter.instance.selectLrc)
            
            if(self.lrcIndex == lrcRowIndex) {
                return
            }
            
            self.lrcIndex = lrcRowIndex
            self.lrcTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: lrcRowIndex, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
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
        
        //将背景图片置于最底层
        self.view.sendSubviewToBack(self.bgImageView)
        
        //把imageview设置为圆形
        self.artistImageView.layer.cornerRadius = self.artistImageView.frame.size.width / 2
        self.artistImageView.clipsToBounds = true;
        //设置imageview边框颜色和宽度
        self.artistImageView.layer.borderWidth = 3;
        self.artistImageView.layer.borderColor = UIColor.whiteColor().CGColor;
        //设置歌词显示区域背景透明
        self.lrcTableView.backgroundView?.backgroundColor = UIColor.clearColor();
        self.lrcTableView.backgroundColor = UIColor.clearColor()
    }
    
    @IBAction func didReturnClicked(sender: UIButton) {
        self.tabBarController?.selectedIndex = 0
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        switch (event!.subtype) {
        case UIEventSubtype.RemoteControlPlay:
            //RemoteControl播放
            self.didPlayClicked(self.playButton)
            break
            
        case UIEventSubtype.RemoteControlPause:
            //RemoteControl暂停
            self.didPlayClicked(self.playButton)
            break
            
        case UIEventSubtype.RemoteControlPreviousTrack:
            //RemoteControl上一首
            self.didPreClicked(self.prevButton)
            break
            
        case UIEventSubtype.RemoteControlNextTrack:
            //RemoteControl下一首
            self.didNextClicked(self.nextButton)
            break
            
        case UIEventSubtype.RemoteControlTogglePlayPause:
            //RemoteControl耳机播放／暂停
            self.didPlayClicked(self.playButton)
            break
            
        default:
            true
        }
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        //设置当前歌词的显示颜色
        for indexPath in self.lrcTableView.indexPathsForVisibleRows! {
            if indexPath.row == self.lrcIndex {
                self.lrcTableView.cellForRowAtIndexPath(indexPath)?.textLabel?.textColor = UIColor(red: 0.0, green: 1.0, blue: 0.498, alpha: 1.0)
            }
            else {
                self.lrcTableView.cellForRowAtIndexPath(indexPath)?.textLabel?.textColor = UIColor.whiteColor()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        //隐藏tabbar
        let playController: PlayTabBarController = self.tabBarController as! PlayTabBarController
        playController.hide()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.PlayStatus(_:)), name: "PlayStatusNotification", object: nil)
        
        self.showInfo()
        
        self.playbackObserver = PlayCenter.instance.avPlayer.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1), queue: dispatch_get_main_queue()) { (CMTime) in
            
            if PlayCenter.instance.avPlayer.currentItem == nil {
                return
            }
            let currentTime = PlayCenter.instance.avPlayer.currentTime()
            let totalTime = PlayCenter.instance.avPlayer.currentItem?.duration
            
            self.songTimePlayLabel.text = "\(Common.getMinuteDisplay(Int(currentTime.seconds)))"
            if !self.beginDrag {
                self.progressSlider.value = Float(currentTime.seconds / totalTime!.seconds)
            }
            
            //同步显示歌词
            self.showLrc(Int(currentTime.seconds))
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "PlayStatusNotification", object: nil)
        //移除时间监听
        PlayCenter.instance.avPlayer.removeTimeObserver(self.playbackObserver)
    }
    
    func resetUI(){
        self.songTimePlayLabel.text = "00:00"
        self.songTimeLengthLabel.text = "00:00"
        self.artistLabel.text = ""
        self.songNameLabel.text = ""
        self.playButton.setImage(UIImage(named: "player_btn_play_normal"), forState: UIControlState.Normal)
        self.artistImageView.image = UIImage(named: "noimage")
        self.lrcIndex = 0
        self.lrcTableView.reloadData()
        
        self.progressSlider.value = 0
        self.progressSlider.enabled = false
        
        if PlayCenter.instance.selectSongIndex <= 0 || PlayCenter.instance.selectSongIndex >= PlayCenter.instance.songList.count {
            self.prevButton.enabled = false
        }
        else {
            self.prevButton.enabled = true
        }
        
        if PlayCenter.instance.selectSongIndex < 0 || PlayCenter.instance.selectSongIndex >= PlayCenter.instance.songList.count - 1 {
            self.nextButton.enabled = false
        }
        else {
            self.nextButton.enabled = true
        }
    }
    
    func showInfo(){
        
        self.resetUI()
        
        if PlayCenter.instance.selectChannel == nil {
            self.navigationItem.title = "本地歌曲"
        }
        else {
            self.navigationItem.title = PlayCenter.instance.selectChannel.name
        }
        
        if PlayCenter.instance.songList.count == 0 {
            //let alertController = Common.getAlertController("发生异常", message: "获取歌曲信息失败！", buttontext: "确定")
            //self.presentViewController(alertController, animated: true, completion: nil)
            //print("get songId failed")
            return
        }
        
        let songId = PlayCenter.instance.songList[PlayCenter.instance.selectSongIndex]
        
        if songId.isEmpty{
            return
        }
        
        let songInfo = PlayCenter.instance.songInfoList[songId]
        
        if songInfo == nil {
            return
        }

        self.songNameLabel.text = songInfo!.name
        self.artistLabel.text = "-" + songInfo!.artistName + "-"
        
        let totalTime = PlayCenter.instance.avPlayer.currentItem?.duration
        if totalTime != nil && !isnan(totalTime!.seconds) {
            self.songTimeLengthLabel.text = Common.getMinuteDisplay(Int(totalTime!.seconds))
            self.progressSlider.enabled = true
        }
        else {
            self.songTimeLengthLabel.text = "00:00"
        }
        
        let currentTime = PlayCenter.instance.avPlayer.currentItem?.currentTime()
        if currentTime != nil && !isnan(currentTime!.seconds) {
            self.songTimePlayLabel.text = Common.getMinuteDisplay(Int(currentTime!.seconds))
            self.progressSlider.value = Float(currentTime!.seconds / totalTime!.seconds)
        }
        else {
            self.songTimePlayLabel.text = "00:00"
        }
        
        if (PlayCenter.instance.avPlayer.rate == 1.0) {
            self.playButton.setImage(UIImage(named: "player_btn_pause_normal"), forState: UIControlState.Normal)
        } else {
            self.playButton.setImage(UIImage(named: "player_btn_play_normal"), forState: UIControlState.Normal)
        }
        
        if PlayCenter.instance.selectChannel == nil {
            //初始化歌手图片
            let imgData = DownloadCenter.instance.downloadedList[songId]?.picRadio
            if imgData != nil {
                self.artistImageView.image = UIImage(data: imgData!)
            }
            else {
                self.artistImageView.image = UIImage(named: "noimage")
            }
            
            //初始化歌词
            let lrc = DownloadCenter.instance.downloadedList[songId]?.lrc
            if(lrc != nil) {
                PlayCenter.instance.selectLrc = Common.praseSongLrc(lrc!)
            }
            else {
                PlayCenter.instance.selectLrc = []
            }
            self.lrcTableView.reloadData()
        }
        else {
            let songLink = PlayCenter.instance.songLinkList[songId]
            
            //初始化歌手图片
            HttpRequest.getImage(songInfo!.songPicRadio) { (imgData) in
                if imgData != nil {
                    self.artistImageView.image = UIImage(data: imgData!)
                }
                else {
                    self.artistImageView.image = UIImage(named: "noimage")
                }
            }
        
            if songLink == nil {
                PlayCenter.instance.selectLrc = []
                self.lrcTableView.reloadData()
                return
            }
        
            //初始化歌词
            HttpRequest.getLrc(songLink!.lrcLink, callback: { lrc -> Void in
                //下载歌词
                if lrc == nil {
                    PlayCenter.instance.selectLrc = []
                }
                else {
                    PlayCenter.instance.selectLrc = Common.praseSongLrc(lrc!)
                }
                self.lrcTableView.reloadData()
            })
        }
    }
    
    @IBAction func didDownloadClicked(sender: UIButton) {
        
        let id = PlayCenter.instance.songList[PlayCenter.instance.selectSongIndex]
        if id.isEmpty {
            return
        }
        
        let songInfo = PlayCenter.instance.songInfoList[id]
        let songLink = PlayCenter.instance.songLinkList[id]
        
        var musicInfo = Dictionary<String, AnyObject>()
        musicInfo["id"] = id
        musicInfo["name"] = songInfo?.name
        musicInfo["albumName"] = songInfo?.albumName
        musicInfo["artistName"] = songInfo?.artistName
        musicInfo["progress"] = 0
        musicInfo["url"] = songLink?.songLink
        musicInfo["bytesRead"] = 0
        musicInfo["bytesTotal"] = songLink?.size
        musicInfo["path"] = ""
        
        var picRadioCompleted = false
        var picSmallCompleted = false
        var lrcCompleted = false
        
        //下载歌手图片
        HttpRequest.getImage(songInfo!.songPicRadio) { (imgData) in
            musicInfo["picRadio"] = imgData
            picRadioCompleted = true
            if picRadioCompleted && picSmallCompleted && lrcCompleted {
                CoreDataManager.addMusicInfo(musicInfo)
            }
        }
        
        //下载歌手图片
        HttpRequest.getImage(songInfo!.songPicSmall) { (imgData) in
            musicInfo["picSmall"] = imgData
            picSmallCompleted = true
            if picRadioCompleted && picSmallCompleted && lrcCompleted {
                CoreDataManager.addMusicInfo(musicInfo)
            }
        }
        
        //下载歌词
        HttpRequest.getLrc(songLink!.lrcLink, callback: { lrc -> Void in
            //下载歌词
            musicInfo["lrc"] = lrc
            lrcCompleted = true
            if picRadioCompleted && picSmallCompleted && lrcCompleted {
                CoreDataManager.addMusicInfo(musicInfo)
            }
        })
    }
    
    @IBAction func didPlayClicked(sender: UIButton) {
        //播放暂停
        PlayCenter.instance.playOrPause()
    }

    @IBAction func didNextClicked(sender: UIButton) {
        //下一首
        PlayCenter.instance.playNext()
    }
    
    @IBAction func didPreClicked(sender: UIButton) {
        //上一首
        PlayCenter.instance.playPre()
    }
    
    @IBAction func didSliderTouchUpInside(sender: UISlider) {
        let totalTime = PlayCenter.instance.avPlayer.currentItem?.duration
        let newSeconds = Int64(Float(totalTime!.seconds) * self.progressSlider.value)
        let newTime = CMTimeMake(newSeconds, 1)
        PlayCenter.instance.avPlayer.seekToTime(newTime)
        self.showLrc(Int(newSeconds))

        self.beginDrag = false
    }
    
    @IBAction func didSliderTouchDown(sender: UISlider) {
        self.beginDrag = true
    }
    
    //播放状态通知
    func PlayStatus(notification: NSNotification) {
        
        if notification.userInfo!.keys.contains("status") {
            let status = notification.userInfo!["status"] as! AVPlayerStatus.RawValue
            
            switch (status) {
            case AVPlayerStatus.ReadyToPlay.rawValue:
                print("ReadyToPlay")
                self.showInfo()
                
            case AVPlayerStatus.Failed.rawValue:
                print("Failed to load video")
                
            case AVPlayerStatus.Unknown.rawValue:
                print("Unknown")
                
            default:
                true
            }
        }
        else if notification.userInfo!.keys.contains("loadedTimeRanges") {
            //时间读取完毕，界面显示总时长
            let totalTime = notification.userInfo!["loadedTimeRanges"] as! String
            
            self.songTimeLengthLabel.text = totalTime
            self.progressSlider.enabled = true
        }
        else if notification.userInfo!.keys.contains("rate") {
            //播放状态
            let rate = notification.userInfo!["rate"] as! Float
            if (rate == 1.0) {
                self.playButton.setImage(UIImage(named: "player_btn_pause_normal"), forState: UIControlState.Normal)
            } else {
                self.playButton.setImage(UIImage(named: "player_btn_play_normal"), forState: UIControlState.Normal)
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return PlayCenter.instance.selectLrc.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("lrcLineCell", forIndexPath: indexPath)
        
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel!.backgroundColor = UIColor.clearColor()
        cell.textLabel!.textColor = UIColor.whiteColor()
        if indexPath.row < PlayCenter.instance.selectLrc.count {
            cell.textLabel!.text = PlayCenter.instance.selectLrc[indexPath.row].lrc
        }
        else {
            cell.textLabel!.text = ""
        }
        cell.textLabel!.textAlignment = NSTextAlignment.Center
        cell.textLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        cell.textLabel!.numberOfLines = 0
        
        return cell
    }
}
