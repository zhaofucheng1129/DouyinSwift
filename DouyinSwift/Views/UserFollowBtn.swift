//
//  ZButton.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/2.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

class UserFollowBtn: UIControl {

    private var icon: UIImageView!
    private var label: UILabel!
    
    init() {
        super.init(frame: CGRect.zero)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
//        backgroundColor = UIColor("393B44")
        backgroundColor = UIColor("FE2C55")
        let stackView = UIStackView()
        icon = UIImageView()
        icon.image = UIImage(named: "playlist_button_follow22x22")
        label = UILabel(text: "关注", font: .systemFont(ofSize: 14))
        label.textColor = UIColor.white
        stackView.spacing = 5
        stackView.axis = .horizontal
        stackView.isUserInteractionEnabled = false
        stackView.addArrangedSubview(icon)
        stackView.addArrangedSubview(label)
        stackView.alignment = .center
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        alpha = 0.7
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        alpha = 1
        
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        guard bounds.contains(point) else { return }

        if isSelected {
            backgroundColor = UIColor("393B44")
            icon.isHidden = true
            label.text = "取消关注"
            label.font = .systemFont(ofSize: 16)
        } else {
            backgroundColor = UIColor("FE2C55")
            icon.isHidden = false
            label.text = "关注"
            label.font = .systemFont(ofSize: 14)
        }
        isSelected = !isSelected
    }
}
