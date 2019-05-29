//
//  VideoCellFollowBtn.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/5/29.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

class VideoCellFollowBtn: UIImageView {
    
    required init() {
        super.init(frame: CGRect.zero)
        layer.backgroundColor = UIColor(red: 247, green: 54, blue: 87)?.cgColor
        image = UIImage(named: "icon_personal_add_little")
        contentMode = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.width / 2
    }
}
