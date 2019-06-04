//
//  VideoViewCell.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/4.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class VideoViewCell: UICollectionViewCell {
    
    private var bag: DisposeBag = DisposeBag()
    private var coverImage: ImageView!
    private var countLable: UILabel!
    private var topIcon: ImageView!
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
    public func bind(viewModel: VideoCellViewModel) {
        viewModel.dynamicCover.drive(onNext: { [weak self] url in
            guard let `self` = self, let url = url else { return }
            self.coverImage.load.image(with: url)
        }).disposed(by: bag)
        
        viewModel.isTop.map { !$0 }.drive(topIcon.rx.isHidden).disposed(by: bag)
        viewModel.topIcon.drive(onNext: { [weak self] url in
            guard let `self` = self, let url = url else { return }
            self.topIcon.load.image(with: url)
        }).disposed(by: bag)
        viewModel.diggCount.drive(countLable.rx.text).disposed(by: bag)
    }
    
    func setUpUI() {
        coverImage = ImageView()
        coverImage.contentMode = .scaleAspectFill
        coverImage.clipsToBounds = true
        contentView.addSubview(coverImage)
        coverImage.translatesAutoresizingMaskIntoConstraints = false
        coverImage.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        coverImage.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        coverImage.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        coverImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        let likeIcon = UIImageView(image: UIImage(named: "icon_home_likenum"))
        addSubview(likeIcon)
        likeIcon.translatesAutoresizingMaskIntoConstraints = false
        likeIcon.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        likeIcon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        
        countLable = UILabel(text: "", font: .boldSystemFont(ofSize: 11))
        countLable.textColor = UIColor.white
        addSubview(countLable)
        countLable.translatesAutoresizingMaskIntoConstraints = false
        countLable.leftAnchor.constraint(equalTo: likeIcon.rightAnchor, constant: 5).isActive = true
        countLable.centerYAnchor.constraint(equalTo: likeIcon.centerYAnchor).isActive = true
        
        topIcon = ImageView()
        topIcon.isHidden = true
        addSubview(topIcon)
        topIcon.translatesAutoresizingMaskIntoConstraints = false
        topIcon.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        topIcon.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
    }

}
