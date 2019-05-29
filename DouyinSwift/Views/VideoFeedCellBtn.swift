//
//  VideoFeedCellBtn.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/5/30.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

class VideoFeedCellBtn: UIControl {
    
    public let imageView: UIImageView
    public let label: UILabel
    
    required init() {
        imageView = UIImageView()
        label = UILabel(text: "0", font: .systemFont(ofSize: 12))
        super.init(frame: CGRect.zero)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        label.textColor = UIColor.white
        self.addSubview(label)
        self.addSubview(imageView)
        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        imageViewScaleAnimation(isPressed: true)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        imageViewScaleAnimation(isPressed: false)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        imageViewScaleAnimation(isPressed: false)
    }
    
    private func imageViewScaleAnimation(isPressed: Bool) {
        let scale = isPressed ? CGAffineTransform(scaleX: 1.2, y: 1.2)
                : CGAffineTransform(scaleX: 1, y: 1)
        
        UIView.animate(withDuration: 0.1) {
            self.imageView.transform = scale
        }
    }
}
