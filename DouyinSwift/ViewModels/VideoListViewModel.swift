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

class VideoListViewModel {
    
    enum PageStyle {
        case feed
        case post
        case favorite
    }
    
    private var style:PageStyle
    
    private var videoDataSource: BehaviorRelay<[VideoCellViewModel]> = BehaviorRelay(value: [])
    
    //首页头像点击进入用户界面事件
    private var loadUserPageEvent: BehaviorRelay<Void> = BehaviorRelay(value: ())
    public var loadUserPageEventDriver: Driver<Void> {
        return loadUserPageEvent.asDriver().skip(1)
    }
    
    //用户界面点击视频进入列表事件
    private var loadVideoListPageEvent: PublishRelay<(UICollectionView, IndexPath)> = PublishRelay()
    public var loadVideoListPageEventRelay: PublishRelay<(UICollectionView, IndexPath)> {
        return loadVideoListPageEvent
    }
    
    public var dataSourceDriver: Driver<[VideoCellViewModel]> {
        return videoDataSource.asDriver().skip(1)
    }
    public var dataSource: [VideoCellViewModel] {
        return videoDataSource.value
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
        let observable = DouyinApiProvider.rx.request(token).map([Aweme].self, atKeyPath: keyPath, using: JSONDecoder(), failsOnEmptyData: false).asObservable()
        _ = observable.subscribe(onNext: { [weak self] (awemes) in
            guard let `self` = self else { return }
            var newArray = self.videoDataSource.value
            newArray.append(contentsOf: awemes.map({ (aweme) -> VideoCellViewModel in return VideoCellViewModel(aweme: aweme, loadUserPageEvent: self.loadUserPageEvent) }))
            self.videoDataSource.accept(newArray)
        })
    }
}
