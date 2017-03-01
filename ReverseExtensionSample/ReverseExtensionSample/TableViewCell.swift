//
//  TableViewCell.swift
//  ReverseExtensionSample
//
//  Created by marty-suzuki on 2017/03/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var labelContainerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        iconImageView.layer.cornerRadius = 16
        iconImageView.layer.masksToBounds = true
        
        labelContainerView.layer.cornerRadius = 8
        labelContainerView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with message: MessageModel) {
        iconImageView.image = UIImage(named: message.imageName)
        messageLabel.text = message.message
        timeLabel.text = message.time
    }
}
