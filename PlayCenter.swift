//
//  PlayCenter.swift
//  MusicPlayer
//
//  Created by 廖彬彬 on 16/4/4.
//  Copyright © 2016年 廖彬彬. All rights reserved.
//

import Foundation
import MediaPlayer

class PlayCenter: NSObject {
    //单例
    class var instance: PlayCenter{
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: PlayCenter? = nil
        }
        
        dispatch_once(&Static.onceToken) { () -> Void in
            Static.instance = PlayCenter()
        }
        return Static.instance!
    }
    
    override init(){
        
        super.init()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch {
            // deal with error
            print("init AVAudioSession error")
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.AVPlayerNotification(_:)), name: "AVPlayerItemDidPlayToEndTimeNotification", object: nil)
        
        //监听播放状态
        self.avPlayer.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.New, context: &myContext)
    }
  
    let avPlayer: AVPlayer = AVPlayer()
    //歌曲分类列表信息
    var channelInfoList: [Channel] = []
    //当前选择的频道
    var selectChannel: Channel!
    //当前播放的歌曲索引
    var selectSongIndex: Int = 0
    //当前歌词
    var selectLrc: [(lrc:String,time:Int)] = []
    
    var songList: [String] = []
    var songInfoList: Dictionary<String, SongInfo> = Dictionary<String, SongInfo>()
    var songLinkList: Dictionary<String, SongLink> = Dictionary<String, SongLink>()
    
    //加载网络电台歌曲列表
    func loadSongList(channelId: String) {
        //重置当前播放索引、歌曲列表
        self.selectSongIndex = 0
        self.songList = []
        self.selectLrc = []
        self.songInfoList.removeAll()
        self.songLinkList.removeAll()
        
        if channelId.isEmpty {
            //本地歌曲
            self.songList = Array(DownloadCenter.instance.downloadedList.keys)
            self.loadSongInfo(channelId, songList: self.songList)
        }
        else {
            //电台歌曲
            HttpRequest.getSongList(channelId) { (songList) in
                if(channelId != self.selectChannel.id) {
                    return
                }
            
                if songList != nil {
                    self.songList = songList!
                    self.loadSongInfo(channelId, songList: self.songList)
                }
                else {
                    print("getSongList failed")
                }
            }
        }
    }
    
    //获取歌曲信息列表
    func loadSongInfo(channelId: String, songList: [String]) {
        if channelId.isEmpty {
            //本地歌曲
            for id in songList {
                let musicInfo = DownloadCenter.instance.downloadedList[id]
                let songInfo = SongInfo(id: musicInfo!.id!, name: musicInfo!.name!, artistId: "", artistName: musicInfo!.artistName!, albumId: 0, albumName: "", songPicSmall: "", songPicBig: "", songPicRadio: "", allRate: "")
                self.songInfoList[songInfo.id] = songInfo
            }
            
            self.loadSongLink(channelId, songList: songList)
        }
        else {
            //电台歌曲
            HttpRequest.getSongInfoList(songList) { (songInfoList) in
                if(channelId != self.selectChannel.id) {
                    return
                }
            
                if songInfoList == nil {
                    print("getSongInfoList failed")
                    return
                }
            
                for songInfo in songInfoList! {
                    self.songInfoList[songInfo.id] = songInfo
                }
            
                self.loadSongLink(channelId, songList: songList)
            }
        }
    }
    
    //获取歌曲链接列表
    func loadSongLink(channelId: String, songList: [String]) {
        if channelId.isEmpty {
            for id in songList {
                let musicInfo = DownloadCenter.instance.downloadedList[id]
                let songLink = SongLink(id: musicInfo!.id!, name: musicInfo!.name!, lrcLink: "", linkCode: 0, songLink: musicInfo!.url!, format: "", time: 0, size: 0, rate: 0)
                self.songLinkList[songLink.id] = songLink
            }
        }
        else {
            HttpRequest.getSongLinkList(songList) { (songLinkList) in
                if(channelId != self.selectChannel.id) {
                    return
                }
                
                if songLinkList == nil {
                    print("getSongLinkList failed")
                    return
                }
                
                for songLink in songLinkList! {
                    self.songLinkList[songLink.id] = songLink
                }
                
                let id = self.songList[self.selectSongIndex]
                let url = self.songLinkList[id]!.songLink
                self.playWithUrl(id, url: url)
            }
        }
    }

    //通过url播放歌曲
    func playWithUrl(id: String, url: String) {
        if self.avPlayer.currentItem != nil {
            self.avPlayer.pause()
            self.avPlayer.currentItem!.removeObserver(self, forKeyPath: "status", context: &myContext)
            self.avPlayer.currentItem!.removeObserver(self, forKeyPath: "loadedTimeRanges", context: &myContext)
            self.avPlayer.replaceCurrentItemWithPlayerItem(nil)
        }
        
        self.selectLrc = []
        
        var playerItem: AVPlayerItem! = nil
        if DownloadCenter.instance.downloadedList.keys.contains(id) {
            let musicInfo = DownloadCenter.instance.downloadedList[id]
            
            let fileManager = NSFileManager.defaultManager()
            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let file = directoryURL.URLByAppendingPathComponent(musicInfo!.path!)
            
            let nsUrl = NSURL(fileURLWithPath: file.path!)
            playerItem = AVPlayerItem(URL: nsUrl)
        }
            
        if playerItem == nil {
            let nsUrl = NSURL(string: Common.getCanPlaySongUrl(url))!
            playerItem = AVPlayerItem(URL: nsUrl)
        }

        self.avPlayer.replaceCurrentItemWithPlayerItem(playerItem)

        self.avPlayer.currentItem!.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: &myContext)
        self.avPlayer.currentItem!.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.New, context: &myContext)
    }
    
    //播放或暂停
    func playOrPause() {
        if self.songList.count == 0 {
            return
        }
        
        if self.avPlayer.rate == 1.0 {
            PlayCenter.instance.avPlayer.pause()
        }
        else if self.avPlayer.currentItem == nil {
            let id = self.songList[self.selectSongIndex]
            let url = self.songLinkList[id]!.songLink
            self.playWithUrl(id, url: url)
        }
        else {
            self.avPlayer.play()
        }
    }
    
    //播放下一首
    func playNext() {
        if self.songList.count == 0 {
            return
        }
        
        if self.selectSongIndex < self.songList.count - 1 {
            self.selectSongIndex += 1
            let id = self.songList[self.selectSongIndex]
            let url = self.songLinkList[id]!.songLink
            self.playWithUrl(id, url: url)
        }
    }
    
    //播放上一首
    func playPre() {
        if self.songList.count == 0 {
            return
        }
        
        if self.selectSongIndex > 0 {
            self.selectSongIndex -= 1
            let id = self.songList[self.selectSongIndex]
            let url = self.songLinkList[id]!.songLink
            self.playWithUrl(id, url: url)
        }
    }
    
    private var myContext = 0
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        switch (keyPath!, context) {
        case ("status", &myContext):
            let status = (change![NSKeyValueChangeNewKey] as! NSNumber).integerValue as AVPlayerStatus.RawValue
            
            switch (status) {
            case AVPlayerStatus.ReadyToPlay.rawValue:
                self.avPlayer.play()
                
            default:
                true
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName("PlayStatusNotification", object: self, userInfo: ["status": status])
            
        case ("loadedTimeRanges", &myContext):
            let totalTime = self.avPlayer.currentItem!.duration
            
            if(totalTime.seconds > 0) {
                NSNotificationCenter.defaultCenter().postNotificationName("PlayStatusNotification", object: self, userInfo: ["loadedTimeRanges": "\(Common.getMinuteDisplay(Int(totalTime.seconds)))"])
            }
            
        case ("rate", &myContext):
            let rate = change![NSKeyValueChangeNewKey] as! Float
            NSNotificationCenter.defaultCenter().postNotificationName("PlayStatusNotification", object: self, userInfo: ["rate": rate])
            
        default:
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    //播放完毕
    func AVPlayerNotification(notification: NSNotification) {
        //播放完毕切下一首歌
        if self.selectSongIndex < self.songList.count - 1 {
            self.playNext()
        }
        else if PlayCenter.instance.selectSongIndex == PlayCenter.instance.songList.count - 1 {
            if PlayCenter.instance.selectChannel == nil {
                //本地歌曲播放完成重新开始
                PlayCenter.instance.selectSongIndex = -1
                self.playNext()
            }
            else {
                //列表播放完成重新获取歌曲列表
                self.loadSongList(PlayCenter.instance.selectChannel.id)
            }
        }
    }
    
    deinit {
        //执行析构过程
        //移除播放状态的监听
        self.avPlayer.removeObserver(self, forKeyPath: "rate", context: &myContext)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "AVPlayerItemDidPlayToEndTimeNotification", object: nil)
    }

}