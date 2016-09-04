//
//  DemoListCell.swift
//  Collection
//
//  Created by 刘伟 on 15/10/30.
//  Copyright © 2015年 lawrence_liu. All rights reserved.
//

import UIKit

class MusicTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var playImage: UIImageView!
    @IBOutlet weak var labelStackView: UIStackView!
    
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
            self.labelStackView.frame.origin.x = self.playImage.frame.origin.x + self.playImage.frame.size.width + 5
        }
        else {
            self.playImage.hidden = true
            self.playImage.frame.size.width = 0
            self.labelStackView.frame.origin.x = self.playImage.frame.origin.x + self.playImage.frame.size.width + 5
        }
    }
    
    override func drawRect(rect: CGRect) {
        if self.selected {
            self.setPlayImgVisible(true)
        }
        else {
            self.setPlayImgVisible(false)
        }
    }
    
    /*
    override func layoutSubviews() {
        if self.selected {
            self.setPlayImgVisible(true)
        }
        else {
            self.setPlayImgVisible(false)
        }
    }
    */
}
