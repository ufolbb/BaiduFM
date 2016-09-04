//
//  HttpRequest.swift
//  MusicPlayer
//
//  Created by 廖彬彬 on 16/4/3.
//  Copyright © 2016年 廖彬彬. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class HttpRequest {
    
    class func getChannelList(callback:[Channel]?->Void) -> Void{
        
        var channelList:[Channel]? = nil
        Alamofire.request(.GET, http_channel_list_url).responseJSON{ (response) -> Void in
            if response.result.error == nil && response.result.value != nil {
                
                var data = JSON(response.result.value!)
                let list = data["channel_list"]
                channelList = []
                for (_, subJson): (String, JSON) in list {
                    
                    let id = subJson["channel_id"].stringValue
                    let name = subJson["channel_name"].stringValue
                    let order = subJson["channel_order"].int
                    let cate_id = subJson["cate_id"].stringValue
                    let cate = subJson["cate"].stringValue
                    let cate_order = subJson["cate_order"].int
                    let pv_order = subJson["pv_order"].int
                    
                    let channel = Channel(id: id, name: name, order: order!, cate_id: cate_id, cate: cate, cate_order: cate_order!, pv_order: pv_order!)
                    channelList?.append(channel)
                }
                callback(channelList)
            }else{
                callback(nil)
            }
        }
    }
    
    class func getSongList(ch_name:String, callback:[String]?->Void)->Void{
        
        var songList:[String]? = nil
        let url = http_song_list_url + ch_name
        // println(url)
        Alamofire.request(.GET, url).responseJSON{ (response) -> Void in
            if response.result.error == nil && response.result.value != nil {
                //println(json)
                var data = JSON(response.result.value!)
                let list = data["list"]
                songList = []
                for (_, subJson): (String, JSON) in list {
                    let id = subJson["id"].stringValue
                    songList?.append(id)
                }
                callback(songList)
            }else{
                callback(nil)
            }
        }
    }
    
    class func getSongInfoList(chidArray:[String], callback:[SongInfo]?->Void ){
        
        let chids = chidArray.joinWithSeparator(",")
        
        let params = ["songIds":chids]
        
        Alamofire.request(.POST, http_song_info, parameters: params).responseJSON{ (response) -> Void in
            if response.result.error == nil && response.result.value != nil {
                var data = JSON(response.result.value!)
                
                let lists = data["data"]["songList"]
                
                var ret:[SongInfo] = []
                
                for (_, list): (String, JSON) in lists {
                    
                    let id = list["songId"].stringValue
                    let name = list["songName"].stringValue
                    let artistId = list["artistId"].stringValue
                    let artistName = list["artistName"].stringValue
                    let albumId = list["albumId"].int
                    let albumName = list["albumName"].stringValue
                    let songPicSmall = list["songPicSmall"].stringValue
                    let songPicBig = list["songPicBig"].stringValue
                    let songPicRadio = list["songPicRadio"].stringValue
                    let allRate = list["allRate"].stringValue
                    
                    let songInfo = SongInfo(id: id, name: name, artistId: artistId, artistName: artistName, albumId: albumId!, albumName: albumName, songPicSmall: songPicSmall, songPicBig: songPicBig, songPicRadio: songPicRadio, allRate: allRate)
                    ret.append(songInfo)
                }
                callback(ret)
            }else{
                callback(nil)
            }
        }
    }
    
    class func getSongLinkList(chidArray:[String], callback:[SongLink]?->Void ) {
        
        let chids = chidArray.joinWithSeparator(",")
        
        let params = ["songIds":chids]
        
        Alamofire.request(.POST, http_song_link, parameters: params).responseJSON{ (response) -> Void in
            if response.result.error == nil && response.result.value != nil {
                var data = JSON(response.result.value!)
                let lists = data["data"]["songList"]
                
                var ret:[SongLink] = []
                
                for (_, list): (String, JSON) in lists {
                    
                    let id = list["songId"].stringValue
                    let name = list["songName"].stringValue
                    let lrcLink = list["lrcLink"].stringValue
                    let linkCode = list["linkCode"].int
                    let link = list["songLink"].stringValue
                    let format = list["format"].stringValue
                    let time = list["time"].int
                    let size = list["size"].int
                    let rate = list["rate"].int
                    
                    var t = 0, s = 0, r = 0
                    if time != nil {
                        t = time!
                    }
                    
                    if size != nil {
                        s = size!
                    }
                    
                    if rate != nil {
                        r = rate!
                    }
                    
                    let songLink = SongLink(id: id, name: name, lrcLink: lrcLink, linkCode: linkCode!, songLink: link, format: format, time: t, size: s, rate: r)
                    ret.append(songLink)
                }
                callback(ret)
            }else{
                callback(nil)
            }
        }
    }
    
    class func getSongLink(songid:String, callback:SongLink?->Void ) {
        
        let params = ["songIds":songid]
        
        Alamofire.request(.POST, http_song_link, parameters: params).responseJSON{ (response) -> Void in
            if response.result.error == nil && response.result.value != nil {
                var data = JSON(response.result.value!)
                let lists = data["data"]["songList"]
                
                var ret:[SongLink] = []
                
                for (_, list): (String, JSON) in lists {
                    
                    let id = list["songId"].stringValue
                    let name = list["songName"].stringValue
                    let lrcLink = list["lrcLink"].stringValue
                    let linkCode = list["linkCode"].int
                    let link = list["songLink"].stringValue
                    let format = list["format"].stringValue
                    let time = list["time"].int
                    let size = list["size"].int
                    let rate = list["rate"].int
                    
                    var t = 0, s = 0, r = 0
                    if time != nil {
                        t = time!
                    }
                    
                    if size != nil {
                        s = size!
                    }
                    
                    if rate != nil {
                        r = rate!
                    }
                    
                    let songLink = SongLink(id: id, name: name, lrcLink: lrcLink, linkCode: linkCode!, songLink: link, format: format, time: t, size: s, rate: r)
                    ret.append(songLink)
                }
                if ret.count == 1 {
                    callback(ret[0])
                }else{
                    callback(nil)
                }
            }else{
                callback(nil)
            }
        }
    }
    
    class func getImage(imgUrl:String, callback:NSData?->Void) ->Void{
        Alamofire.request(.GET, imgUrl).responseData { (response) in
            if response.result.error == nil {
                callback(response.result.value)
            }else{
                callback(nil)
            }
        }
    }
    
    class func getLrc(lrcUrl:String, callback:String?->Void) ->Void{
        //let url = http_song_lrc + lrcUrl
        Alamofire.request(.GET, lrcUrl).responseString(encoding: NSUTF8StringEncoding){ (response) -> Void in
            if response.result.error == nil {
                callback(response.result.value)
            }else{
                callback(nil)
            }
        }
    }
    
    class func downloadFile(songURL: String) -> Request {
        
        let canPlaySongURL = Common.getCanPlaySongUrl(songURL)
        
        //下载文件的保存路径
        let downloadRequset = Alamofire.download(Method.GET, canPlaySongURL) {
            (temporaryURL, response) in
            
            let fileManager = NSFileManager.defaultManager()
            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            
            let file = directoryURL.URLByAppendingPathComponent(response.suggestedFilename!)
            
            //判断文件是否存在，是则删除原文件
            let exist = fileManager.fileExistsAtPath(file.path!)
            if exist {
                do {
                    try fileManager.removeItemAtPath(file.path!)
                } catch let error as NSError {
                    print("[download] error:\(error)")
                }
            }
            
            return file
        }
        
        return downloadRequset
    }

    class func downloadFile(resumeData: NSData) -> Request {
        
        //下载文件的保存路径
        let downloadRequset = Alamofire.download(resumeData: resumeData) {
            (temporaryURL, response) in
            
            let fileManager = NSFileManager.defaultManager()
            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            
            let file = directoryURL.URLByAppendingPathComponent(response.suggestedFilename!)
            
            //判断文件是否存在，是则删除原文件
            let exist = fileManager.fileExistsAtPath(file.path!)
            if exist {
                do {
                    try fileManager.removeItemAtPath(file.path!)
                } catch let error as NSError {
                    print("[download] error:\(error)")
                }
            }
            
            return file
        }
        
        return downloadRequset
    }
}
