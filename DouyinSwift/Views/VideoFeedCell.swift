//
//  VideoFeedCell.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/5/27.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation.AVPlayerItem
import RxSwift
import RxCocoa

class VideoFeedCell: UITableViewCell {
    private var playImage: UIImageView!
    private var playerView: ZPlayerView!
    private var musicDiscImage: ImageView!
    private var musicDiscCover: ImageView!
    private var shareImage: UIImageView!
    private var shareCount: UILabel!
    private var commentImage: UIImageView!
    private var commentCount: UILabel!
    private var likeImage: UIImageView!
    private var likeCount: UILabel!
    private var avatarBtn: UIButton!
    private var followBtn: VideoCellFollowBtn!
    private var musicIcon: UIImageView!
    private var musicName: UILabel!
    private var videoDesc: UILabel!
    private var authorName: UILabel!
    
    private(set) var isReadyToPlay: Bool = false
    
    private var bag:DisposeBag = DisposeBag()
    
    public var startPlayOnReady: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
    public func bind(viewModel: VideoFeedCellViewModel) {
        self.playerView.viewModel = viewModel
        viewModel.playUrl.bind(to: self.playerView.rx.playUrl).disposed(by: bag)
        viewModel.status.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in
            self?.playImageAnimation(status: $0)
        }).disposed(by: bag)
        viewModel.status.accept(.none)
        viewModel.diggCount.drive(likeCount.rx.text).disposed(by: bag)
        viewModel.commentCount.drive(commentCount.rx.text).disposed(by: bag)
        viewModel.shareCount.drive(shareCount.rx.text).disposed(by: bag)
        viewModel.musicThumb.bind { [weak self] in
            guard let url = $0, let `self` = self else { return }
            self.musicDiscCover.load.image(with: url, completionHandler: { (result) -> UIImage? in
                switch result {
                case .failure:
                    return nil
                case .success(let image):
                    return image.roundedCorner(radius: image.imageSize.width / 2)
                }
            })
        }.disposed(by: bag)
        viewModel.avatarThumb.bind { [weak self] in
            guard let url = $0, let `self` = self else { return }
            self.avatarBtn.load.image(with: url, for: .normal, completionHandler: { (result) -> UIImage? in
                switch result {
                case .failure:
                    return nil
                case .success(let image):
                    return image.roundedCorner(radius: image.imageSize.width / 2)
                }
            })
        }.disposed(by: bag)
        viewModel.musicName.drive(musicName.rx.text).disposed(by: bag)
        viewModel.videoDesc.drive(videoDesc.rx.text).disposed(by: bag)
        viewModel.authorName.drive(authorName.rx.text).disposed(by: bag)
    }
    
    public func play() {
        playerView.play()
    }
    
    // 播放/暂停 按钮动画
    private func playImageAnimation(status: ZPlayerStatus) {
        switch status {
        case .pause:
            self.playImage.isHidden = false
            self.playImage.alpha = 0
            self.playImage.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
            UIView.animate(withDuration: 0.15, animations: {
                self.playImage.alpha = 1
                self.playImage.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        case .playing:
            UIView.animate(withDuration: 0.15, animations: {
                self.playImage.alpha = 0
            }, completion: { _ in
                self.playImage.isHidden = false
            })
        case .none:
            self.playImage.isHidden = true
        }
    }
}

// UI 相关方法
extension VideoFeedCell {
    private func setUpUI() {
        self.selectionStyle = .none
        contentView.backgroundColor = UIColor.clear
        addPlayerView()
        addPlayImage()
        addMusicDisc()
        addShareBtn()
        addCommentBtn()
        addLikeBtn()
        addAvatarBtn()
        addMusicName()
        addVideoDesc()
        addAuthorName()
    }
    
    func addPlayerView() {
        playerView = ZPlayerView()
        playerView.delegate = self
        contentView.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0).isActive = true
        playerView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0).isActive = true
        playerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        playerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
    }
    
    func addPlayImage() {
        playImage = UIImageView()
        playImage.image = UIImage(named: "icon_play_pause52x62")
        contentView.addSubview(playImage)
        playImage.translatesAutoresizingMaskIntoConstraints = false
        playImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0).isActive = true
        playImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
    }
    
    func addMusicDisc() {
        musicDiscImage = ImageView()
        musicDiscImage.image = UIImage(named: "music_cover")
        contentView.addSubview(musicDiscImage)
        musicDiscImage.translatesAutoresizingMaskIntoConstraints = false
        musicDiscImage.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -60).isActive = true
        musicDiscImage.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        musicDiscImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
        musicDiscImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
        musicDiscCover = ImageView()
        contentView.addSubview(musicDiscCover)
        musicDiscCover.translatesAutoresizingMaskIntoConstraints = false
        musicDiscCover.centerXAnchor.constraint(equalTo: musicDiscImage.centerXAnchor).isActive = true
        musicDiscCover.centerYAnchor.constraint(equalTo: musicDiscImage.centerYAnchor).isActive = true
        musicDiscCover.widthAnchor.constraint(equalToConstant: 25).isActive = true
        musicDiscCover.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    func addShareBtn() {
        shareCount = UILabel(text: "0", font: .systemFont(ofSize: 12))
        shareCount.textColor = UIColor.white
        shareImage = UIImageView()
        shareImage.image = UIImage(named: "icon_home_share40x40")
        contentView.addSubview(shareImage)
        contentView.addSubview(shareCount)
        shareImage.translatesAutoresizingMaskIntoConstraints = false
        shareCount.translatesAutoresizingMaskIntoConstraints = false
        shareImage.centerXAnchor.constraint(equalTo: musicDiscImage.centerXAnchor).isActive = true
        shareImage.bottomAnchor.constraint(equalTo: musicDiscImage.topAnchor, constant: -50).isActive = true
        shareCount.topAnchor.constraint(equalTo: shareImage.bottomAnchor).isActive = true
        shareCount.centerXAnchor.constraint(equalTo: shareImage.centerXAnchor).isActive = true
    }
    
    func addCommentBtn() {
        commentCount = UILabel(text: "0", font: .systemFont(ofSize: 12))
        commentCount.textColor = UIColor.white
        commentImage = UIImageView()
        commentImage.image = UIImage(named: "icon_home_comment40x40")
        contentView.addSubview(commentCount)
        contentView.addSubview(commentImage)
        commentCount.translatesAutoresizingMaskIntoConstraints = false
        commentImage.translatesAutoresizingMaskIntoConstraints = false
        commentImage.centerXAnchor.constraint(equalTo: musicDiscImage.centerXAnchor).isActive = true
        commentImage.bottomAnchor.constraint(equalTo: shareImage.topAnchor, constant: -25).isActive = true
        commentCount.topAnchor.constraint(equalTo: commentImage.bottomAnchor).isActive = true
        commentCount.centerXAnchor.constraint(equalTo: commentImage.centerXAnchor).isActive = true
    }
    
    func addLikeBtn() {
        likeCount = UILabel(text: "0", font: .systemFont(ofSize: 12))
        likeCount.textColor = UIColor.white
        likeImage = UIImageView()
        likeImage.image = UIImage(named: "icon_home_like_before40x40")
        contentView.addSubview(likeImage)
        contentView.addSubview(likeCount)
        likeImage.translatesAutoresizingMaskIntoConstraints = false
        likeCount.translatesAutoresizingMaskIntoConstraints = false
        likeImage.centerXAnchor.constraint(equalTo: musicDiscImage.centerXAnchor).isActive = true
        likeImage.bottomAnchor.constraint(equalTo: commentImage.topAnchor, constant: -25).isActive = true
        likeCount.topAnchor.constraint(equalTo: likeImage.bottomAnchor).isActive = true
        likeCount.centerXAnchor.constraint(equalTo: likeImage.centerXAnchor).isActive = true
    }
    
    func addAvatarBtn() {
        avatarBtn = UIButton(type: .system)
        avatarBtn.setImage(UIImage(named: "img_find_default")?.withRenderingMode(.alwaysOriginal), for: .normal)
        avatarBtn.layer.cornerRadius = 25
        avatarBtn.layer.borderColor = UIColor.white.cgColor
        avatarBtn.borderWidth = 1
        contentView.addSubview(avatarBtn)
        avatarBtn.translatesAutoresizingMaskIntoConstraints = false
        avatarBtn.bottomAnchor.constraint(equalTo: likeImage.topAnchor, constant: -25).isActive = true
        avatarBtn.centerXAnchor.constraint(equalTo: musicDiscImage.centerXAnchor).isActive = true
        avatarBtn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        avatarBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        followBtn = VideoCellFollowBtn()
        contentView.addSubview(followBtn)
        followBtn.translatesAutoresizingMaskIntoConstraints = false
        followBtn.centerXAnchor.constraint(equalTo: avatarBtn.centerXAnchor).isActive = true
        followBtn.centerYAnchor.constraint(equalTo: avatarBtn.bottomAnchor).isActive = true
        followBtn.widthAnchor.constraint(equalToConstant: 24).isActive = true
        followBtn.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
    
    func addMusicName() {
        musicIcon = UIImageView()
        musicIcon.image = UIImage(named: "icon_home_musicnote3")
        contentView.addSubview(musicIcon)
        musicName = UILabel(text: "", font: .systemFont(ofSize: 14))
        musicName.textColor = UIColor.white
        contentView.addSubview(musicName)
        musicIcon.translatesAutoresizingMaskIntoConstraints = false
        musicName.translatesAutoresizingMaskIntoConstraints = false
        musicIcon.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        musicIcon.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -60).isActive = true
        musicIcon.setContentHuggingPriority(.required, for: .vertical)
        musicName.leftAnchor.constraint(equalTo: musicIcon.rightAnchor, constant: 5).isActive = true
        musicName.centerYAnchor.constraint(equalTo: musicIcon.centerYAnchor).isActive = true
        
    }
    
    func addVideoDesc() {
        videoDesc = UILabel(text: "", font: .systemFont(ofSize: 12))
        videoDesc.textColor = UIColor.white
        videoDesc.numberOfLines = 2
        contentView.addSubview(videoDesc)
        videoDesc.translatesAutoresizingMaskIntoConstraints = false
        videoDesc.leftAnchor.constraint(equalTo: musicIcon.leftAnchor).isActive = true
        videoDesc.bottomAnchor.constraint(equalTo: musicIcon.topAnchor, constant: -8).isActive = true
        videoDesc.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5).isActive = true
    }
    
    func addAuthorName() {
        authorName = UILabel(text: "", font: .boldSystemFont(ofSize: 16))
        authorName.textColor = UIColor.white
        contentView.addSubview(authorName)
        authorName.translatesAutoresizingMaskIntoConstraints = false
        authorName.leftAnchor.constraint(equalTo: musicIcon.leftAnchor).isActive = true
        authorName.bottomAnchor.constraint(equalTo: videoDesc.topAnchor, constant: -8).isActive = true
        authorName.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5).isActive = true
    }
}

extension VideoFeedCell: ZPlayerViewDelegate {
    func onItemCurrentTimeChange(current: Float64, duration: Float64) {
        
    }
    
    func onItemStatusChange(status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            isReadyToPlay = true
            startPlayOnReady?()
        default:
            break
        }
    }
}
