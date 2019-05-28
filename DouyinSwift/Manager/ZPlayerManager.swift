//
//  ZPlayerManager.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/5/26.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import Foundation
import AVFoundation

class ZPlayerManager {
    static let shared: ZPlayerManager = ZPlayerManager()
    
    private var players: [AVPlayer] = []
    private init() { }
    
    class func configAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord)
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
        } catch {
            print("Audio session config error \(error)")
        }
    }
    
    public func play(player: AVPlayer) {
        players.forEach { $0.pause() }
        if !players.contains(player) {
            players.append(player)
        }
        player.play()
    }
    
    public func pause(player: AVPlayer) {
        player.pause()
    }
    
    public func pasueAll() {
        players.forEach { $0.pause() }
    }
    
    public func remove(player: AVPlayer) {
        if players.contains(player) {
            players.removeAll { $0 == player }
        }
    }
    
    public func removeAll() {
        players.removeAll()
    }
}
