//
//  VideoFeedCellMusicBtn.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/5/30.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

class VideoFeedCellMusicBtn: UIControl {
    
    public let cover: ImageView
    private let musicDiscImage: UIImageView!
    private var noteLayers: [CALayer] = []
    required init() {
        cover = ImageView()
        musicDiscImage = UIImageView()
        super.init(frame: CGRect.zero)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setUpUI() {
        musicDiscImage.image = UIImage(named: "music_cover")
        addSubview(musicDiscImage)
        musicDiscImage.translatesAutoresizingMaskIntoConstraints = false
        musicDiscImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        musicDiscImage.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        musicDiscImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        musicDiscImage.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        musicDiscImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
        musicDiscImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
        musicDiscImage.addSubview(cover)
        cover.translatesAutoresizingMaskIntoConstraints = false
        cover.centerXAnchor.constraint(equalTo: musicDiscImage.centerXAnchor).isActive = true
        cover.centerYAnchor.constraint(equalTo: musicDiscImage.centerYAnchor).isActive = true
        cover.widthAnchor.constraint(equalToConstant: 25).isActive = true
        cover.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    public func setUpAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = Double.pi * 2
        rotation.duration = 5
        rotation.isRemovedOnCompletion = false
        rotation.isCumulative = true
        rotation.repeatCount = Float.infinity
        musicDiscImage.layer.add(rotation, forKey: "rotation")
        
        setUpNoteAnimation(imageName: "icon_home_musicnote1", endPoint: CGPoint(x: -4, y: -5),
                           rotationValues: [0,Double.pi * 0.2], delay: 0)
        setUpNoteAnimation(imageName: "icon_home_musicnote1", endPoint: CGPoint(x: -15, y: -5),
                           rotationValues: [0, -Double.pi * 0.2], delay: 1)
        setUpNoteAnimation(imageName: "icon_home_musicnote2", endPoint: CGPoint(x: -25, y: -5),
                           rotationValues: [0, -Double.pi * 0.2], delay: 2)
    }
    
    func setUpNoteAnimation(imageName: String, endPoint: CGPoint, rotationValues: [Double], delay: Double) {

        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: bounds.midX, y: bounds.maxY + 10))
        bezierPath.addQuadCurve(to: endPoint, controlPoint: CGPoint(x: -30, y: bounds.maxY))
//        bezierPath.lineWidth = 1
//        let pathLayer = CAShapeLayer()
//        pathLayer.path = bezierPath.cgPath
//        pathLayer.lineWidth = 1
//        pathLayer.fillColor = UIColor.clear.cgColor
//        pathLayer.strokeColor = UIColor.red.cgColor
//        pathLayer.frame = self.bounds
//        layer.addSublayer(pathLayer)
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 3
        animationGroup.beginTime = CACurrentMediaTime() + Double(delay)
        animationGroup.repeatCount = Float.infinity
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.timingFunction = CAMediaTimingFunction(name: .linear)
        
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.path = bezierPath.cgPath
        
        let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.values = rotationValues
        
        let alphaAnimation = CAKeyframeAnimation(keyPath: "opacity")
        alphaAnimation.values = [0, 0.5, 0.9, 0.7, 0]
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1, 1, 1.2, 1.3, 1.5]
        
        animationGroup.animations = [pathAnimation,rotationAnimation,alphaAnimation,scaleAnimation]
        
        let noteLayer = CALayer()
        noteLayer.contents = UIImage(named: imageName)?.cgImage
        noteLayer.size = CGSize(width: 10, height: 10)
        noteLayer.opacity = 0
        noteLayer.add(animationGroup, forKey: nil)
        layer.addSublayer(noteLayer)
        noteLayers.append(noteLayer)
    }

    public func resetAnimation() {
        musicDiscImage.layer.removeAllAnimations()
        noteLayers.forEach { (layer) in
            layer.removeAllAnimations()
            layer.removeFromSuperlayer()
        }
    }
    
    public func pauseAnimation() {
        musicDiscImage.layer.pauseAnimation()
        noteLayers.forEach { $0.pauseAnimation() }
    }
    
    public func resumeAnimtion() {
        musicDiscImage.layer.resumeAnimation()
        noteLayers.forEach { $0.resumeAnimation() }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 0.7
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 1
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 1
    }
}
