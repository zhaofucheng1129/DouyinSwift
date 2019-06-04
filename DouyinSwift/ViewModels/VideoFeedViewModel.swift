//
//  VideoFeedViewModel.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/5/28.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa



class VideoFeedViewModel {
    
    enum PageStyle {
        case feed
        case post
        case favorite
    }
    
    private var style:PageStyle
    
    private var videoFeedDataSource: BehaviorRelay<[VideoFeedCellViewModel]> = BehaviorRelay(value: [])
    
    private var loadUserPageEvent: BehaviorRelay<Void> = BehaviorRelay(value: ())
    public var loadUserPageEventDriver: Driver<Void> {
        return loadUserPageEvent.asDriver().skip(1)
    }
    
    public var dataSourceDriver: Driver<[VideoFeedCellViewModel]> {
        return videoFeedDataSource.asDriver().skip(1)
    }
    public var dataSource: [VideoFeedCellViewModel] {
        return videoFeedDataSource.value
    }
    
    init(style: PageStyle) {
        self.style = style
    }
    
    public func requestData(page: Int = 1) {
        var token: DouyinApiManager = .feed(page: page)
        var keyPath: String = ""
        switch style {
        case .feed:
            token = .feed(page: page)
            keyPath = "aweme_list"
        case .post:
            token = .post(page: page)
            keyPath = "aweme_list"
        case .favorite:
            token = .favorite(page: page)
            keyPath = "aweme_list"
        }
        let feedObservable = DouyinApiProvider.rx.request(token).map([Aweme].self, atKeyPath: keyPath, using: JSONDecoder(), failsOnEmptyData: false).asObservable()
        _ = feedObservable.subscribe(onNext: { [weak self] (awemes) in
            guard let `self` = self else { return }
            var newArray = self.videoFeedDataSource.value
            newArray.append(contentsOf: awemes.map({ (aweme) -> VideoFeedCellViewModel in return VideoFeedCellViewModel(aweme: aweme, loadUserPageEvent: self.loadUserPageEvent) }))
            self.videoFeedDataSource.accept(newArray)
        })
    }
}
