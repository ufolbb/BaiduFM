//
//  MusicDownloadingCell.swift
//  MusicPlayer
//
//  Created by 廖彬彬 on 16/7/11.
//  Copyright © 2016年 廖彬彬. All rights reserved.
//

import UIKit
import Alamofire

class MusicDownloadingCell: UITableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    var id: String!
    var running: Bool = false
    var updateTime: NSDate = NSDate()
    var bytesRead: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.progressBar.progress = 0
        self.infoLabel.text = ""
        self.contentLabel.text = ""
        self.speedLabel.text = ""
    }
    
    func SetProgress(bytesRead: Int, totalBytesRead: Int, totalBytesExpectedToRead: Int) {
        //计算下载进度
        let percent = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
        self.progressBar.setProgress(percent, animated: true)
            
        let nowTime = NSDate()
        let second = nowTime.timeIntervalSinceDate(self.updateTime)
        
        if(second < 0.5) {
            return
        }
        
        self.bytesRead += Int(bytesRead)
        let totalRead = String(format: "%.2f", Float(totalBytesRead) / 1024 / 1024)
        let fileLength = String(format: "%.2f", Float(totalBytesExpectedToRead) / 1024 / 1024)
        self.infoLabel.text = "\(totalRead)M/\(fileLength)M"
            
        let speed = String(format: "%.2f", Float(self.bytesRead) / Float(second) / 1024)
        self.speedLabel.text = "\(speed) KB/S"
            
        self.bytesRead = 0
        self.updateTime = nowTime
    }
    
    func SetRunning()
    {
        self.running = true
        downloadButton.setImage(UIImage(named: "player_btn_pause_normal"), forState: UIControlState.Normal)
    }
    
    func SetPause()
    {
        self.running = false
        downloadButton.setImage(UIImage(named: "player_btn_play_normal"), forState: UIControlState.Normal)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func downloadClicked(sender: UIButton) {
        
        if self.running {
            DownloadCenter.instance.CancelDownload(self.id)
            return
        }
        
        self.updateTime = NSDate()
        self.bytesRead = 0

        //设置按钮图片为暂停
        self.SetRunning()
        
        DownloadCenter.instance.StartDownload(self.id)
    }
}