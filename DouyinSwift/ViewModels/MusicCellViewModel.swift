//
//  MusicCellViewModel.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/5.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MusicCellViewModel {
    var bag: DisposeBag = DisposeBag()
    
    private let music: BehaviorRelay<Music>
    
    init(music: Music) {
        self.music = BehaviorRelay(value: music)
    }
}

// MARK: - 界面数据绑定
extension MusicCellViewModel {
    
    public var musicDriver: Driver<Music> {
        return music.asDriver()
    }
    
    public var musicCover: Driver<URL?> {
        return musicDriver.map {
            guard let str = $0.coverThumb.urlList.first else { return nil }
            return URL(string: str) ?? nil
            }.asDriver()
    }
    
    public var musicName: Driver<String> {
        return musicDriver.map {
            return $0.title
        }.asDriver()
    }
    
    public var userCount: Driver<String> {
        return musicDriver.map {
            return "\($0.userCount) 个视频使用"
        }.asDriver()
    }
    
    public var duration: Driver<String> {
        return musicDriver.map {
            let duration = $0.duration
            let m = duration / 60
            let s = duration - m * 60
            return "\(m > 10 ? "\(m)" : "0\(m)") : \(s > 10 ? "\(s)" : "0\(s)")"
        }
    }
}
