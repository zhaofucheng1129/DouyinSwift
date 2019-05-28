//
//  ZPlayerView.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/5/26.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

private let STATUS_KEYPATH = "status"
private var PlayerItemStatusContent: Void?

protocol ZPlayerViewDelegate: AnyObject {
    func onItemStatusChange(status: AVPlayerItem.Status)
    
    func onItemCurrentTimeChange(current: Float64, duration: Float64)
}

class ZPlayerView: UIView {
    
    var assetUrl: URL? {
        didSet {
            prepareToPlay()
        }
    }
    var viewModel: VideoFeedCellViewModel?
    
    var playerItem: AVPlayerItem!
    var player: AVPlayer!
    var shouldAutorepeat: Bool = true
    
    weak var delegate: ZPlayerViewDelegate?
    
    var timeObserverToken: Any?
    var playToEndObserverToken: NSObjectProtocol?
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    init(assetUrl: URL) {
        self.assetUrl = assetUrl
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.black
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        prepareToPlay()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.black
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareToPlay() {
        guard let assetUrl = assetUrl else { return }
//        let asset = AVAsset(url: assetUrl)
        playerItem = AVPlayerItem(url: assetUrl)
        if let player = player {
            ZPlayerManager.shared.remove(player: player)
        }
        player = AVPlayer(playerItem: playerItem)
        playerLayer.player = player
        playerItem.addObserver(self, forKeyPath: STATUS_KEYPATH, options: .new, context: &PlayerItemStatusContent)
        addTapControlGesture()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        DispatchQueue.main.async {
            guard let playerItem = self.playerItem, context == &PlayerItemStatusContent else { return }
            playerItem.removeObserver(self, forKeyPath: STATUS_KEYPATH)
            self.addPlayerTimeObserver()
            self.addPlayerItemEndObserver()
            
            self.delegate?.onItemStatusChange(status: playerItem.status)
        }
    }
    
    private func addPlayerTimeObserver() {
        let interval = CMTimeMakeWithSeconds(0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = self.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] (time) in
            let currentTime = CMTimeGetSeconds(time)
            guard let itemDuration = self?.playerItem.duration else { return }
            let duration = CMTimeGetSeconds(itemDuration)
            self?.delegate?.onItemCurrentTimeChange(current: currentTime, duration: duration)
        }
    }
    
    private func addPlayerItemEndObserver() {
        if let playToEndObserverToken = playToEndObserverToken {
            NotificationCenter.default.removeObserver(playToEndObserverToken)
        }
        
        playToEndObserverToken = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.playerItem,
                                               queue: OperationQueue.main) { [weak self] _ in
                                                self?.player.seek(to: CMTime.zero, completionHandler: {
                                                    if $0, self?.shouldAutorepeat ?? false {
                                                        self?.player.play()
                                                    }
                                                }) }
    }
    
    private func addTapControlGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureEvent(gesture:)))
        self.addGestureRecognizer(tap)
    }
    
    @objc private func tapGestureEvent(gesture: UITapGestureRecognizer) {
        //当前暂停状态
        if player.rate == 0 {
            play()
            viewModel?.status.accept(.playing)
        } else if (player?.rate ?? 0) > 0 {
            pause()
            viewModel?.status.accept(.pause)
        }
    }
    
    public func play() {
        ZPlayerManager.shared.play(player: player)
    }
    
    public func pause() {
        ZPlayerManager.shared.pause(player: player)
    }
    
    deinit {
        if let playToEndObserverToken = playToEndObserverToken {
            NotificationCenter.default.removeObserver(playToEndObserverToken, name: .AVPlayerItemDidPlayToEndTime, object: self.playerItem)
            self.playToEndObserverToken = nil
        }
    }
}


extension Reactive where Base: ZPlayerView {
    var playUrl: Binder<URL?> {
        return Binder(base) { playerView, url in
            playerView.assetUrl = url
        }
    }
}
