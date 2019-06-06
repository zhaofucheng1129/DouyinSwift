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
    private var playerDic: [Int:[AVPlayer]] = [:]
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
    
    public func play<T>(owner:T ,player: AVPlayer) where T: Hashable {
        pause(owner: owner)
        var players = playerDic[owner.hashValue] ?? [AVPlayer]()
        players.forEach { $0.pause() }
        if !players.contains(player) {
            players.append(player)
        }
        playerDic[owner.hashValue] = players
        player.play()
        
        print(playerDic)
    }
    
    public func pause(player: AVPlayer) {
        player.pause()
    }
    
    public func pause<T>(owner: T) where T: Hashable {
        guard let players = playerDic[owner.hashValue] else { return }
        players.forEach { $0.pause() }
    }
    
    public func pasueAll() {
        playerDic.values.forEach { (players) in
            players.forEach { $0.pause() }
        }
    }
    
    public func remove<T>(owner: T, player: AVPlayer) where T: Hashable {
        guard let players = playerDic[owner.hashValue] else { return }
        playerDic[owner.hashValue] = players.filter { $0 != player }
    }
    
    public func remove<T>(owner: T) where T: Hashable {
        playerDic.removeValue(forKey: owner.hashValue)
    }
    
    public func removeAll() {
        playerDic.removeAll()
    }
}
