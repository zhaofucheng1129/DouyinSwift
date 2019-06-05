//
//  TimeLineCellViewModel.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/5.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimeLineCellViewModel {
    
    private let aweme: BehaviorRelay<Aweme>
    
    init(aweme: Aweme) {
        self.aweme = BehaviorRelay(value: aweme)
    }
}

// MARK: - 界面数据绑定
extension TimeLineCellViewModel {
    
    public var awemeDriver: Driver<Aweme> {
        return aweme.asDriver()
    }
    
    public var playUrl: Driver<URL?> {
        return awemeDriver.map { (aweme) -> URL? in
            guard let urlStr = aweme.video.playAddr.urlList.first else { return nil }
            let url = URL(string: urlStr)
            return url
        }.asDriver()
    }
    
    public var avatarUrl: Driver<URL?> {
        return awemeDriver.map {
            guard let str = $0.author.avatarThumb.urlList.first else { return nil }
            return URL(string: str) ?? nil
            }.asDriver()
    }
    
    public var nickName: Driver<String> {
        return awemeDriver.map { $0.author.nickName }.asDriver()
    }
    
    public var desc: Driver<String> {
        return awemeDriver.map { $0.desc ?? "" }.asDriver()
    }
    
    public var location: Driver<String> {
        return awemeDriver.map { _ in "北京市" }.asDriver()
    }
    
    public var date: Driver<String> {
        return awemeDriver.map { $0.createTime.string(format: "MM-dd") }.asDriver()
    }
    
    public var diggText: Driver<String> {
        return awemeDriver.map { "\($0.statistics.diggCount.readability)人赞过" }.asDriver()
    }
    
    public var comentText: Driver<String> {
        return awemeDriver.map { "查看全部\($0.statistics.commentCount)条评论" }.asDriver()
    }

}
