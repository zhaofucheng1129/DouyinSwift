//
//  VideoCellFollowBtn.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/5/29.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

class VideoCellFollowBtn: UIView {
    
    private var imageView: UIImageView!
    
    required init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor(red: 247, green: 54, blue: 87)
        setUpImage()
        setUpGesture()
    }
    
    func setUpGesture() {
        isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer { [weak self](tapGes) in
            self?.followAnimation()
        }
        addGestureRecognizer(tapGesture)
    }
    
    func setUpImage() {
        imageView = UIImageView(image: UIImage(named: "icon_personal_add_little"))
        imageView.contentMode = .center
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        imageView.widthAnchor.constraint(equalToConstant: 11).isActive = true
//        imageView.heightAnchor.constraint(equalToConstant: 11).isActive = true
    }
    
    func followAnimation() {
        addImageAxiaAnimation()
        
        UIView.beginAnimations("followAnimation", context: nil)
        UIView.setAnimationDuration(1)
        backgroundColor = UIColor.white
        UIView.commitAnimations()
    }
    
    func addImageAxiaAnimation() {
        let addImageAxiaAnimationGroup = CAAnimationGroup()
        addImageAxiaAnimationGroup.duration = 0.5
        addImageAxiaAnimationGroup.isRemovedOnCompletion = false
        addImageAxiaAnimationGroup.fillMode = .forwards
        addImageAxiaAnimationGroup.delegate = self
        
        let xAxiaAnimation = CABasicAnimation()
        xAxiaAnimation.keyPath = "transform.rotation.x"
        xAxiaAnimation.fromValue = 0
        xAxiaAnimation.toValue = CGFloat(Double.pi / 2)
        
        let zAxiaAnimation = CABasicAnimation()
        zAxiaAnimation.keyPath = "transform.rotation.z"
        zAxiaAnimation.fromValue = 0
        zAxiaAnimation.toValue = CGFloat(Double.pi / 4)
        
        let addImageAlphaAnimation = CABasicAnimation()
        addImageAlphaAnimation.keyPath = "opacity"
        addImageAlphaAnimation.fromValue = 1
        addImageAlphaAnimation.toValue = 0
        
        addImageAxiaAnimationGroup.animations = [xAxiaAnimation, zAxiaAnimation, addImageAlphaAnimation]
        imageView.layer.add(addImageAxiaAnimationGroup, forKey: "axiaAnimation")
    }
    
    func addDoneImageAxiaAnimation() {
        imageView.image = UIImage(named: "")
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.width / 2
    }
}

extension VideoCellFollowBtn: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let animation = imageView.layer.animation(forKey: "axiaAnimation")
        if animation == anim, flag {
            imageView.layer.removeAnimation(forKey: "axiaAnimation")
            addDoneImageAxiaAnimation()
        }
    }
}
