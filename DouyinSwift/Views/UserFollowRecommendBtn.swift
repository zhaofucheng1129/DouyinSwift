//
//  UserFollowRecommendBtn.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/2.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

class UserFollowRecommendBtn: UIControl {

    private var icon: UIImageView!
    
    init() {
        super.init(frame: CGRect.zero)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        backgroundColor = UIColor("393B44")
        
        icon = UIImageView(image: UIImage(named: "playlist_top_arrow14x14"))
        addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if isSelected {
            UIView.animate(withDuration: 0.25, animations: {
                self.backgroundColor = UIColor("393B44")
                self.icon.transform = self.icon.transform.rotated(by: CGFloat(Float.pi))
            })
        } else {
            UIView.animate(withDuration: 0.25, animations:{
                self.backgroundColor = UIColor("FE2C55")
                self.icon.transform = self.icon.transform.rotated(by: CGFloat(Float.pi))
            })
        }
        
        isSelected = !isSelected
    }
}
