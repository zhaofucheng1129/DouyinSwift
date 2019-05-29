//
//  VideoFeedCellViewModel.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/5/27.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum ZPlayerStatus {
    case none
    case pause
    case playing
}

class VideoFeedCellViewModel {
    
    let status: BehaviorRelay<ZPlayerStatus> = BehaviorRelay(value: .none)
    let isLikedStatus: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    private let aweme: BehaviorRelay<Aweme>
    
    public var awemeObserver: Observable<Aweme> {
        return aweme.share().asObservable()
    }
    
    public var awemeDriver: Driver<Aweme> {
        return aweme.asDriver()
    }
    
    public var diggCount: Driver<String> {
        return awemeDriver.map { $0.statistics.diggCount.readability }.asDriver()
    }
    
    public var commentCount: Driver<String> {
        return awemeDriver.map { $0.statistics.commentCount.readability }.asDriver()
    }
    
    public var shareCount: Driver<String> {
        return awemeDriver.map { $0.statistics.shareCount.readability }.asDriver()
    }
    
    public var musicThumb: Observable<URL?> {
        return awemeDriver.map {
            guard let str = $0.music.coverThumb.urlList.first else { return nil }
            return URL(string: str) ?? nil
        }.asObservable()
    }
    
    public var avatarThumb: Observable<URL?> {
        return awemeDriver.map {
            guard let str = $0.author.avatarThumb.urlList.first else { return nil }
            return URL(string: str) ?? nil
        }.asObservable()
    }
    
    public var playUrl: Observable<URL?> {
        return awemeObserver.map { (aweme) -> URL? in
            guard let urlStr = aweme.video.playAddr.urlList.first else { return nil }
            let url = URL(string: urlStr)
            return url
        }
    }
    
    public var musicName: Driver<String> {
        return awemeDriver.map { (aweme) -> String in
            return aweme.music.title
        }.asDriver()
    }
    
    public var videoDesc: Driver<String?> {
        return awemeDriver.map { (aweme) -> String? in
            return aweme.desc
        }.asDriver()
    }
    
    public var authorName: Driver<String> {
        return awemeDriver.map { (aweme) -> String in
            return "@\(aweme.author.nickName)"
        }.asDriver()
    }
    
    init(aweme: Aweme) {
        self.aweme = BehaviorRelay(value: aweme)
    }
    
    
}

extension Int {
    var readability: String {
        if self < 10000 {
            return "\(self)"
        } else {
            return String(format: "%.1fw", Float(self) / 10000)
        }
    }
}
