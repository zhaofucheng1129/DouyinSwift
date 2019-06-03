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
    
    public func requestFeedData(page: Int = 1) {
        let feedObservable = DouyinApiProvider.rx.request(.feed(page: page)).map([Aweme].self, atKeyPath: "aweme_list", using: JSONDecoder(), failsOnEmptyData: false).asObservable()
        _ = feedObservable.subscribe(onNext: { [weak self] (awemes) in
            guard let `self` = self else { return }
            var newArray = self.videoFeedDataSource.value
            newArray.append(contentsOf: awemes.map({ (aweme) -> VideoFeedCellViewModel in return VideoFeedCellViewModel(aweme: aweme, loadUserPageEvent: self.loadUserPageEvent) }))
            self.videoFeedDataSource.accept(newArray)
        })
    }
}
