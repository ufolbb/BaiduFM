//
//  DownloadCenter.swift
//  MusicPlayer
//
//  Created by 廖彬彬 on 16/6/27.
//  Copyright © 2016年 廖彬彬. All rights reserved.
//

import Foundation
import Alamofire

class DownloadCenter: NSObject {
    //单例
    class var instance: DownloadCenter{
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: DownloadCenter? = nil
        }
        
        dispatch_once(&Static.onceToken) { () -> Void in
            Static.instance = DownloadCenter()
        }
        return Static.instance!
    }
    
    override init(){
        
        super.init()
        
        //初始化已下载歌曲列表
        self.InitDownloadList(true)
        //初始化正在下载歌曲列表
        self.InitDownloadList(false)
    }
    
    var downloadedList: Dictionary<String, MusicInfo> = Dictionary<String, MusicInfo>()
    var downloadingList: Dictionary<String, MusicInfo> = Dictionary<String, MusicInfo>()
    var downloadRequset: Dictionary<String, Request> = Dictionary<String, Request>()
    
    func DeleteMusic(id: String) -> Bool{
        //删除歌曲
        if self.downloadedList.keys.contains(id) {
            let fileManager = NSFileManager.defaultManager()
            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let file = directoryURL.URLByAppendingPathComponent(self.downloadedList[id]!.path!)
            
            let isExist = fileManager.fileExistsAtPath(file.path!)
                
            if isExist {
                do {
                    try fileManager.removeItemAtPath(file.path!)
                } catch _ {
                }
            }
            
            self.downloadedList.removeAtIndex(self.downloadedList.indexForKey(id)!)
        }
        
        if self.downloadingList.keys.contains(id) {
            self.downloadingList.removeAtIndex(self.downloadingList.indexForKey(id)!)
        }

        CoreDataManager.delCoreData("MusicData", query: "id='\(id)'")
        return CoreDataManager.delCoreData("MusicInfo", query: "id='\(id)'")
    }
    
    func InitDownloadList(status: Bool) -> Bool{
        
        let fetchedObjects = CoreDataManager.getCoreData("MusicInfo", query: status ? "progress>=1" : "progress<1")
        
        if fetchedObjects == nil {
            return false
        }
        
        if(status){
            self.downloadedList.removeAll()
            for musicInfo:MusicInfo in fetchedObjects as! [MusicInfo]{
                self.downloadedList[musicInfo.id!] = musicInfo
            }
        }
        else{
            self.downloadingList.removeAll()
            for musicInfo:MusicInfo in fetchedObjects as! [MusicInfo]{
                self.downloadingList[musicInfo.id!] = musicInfo
            }
        }
            
        return true
    }
    
    func CancelDownload(id: String) {
        if id.isEmpty {
            return
        }
        
        if self.downloadRequset.keys.contains(id) {
            if self.downloadRequset[id]!.task.state == .Running {
                self.downloadRequset[id]!.cancel()
            }
        }
    }
    
    func StartDownload(id: String) {
        if id.isEmpty {
            return
        }
        
        if self.downloadRequset.keys.contains(id) {
            if self.downloadRequset[id]!.task.state == .Running {
                return
            }
        }
        
        let songInfo = self.downloadingList[id]
        let fetchedObjects = CoreDataManager.getCoreData("MusicData", query: "id='\(id)'")
        
        if fetchedObjects == nil || fetchedObjects?.count == 0 {
            self.downloadRequset[id] = HttpRequest.downloadFile((songInfo?.url)!)
        }
        else {
            let musicData = fetchedObjects![0] as! MusicData
            if musicData.songData?.length > 0 {
                self.downloadRequset[id] = HttpRequest.downloadFile(musicData.songData!)
            }
            else {
                self.downloadRequset[id] = HttpRequest.downloadFile((songInfo?.url)!)
            }
        }
        
        self.downloadRequset[id]!.response{ (request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: NSError?) in
            
            if let error = error {
                if error.code == NSURLErrorCancelled {
                    var musicInfo = Dictionary<String, AnyObject>()
                    musicInfo["id"] = songInfo!.id
                    musicInfo["name"] = songInfo!.name
                    musicInfo["albumName"] = songInfo!.albumName
                    musicInfo["artistName"] = songInfo!.artistName
                    musicInfo["progress"] = songInfo!.progress
                    musicInfo["url"] = songInfo!.url
                    musicInfo["lrc"] = songInfo!.lrc
                    musicInfo["picRadio"] = songInfo!.picRadio
                    musicInfo["picSmall"] = songInfo!.picSmall
                    musicInfo["bytesRead"] = songInfo!.bytesRead
                    musicInfo["bytesTotal"] = songInfo!.bytesTotal
                    musicInfo["path"] = songInfo!.path
                    CoreDataManager.addMusicInfo(musicInfo)
                    
                    //暂停下载，记录已下载的数据
                    var musicData = Dictionary<String, AnyObject>()
                    musicData["id"] = id
                    musicData["songData"] = data
                    CoreDataManager.addMusicData(musicData)
                }
                else {
                    //下载失败
                    print("download failed! id:\(id) response:\(response) error:\(error)")
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName("DownloadStatusNotification", object: self, userInfo: ["id": id, "status": false])
            } else {
                let fileManager = NSFileManager.defaultManager()
                let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                let file = directoryURL.URLByAppendingPathComponent(response!.suggestedFilename!)
                
                let isExist = fileManager.fileExistsAtPath(file.path!)
                
                if isExist {
                    songInfo!.path = response!.suggestedFilename!
                    songInfo!.progress = 1
                    
                    var musicInfo = Dictionary<String, AnyObject>()
                    musicInfo["id"] = songInfo!.id
                    musicInfo["name"] = songInfo!.name
                    musicInfo["albumName"] = songInfo!.albumName
                    musicInfo["artistName"] = songInfo!.artistName
                    musicInfo["progress"] = songInfo!.progress
                    musicInfo["url"] = songInfo!.url
                    musicInfo["lrc"] = songInfo!.lrc
                    musicInfo["picRadio"] = songInfo!.picRadio
                    musicInfo["picSmall"] = songInfo!.picSmall
                    musicInfo["bytesRead"] = songInfo!.bytesRead
                    musicInfo["bytesTotal"] = songInfo!.bytesTotal
                    musicInfo["path"] = songInfo!.path
                    CoreDataManager.addMusicInfo(musicInfo)
                }
                else {
                    print("file not found! id:\(id)")
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName("DownloadStatusNotification", object: self, userInfo: ["id": id, "status": true])
            }
            
            self.downloadRequset.removeAtIndex(self.downloadRequset.indexForKey(id)!)
        }
        
        //下载进度
        self.downloadRequset[id]!.progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
            
            NSNotificationCenter.defaultCenter().postNotificationName("DownloadProgressNotification", object: self, userInfo: ["id": id, "bytesRead": Int(bytesRead), "totalBytesRead": Int(totalBytesRead), "totalBytesExpectedToRead": Int(totalBytesExpectedToRead)])
            
            dispatch_async(dispatch_get_main_queue()) {
                let percent = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
                songInfo!.progress = percent
                songInfo!.bytesRead = Int(totalBytesRead)
                songInfo!.bytesTotal = Int(totalBytesExpectedToRead)
            }
        }

    }
    
}