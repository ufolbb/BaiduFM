//
//  CoreDataManager.swift
//  MusicPlayer
//
//  Created by 廖彬彬 on 16/7/4.
//  Copyright © 2016年 廖彬彬. All rights reserved.
//

import CoreData
import UIKit

class CoreDataManager {
    
    class func getCoreData(entityForName: String, query: String) -> [AnyObject]? {
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = app.managedObjectContext
        
        let fetchRequest: NSFetchRequest = NSFetchRequest()
        fetchRequest.fetchLimit = 0 //限定查询结果的数量
        fetchRequest.fetchOffset = 0 //查询的偏移量
        //设置数据请求的实体结构
        fetchRequest.entity = NSEntityDescription.entityForName(entityForName, inManagedObjectContext: context)
        //设置查询条件
        let predicate = NSPredicate(format: query, "")
        fetchRequest.predicate = predicate
        
        do {
            //查询数据库
            let fetchedObjects: [AnyObject]? = try context.executeFetchRequest(fetchRequest)
            return fetchedObjects
        } catch let error as NSError {
            print("[getCoreData]查询数据库失败! error:\(error)")
            return nil
        }
    }
    
    class func delCoreData(entityForName: String, query: String) -> Bool {
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = app.managedObjectContext
        
        let fetchRequest: NSFetchRequest = NSFetchRequest()
        fetchRequest.fetchLimit = 0 //限定查询结果的数量
        fetchRequest.fetchOffset = 0 //查询的偏移量
        //设置数据请求的实体结构
        fetchRequest.entity = NSEntityDescription.entityForName(entityForName, inManagedObjectContext: context)
        //设置查询条件
        let predicate = NSPredicate(format: query, "")
        fetchRequest.predicate = predicate
        
        do {
            //查询数据库
            let fetchedObjects: [AnyObject]? = try context.executeFetchRequest(fetchRequest)
            for object in fetchedObjects! {
                //删除对象
                context.deleteObject(object as! NSManagedObject)
            }
            return true
        } catch let error as NSError {
            print("[delCoreData]查询数据库失败! error:\(error)")
            return false
        }
    }
    
    class func addMusicInfo(entity: Dictionary<String, AnyObject>) -> Bool {
        
        let id = entity["id"] as? String
        if id!.isEmpty {
            return false
        }
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = app.managedObjectContext
        
        let fetchRequest: NSFetchRequest = NSFetchRequest()
        fetchRequest.fetchLimit = 0 //限定查询结果的数量
        fetchRequest.fetchOffset = 0 //查询的偏移量
        //设置数据请求的实体结构
        fetchRequest.entity = NSEntityDescription.entityForName("MusicInfo", inManagedObjectContext: context)
        //设置查询条件
        let predicate = NSPredicate(format: "id='\(id!)'", "")
        fetchRequest.predicate = predicate
        
        do {
            //查询数据库
            let fetchedObjects: [AnyObject]? = try context.executeFetchRequest(fetchRequest)
            var musicInfo: MusicInfo
            if fetchedObjects?.count > 0 {
                musicInfo = fetchedObjects![0] as! MusicInfo
            }
            else
            {
                //新增音乐保存到数据库
                musicInfo = NSEntityDescription.insertNewObjectForEntityForName("MusicInfo", inManagedObjectContext: context) as! MusicInfo
                musicInfo.id = id
            }
            
            musicInfo.name = entity["name"] as? String
            musicInfo.albumName = entity["albumName"] as? String
            musicInfo.artistName = entity["artistName"] as? String
            musicInfo.picRadio = entity["picRadio"] as? NSData
            musicInfo.picSmall = entity["picSmall"] as? NSData
            musicInfo.lrc = entity["lrc"] as? String
            musicInfo.url = entity["url"] as? String
            musicInfo.progress = entity["progress"] as? Float
            musicInfo.bytesRead = entity["bytesRead"] as? Int
            musicInfo.bytesTotal = entity["bytesTotal"] as? Int
            musicInfo.path = entity["path"] as? String
            
            do {
                //保存
                try context.save()
                
                if Float(musicInfo.progress!) >= 1 {
                    if DownloadCenter.instance.downloadingList.keys.contains(id!) {
                        DownloadCenter.instance.downloadingList.removeAtIndex(DownloadCenter.instance.downloadingList.indexForKey(id!)!)
                    }
                    DownloadCenter.instance.downloadedList[id!] = musicInfo
                }
                else {
                    if DownloadCenter.instance.downloadedList.keys.contains(id!) {
                        DownloadCenter.instance.downloadedList.removeAtIndex(DownloadCenter.instance.downloadedList.indexForKey(id!)!)
                    }
                    DownloadCenter.instance.downloadingList[id!] = musicInfo
                }
                
                return true
            } catch let error as NSError {
                print("[addMusicInfo]保存到数据库失败! id:\(id) error:\(error)")
                return false
            }
        } catch let error as NSError {
            print("[addMusicInfo]查询数据库失败! id:\(id) error:\(error)")
            return false
        }
    }
    
    class func addMusicData(entity: Dictionary<String, AnyObject>) -> Bool {
        
        let id = entity["id"] as? String
        if id!.isEmpty {
            return false
        }
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = app.managedObjectContext
        
        let fetchRequest: NSFetchRequest = NSFetchRequest()
        fetchRequest.fetchLimit = 0 //限定查询结果的数量
        fetchRequest.fetchOffset = 0 //查询的偏移量
        //设置数据请求的实体结构
        fetchRequest.entity = NSEntityDescription.entityForName("MusicData", inManagedObjectContext: context)
        //设置查询条件
        let predicate = NSPredicate(format: "id='\(id!)'", "")
        fetchRequest.predicate = predicate
        
        do {
            //查询数据库
            let fetchedObjects: [AnyObject]? = try context.executeFetchRequest(fetchRequest)
            var musicData: MusicData
            if fetchedObjects?.count > 0 {
                musicData = fetchedObjects![0] as! MusicData
            }
            else
            {
                //新增音乐保存到数据库
                musicData = NSEntityDescription.insertNewObjectForEntityForName("MusicData", inManagedObjectContext: context) as! MusicData
                musicData.id = id
            }
            
            musicData.songData = entity["songData"] as? NSData

            do {
                //保存
                try context.save()
                return true
            } catch let error as NSError {
                print("[addMusicData]保存到数据库失败! id:\(id) error:\(error)")
                return false
            }
        } catch let error as NSError {
            print("[addMusicData]查询数据库失败! id:\(id) error:\(error)")
            return false
        }
    }
}