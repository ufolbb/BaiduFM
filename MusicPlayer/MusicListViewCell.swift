//
//  MusicListViewCell.swift
//  MusicPlayer
//
//  Created by 廖彬彬 on 16/8/31.
//  Copyright © 2016年 廖彬彬. All rights reserved.
//

import UIKit

class MusicListViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var playImage: UIImageView!
    
    var id: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.titleLabel.textColor = UIColor.redColor()
        }
        else {
            self.titleLabel.textColor = UIColor.blackColor()
        }
        self.setPlayImgVisible(selected)
    }
    
    func setPlayImgVisible(visible: Bool) {
        if visible {
            self.playImage.hidden = false
            self.playImage.frame.size.width = 32
        }
        else {
            self.playImage.hidden = true
            self.playImage.frame.size.width = 0
        }
        
        self.titleLabel.frame.origin.x = self.playImage.frame.origin.x + self.playImage.frame.size.width + 5
        self.contentLabel.frame.origin.x = self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width + 5
    }
    
    override func drawRect(rect: CGRect) {
        self.autoSize()
        
        if self.selected {
            self.setPlayImgVisible(true)
        }
        else {
            self.setPlayImgVisible(false)
        }
    }
    
    override func layoutSubviews() {
        self.autoSize()
        
        if self.selected {
            self.setPlayImgVisible(true)
        }
        else {
            self.setPlayImgVisible(false)
        }
    }
    
    func autoSize() {
        self.playImage.center.y = self.contentView.center.y
        self.contentLabel.center.y = self.contentView.center.y
        self.titleLabel.center.y = self.contentView.center.y
        
        //设置label宽度自适应
        let titleText = self.titleLabel.text!
        let titleSize = CGSize.init(width: 1000, height: 32)
        let titleAttributes = [NSFontAttributeName: self.titleLabel.font!]
        let titleLabelszie = titleText.boundingRectWithSize(titleSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: titleAttributes, context: nil)
        self.titleLabel.frame.size.width = titleLabelszie.size.width
        
        let contentText = self.contentLabel.text!
        let contentSize = CGSize.init(width: 120, height: 32)
        let contentAttributes = [NSFontAttributeName: self.contentLabel.font!]
        let contentLabelszie = contentText.boundingRectWithSize(contentSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: contentAttributes, context: nil)
        self.contentLabel.frame.size.width = contentLabelszie.size.width
    }

}