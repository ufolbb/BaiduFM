//
//  MusicData+CoreDataProperties.swift
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

extension MusicData {

    @NSManaged var id: String?
    @NSManaged var songData: NSData?

}
