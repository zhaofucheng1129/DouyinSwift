//
//  VideoViewCell.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/4.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

class VideoViewCell: UICollectionViewCell {
    private var coverImage: ImageView!
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        coverImage = ImageView()
        coverImage.load.image(with: URL(string: "https://p3-dy.byteimg.com/obj/25f0d000885a611410bc6")!)
        coverImage.contentMode = .scaleAspectFill
        coverImage.clipsToBounds = true
        contentView.addSubview(coverImage)
        coverImage.translatesAutoresizingMaskIntoConstraints = false
        coverImage.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        coverImage.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        coverImage.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        coverImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

}
