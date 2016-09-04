//
//  MusicInfo+CoreDataProperties.swift
//  MusicPlayer
//
//  Created by 廖彬彬 on 16/7/17.
//  Copyright © 2016年 廖彬彬. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension MusicInfo {

    @NSManaged var albumName: String?
    @NSManaged var artistName: String?
    @NSManaged var bytesRead: NSNumber?
    @NSManaged var bytesTotal: NSNumber?
    @NSManaged var id: String?
    @NSManaged var lrc: String?
    @NSManaged var name: String?
    @NSManaged var picRadio: NSData?
    @NSManaged var picSmall: NSData?
    @NSManaged var progress: NSNumber?
    @NSManaged var url: String?
    @NSManaged var path: String?

}
