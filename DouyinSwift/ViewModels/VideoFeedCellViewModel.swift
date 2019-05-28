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
    private let aweme: BehaviorRelay<Aweme>
    
    public var dataObserver: Observable<Aweme> {
        return aweme.share().asObservable()
    }
    
    public var playUrl: Observable<URL?> {
        return dataObserver.map { (aweme) -> URL? in
            guard let urlStr = aweme.video.playAddr.urlList.first else { return nil }
            let url = URL(string: urlStr)
            return url
        }
    }
    
    init(aweme: Aweme) {
        self.aweme = BehaviorRelay(value: aweme)
    }
    
}
