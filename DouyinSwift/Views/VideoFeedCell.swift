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
import Lottie
import MediaPlayer

class VideoFeedCell: UITableViewCell {
    private var playImage: UIImageView!
    private var playerView: ZPlayerView!
    private var musicDiscBtn: VideoFeedCellMusicBtn!
    private var shareBtn: VideoFeedCellBtn!
    private var commentBtn: VideoFeedCellBtn!
    private var likeBtn: AnimationView!
    private var likeCount: UILabel!
    private var avatarBtn: UIButton!
    private var followBtn: AnimationView!
    private var musicIcon: UIImageView!
    private var musicName: VideoFeedCellMusicAlbumNameBtn!
    private var videoDesc: ZLabel!
    private var authorName: ZLabel!
    private var volumeProgressView: UIProgressView!
    
    private var viewModel:VideoCellViewModel?
    
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
        addFollowBtn()
        musicDiscBtn.resetAnimation()
    }
    
    public func bind(viewModel: VideoCellViewModel) {
        self.viewModel = viewModel
        self.playerView.viewModel = viewModel
        viewModel.playUrl.bind(to: self.playerView.rx.playUrl).disposed(by: bag)
        viewModel.status.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in
            self?.playImageAnimation(status: $0)
        }).disposed(by: bag)
        viewModel.status.accept(.none)
        viewModel.diggCount.drive(likeCount.rx.text).disposed(by: bag)
        viewModel.commentCount.drive(commentBtn.label.rx.text).disposed(by: bag)
        viewModel.shareCount.drive(shareBtn.label.rx.text).disposed(by: bag)
        viewModel.musicThumb.bind { [weak self] in
            guard let url = $0, let `self` = self else { return }
            self.musicDiscBtn.cover.load.image(with: url, completionHandler: { (result) -> UIImage? in
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
        viewModel.isLikedStatus.asDriver().drive(onNext: { [weak self] (isLike) in
            guard let `self` = self else { return }
            if isLike {
                self.likeBtn.animation = Animation.named("icon_home_dislike_new", subdirectory: "LottieResources")
            } else {
                self.likeBtn.animation = Animation.named("icon_home_like_new", subdirectory: "LottieResources")
            }
        }).disposed(by: bag)
        
        avatarBtn.rx.tap.subscribe(onNext: {  _ in
            viewModel.loadUserPageEvent.accept(())
        }).disposed(by: bag)
        
        AVAudioSession.sharedInstance().rx.observe(Float.self, "outputVolume").skip(1).subscribe(onNext: { [weak self] (volume) in
            guard let `self` = self else { return }
            self.volumeProgressView.setProgress(volume ?? 0, animated: true)
            UIView.animate(withDuration: 0.25, animations: {
                self.volumeProgressView.alpha = 1
            }) {
                if $0 {
                    UIView.animate(withDuration: 0.25, delay: 0.5, animations: {
                        self.volumeProgressView.alpha = 0
                    })
                }
            }
            
        }).disposed(by: bag)
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
            musicDiscBtn.pauseAnimation()
            musicName.pauseAnimation()
        case .playing:
            UIView.animate(withDuration: 0.15, animations: {
                self.playImage.alpha = 0
            }, completion: { _ in
                self.playImage.isHidden = false
            })
            musicDiscBtn.resumeAnimtion()
            musicName.resumeAnimation()
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
        addFollowBtn()
        addMusicName()
        addVideoDesc()
        addAuthorName()
        addVolumeProgressView()
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
        musicDiscBtn = VideoFeedCellMusicBtn()
        contentView.addSubview(musicDiscBtn)
        musicDiscBtn.translatesAutoresizingMaskIntoConstraints = false
        musicDiscBtn.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        musicDiscBtn.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
    }
    
    func addShareBtn() {
        shareBtn = VideoFeedCellBtn()
        shareBtn.imageView.image = UIImage(named: "icon_home_share40x40")
        contentView.addSubview(shareBtn)
        shareBtn.translatesAutoresizingMaskIntoConstraints = false
        shareBtn.centerXAnchor.constraint(equalTo: musicDiscBtn.centerXAnchor).isActive = true
        shareBtn.bottomAnchor.constraint(equalTo: musicDiscBtn.topAnchor, constant: -40).isActive = true
    }
    
    func addCommentBtn() {
        commentBtn = VideoFeedCellBtn()
        commentBtn.imageView.image = UIImage(named: "icon_home_comment40x40")
        contentView.addSubview(commentBtn)
        commentBtn.translatesAutoresizingMaskIntoConstraints = false
        commentBtn.centerXAnchor.constraint(equalTo: musicDiscBtn.centerXAnchor).isActive = true
        commentBtn.bottomAnchor.constraint(equalTo: shareBtn.topAnchor, constant: -10).isActive = true
    }
    
    func addLikeBtn() {
        likeCount = UILabel(text: "0", font: .systemFont(ofSize: 12))
        likeCount.textColor = UIColor.white
        likeBtn = AnimationView()
        let imageProvider = BundleImageProvider(bundle: Bundle.main, searchPath: "LottieResources")
        likeBtn.imageProvider = imageProvider
        contentView.addSubview(likeBtn)
        contentView.addSubview(likeCount)
        likeBtn.translatesAutoresizingMaskIntoConstraints = false
        likeCount.translatesAutoresizingMaskIntoConstraints = false
        likeBtn.centerXAnchor.constraint(equalTo: musicDiscBtn.centerXAnchor).isActive = true
        likeBtn.bottomAnchor.constraint(equalTo: commentBtn.topAnchor, constant: -25).isActive = true
        likeBtn.widthAnchor.constraint(equalToConstant: 55).isActive = true
        likeBtn.heightAnchor.constraint(equalToConstant: 55).isActive = true
        likeCount.topAnchor.constraint(equalTo: likeBtn.bottomAnchor).isActive = true
        likeCount.centerXAnchor.constraint(equalTo: likeBtn.centerXAnchor).isActive = true
        
        let tapGesture = UITapGestureRecognizer { [weak self] (gesture) in
            guard let `self` = self else { return }
            self.likeBtn.play(completion: { [weak self] (finished) in
                guard let `self` = self, let viewModel = self.viewModel else { return }
                viewModel.isLikedStatus.accept(!viewModel.isLikedStatus.value)
            })
        }
        likeBtn.addGestureRecognizer(tapGesture)
        
    }
    
    func addAvatarBtn() {
        avatarBtn = UIButton(type: .system)
        avatarBtn.setImage(UIImage(named: "img_find_default")?.withRenderingMode(.alwaysOriginal), for: .normal)
        avatarBtn.layer.cornerRadius = 25
        avatarBtn.layer.borderColor = UIColor.white.cgColor
        avatarBtn.borderWidth = 1
        contentView.addSubview(avatarBtn)
        avatarBtn.translatesAutoresizingMaskIntoConstraints = false
        avatarBtn.bottomAnchor.constraint(equalTo: likeBtn.topAnchor, constant: -25).isActive = true
        avatarBtn.centerXAnchor.constraint(equalTo: musicDiscBtn.centerXAnchor).isActive = true
        avatarBtn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        avatarBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func addFollowBtn() {
        if followBtn != nil, followBtn.superview != nil { return }
        followBtn = AnimationView()
        followBtn.animation = Animation.named("home_follow_add", subdirectory: "LottieResources")
        contentView.addSubview(followBtn)
        followBtn.translatesAutoresizingMaskIntoConstraints = false
        followBtn.centerXAnchor.constraint(equalTo: avatarBtn.centerXAnchor).isActive = true
        followBtn.centerYAnchor.constraint(equalTo: avatarBtn.bottomAnchor).isActive = true
        followBtn.widthAnchor.constraint(equalToConstant: 34).isActive = true
        followBtn.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        let tapGesture = UITapGestureRecognizer { [weak self] (gesture) in
            guard let `self` = self else { return }
            self.followBtn.play(completion: { [weak self](finished) in
                UIView.animate(withDuration: 0.3, delay: 0.1, animations: {
                    self?.followBtn.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                }, completion: { _ in
                    self?.followBtn.removeFromSuperview()
                })
            })
        }
        followBtn.addGestureRecognizer(tapGesture)
    }
    
    func addMusicName() {
        musicIcon = UIImageView()
        musicIcon.image = UIImage(named: "icon_home_musicnote3")
        contentView.addSubview(musicIcon)
        musicName = VideoFeedCellMusicAlbumNameBtn()
        contentView.addSubview(musicName)
        musicIcon.translatesAutoresizingMaskIntoConstraints = false
        musicName.translatesAutoresizingMaskIntoConstraints = false
        musicIcon.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        musicIcon.bottomAnchor.constraint(equalTo: musicDiscBtn.bottomAnchor).isActive = true
        musicIcon.setContentHuggingPriority(.required, for: .vertical)
        musicName.leftAnchor.constraint(equalTo: musicIcon.rightAnchor, constant: 5).isActive = true
        musicName.centerYAnchor.constraint(equalTo: musicIcon.centerYAnchor).isActive = true
        musicName.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6).isActive = true
        musicName.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
    }
    
    func addVideoDesc() {
        videoDesc = ZLabel(frame: CGRect.zero)
        videoDesc.delegate = self
        videoDesc.font = .systemFont(ofSize: 14)
        videoDesc.textColor = UIColor(white: 1, alpha: 0.9)
        videoDesc.numberOfLines = 3
        contentView.addSubview(videoDesc)
        videoDesc.translatesAutoresizingMaskIntoConstraints = false
        videoDesc.leftAnchor.constraint(equalTo: musicIcon.leftAnchor).isActive = true
        videoDesc.bottomAnchor.constraint(equalTo: musicIcon.topAnchor, constant: -8).isActive = true
        videoDesc.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.67).isActive = true
    }
    
    func addAuthorName() {
        authorName = ZLabel(frame: CGRect.zero)
        authorName.delegate = self
        authorName.isAllSelected = true
        authorName.font = .boldSystemFont(ofSize: 16)
        authorName.linkTextFont = .boldSystemFont(ofSize: 16)
        authorName.textColor = UIColor.white
        contentView.addSubview(authorName)
        authorName.translatesAutoresizingMaskIntoConstraints = false
        authorName.leftAnchor.constraint(equalTo: musicIcon.leftAnchor).isActive = true
        authorName.bottomAnchor.constraint(equalTo: videoDesc.topAnchor, constant: -8).isActive = true
        authorName.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5).isActive = true
    }
    
    func addVolumeProgressView() {
        let volumeView = MPVolumeView(frame: CGRect(x: -2000, y: -2000, width: 1, height: 1))
        contentView.addSubview(volumeView)
//        volumeView.subviews.forEach { (view) in
//            if (NSStringFromClass(view.classForCoder) == "MPVolumeSlider") {
//                volumeSlider = view as? UISlider
//                volumeSlider.sendActions(for: .touchUpInside)
//            }
//        }
//
//        volumeSlider.minimumTrackTintColor = UIColor.orange
//        volumeSlider.maximumTrackTintColor = UIColor.clear
//        volumeSlider.thumbTintColor = UIColor.clear
//        volumeSlider.isUserInteractionEnabled = false
//        contentView.addSubview(volumeSlider)
//        volumeSlider.translatesAutoresizingMaskIntoConstraints = false
//        volumeSlider.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
//        volumeSlider.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
//        volumeSlider.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        
        volumeProgressView = UIProgressView(progressViewStyle: .default)
        volumeProgressView.trackTintColor = UIColor.clear
        volumeProgressView.progressTintColor = UIColor("FBD537")
        volumeProgressView.alpha = 0
        contentView.addSubview(volumeProgressView)
        volumeProgressView.translatesAutoresizingMaskIntoConstraints = false
        volumeProgressView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        volumeProgressView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        volumeProgressView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        volumeProgressView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}

extension VideoFeedCell: ZLabelDelegate {
    func labelDidSelectedLinkText(label: ZLabel, text: String) {
        UIAlertController(title: "点击了文本", message: text, style: .alert, defaultButtonTitle: "退下").show()
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
            musicDiscBtn.setUpAnimation()
            musicName.setUpAnimation()
        default:
            break
        }
    }
}
