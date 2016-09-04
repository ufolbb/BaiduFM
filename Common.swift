//
//  Common.swift
//  MusicPlayer
//
//  Created by 廖彬彬 on 16/4/4.
//  Copyright © 2016年 廖彬彬. All rights reserved.
//

import Foundation
import UIKit

class Common {
    
     /*
     获取可以播放的音乐
     - parameter url: 音乐播放URL
     - returns: 可以播放的URL
     */
    class func getCanPlaySongUrl(url: String)->String{
        
        if url.hasPrefix("http://file.qianqian.com"){
            return replaceString("&src=.+", replace: url, place: "")!
            //return url.substringToIndex(advance(url.startIndex, 114))
        }
        return url
    }
    
     /*
     获取首页显示图片
     - parameter info: 歌曲信息
     - returns: 首页显示的图片
     */
    class func getIndexPageImage(info :SongInfo) -> String{
        
        if info.songPicBig.isEmpty == false {
            return info.songPicBig
        }
        
        if info.songPicRadio.isEmpty == false {
            return info.songPicRadio
        }
        
        return info.songPicSmall
    }
    
     /*
     获取友好显示的时间
     - parameter seconds: 秒数
     - returns: 友好的时间显示
     */
    class func getMinuteDisplay(seconds: Int) ->String{
        
        let minute = Int(seconds/60)
        let second = seconds%60
        
        let minuteStr = minute >= 10 ? String(minute) : "0\(minute)"
        let secondStr = second >= 10 ? String(second) : "0\(second)"
        
        return "\(minuteStr):\(secondStr)"
    }
    
     /*
     正则替换字符串
     - parameter pattern: 正则表达式
     - parameter replace: 需要被替换的字符串
     - parameter place:   用来替换的字符串
     - returns: 替换后的字符串
     */
    class func replaceString(pattern:String, replace:String, place:String)->String?{
        let exp =  try? NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
        return exp?.stringByReplacingMatchesInString(replace, options: [], range: NSRange(location: 0,length: replace.characters.count), withTemplate: place)
    }
    
    class func fileIsExist(filePath:String)->Bool{
        return NSFileManager.defaultManager().fileExistsAtPath(filePath)
    }
    
    class func matchesForRegexInText(regex: String!, text: String!) -> [String] {
        
        let regex = try! NSRegularExpression(pattern: regex,
                                             options: [])
        let nsString = text as NSString
        let results = regex.matchesInString(text,
                                            options: [], range: NSMakeRange(0, nsString.length))
        
        return results.map { nsString.substringWithRange($0.range)}
    }
    
    //02:57 => 2*60+57=177
    class func timeStringToSecond(time:String)->Int?{
        
        var strArr = time.componentsSeparatedByString(":")
        if strArr.count == 0 {return nil}
        
        let minute =  Int(strArr[0])
        let second = Int(strArr[1])
        
        if let min = minute, sec = second{
            return min * 60 + sec
        }
        return nil
    }
    
    class func subStr(str:String, start:Int, length:Int)->String{
        
        return str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(start), end: str.startIndex.advancedBy(start+length)))
        
    }
    
    class func praseSongLrc(lrc:String)->[(lrc:String,time:Int)]{
        
        let list = lrc.componentsSeparatedByString("\n")
        var ret:[(lrc:String,time:Int)] = []
        
        for _ in 0...5 {
            ret += [(lrc:"",time:0)]
        }

        for row in list {
            //匹配[]歌词时间
            var timeArray = matchesForRegexInText("(\\[\\d{2}\\:\\d{2}\\.\\d{2}\\])", text: row)
            var lrcArray = matchesForRegexInText("\\](.*)", text: row)
            
            if timeArray.count == 0 {continue}
            //[02:57.26]
            let lrcTime = timeArray[0]
            
            var lrcTxt:String = ""
            if lrcArray.count >= 1 {
                lrcTxt = lrcArray[0]
                lrcTxt = subStr(lrcTxt, start: 1, length: lrcTxt.characters.count-1)
            }
            
            //02:57
            let time = subStr(lrcTime, start: 1, length: 5)
            
            if let t = timeStringToSecond(time){
                ret += [(lrc:lrcTxt,time:t)]
            }
        }
        
        for _ in 0...5 {
            ret += [(lrc:"",time:99999)]
        }
        
        return ret
    }
    
    class func currentLrcIndexByTime(curLength:Int, lrcArray:[(lrc:String,time:Int)])->Int{
        
        for index in 0...lrcArray.count-1 {
            if index == lrcArray.count-1 {
                return index
            }
            
            if curLength >= lrcArray[index].time  &&  curLength < lrcArray[index + 1].time{
                return index
            }
        }
        
        return 0
        
        /*
        var i = 0
        for (_, time): (String, Int) in lrcArray {
            
            if time >= curLength {
                return i
            }
            i += 1
        }
        
        return 0
        */
    }
    
    class func currentLrcByTime(curLength:Int, lrcArray:[(lrc:String,time:Int)])->(String,String){

        var i = 0
        for (lrc, time): (String, Int) in lrcArray {
            
            if time >= curLength {
                if i == 0 { return (lrc, "") }
                let prev = lrcArray[i-1]
                return (prev.lrc,lrc)
            }
            i += 1
        }
        
        return ("","")
        
    }
    
    class func getAlertController(title: String, message: String, buttontext: String)->UIAlertController{
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: buttontext, style: UIAlertActionStyle.Default,handler: nil))
        return alertController
    }
    
}