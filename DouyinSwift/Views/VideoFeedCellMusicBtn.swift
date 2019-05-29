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
    
    required init() {
        cover = ImageView()
        super.init(frame: CGRect.zero)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        let musicDiscImage = UIImageView()
        musicDiscImage.image = UIImage(named: "music_cover")
        addSubview(musicDiscImage)
        musicDiscImage.translatesAutoresizingMaskIntoConstraints = false
        musicDiscImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        musicDiscImage.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        musicDiscImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        musicDiscImage.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        musicDiscImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
        musicDiscImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
        addSubview(cover)
        cover.translatesAutoresizingMaskIntoConstraints = false
        cover.centerXAnchor.constraint(equalTo: musicDiscImage.centerXAnchor).isActive = true
        cover.centerYAnchor.constraint(equalTo: musicDiscImage.centerYAnchor).isActive = true
        cover.widthAnchor.constraint(equalToConstant: 25).isActive = true
        cover.heightAnchor.constraint(equalToConstant: 25).isActive = true
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
