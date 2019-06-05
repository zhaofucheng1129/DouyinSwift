//
//  TimeLineListViewModel.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/5.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TimeLineListViewModel {
    private var timelineDataSource: BehaviorRelay<[TimeLineCellViewModel]> = BehaviorRelay(value: [])
    
    public var dataSourceDriver: Driver<[TimeLineCellViewModel]> {
        return timelineDataSource.asDriver().skip(1)
    }
    public var dataSource: [TimeLineCellViewModel] {
        return timelineDataSource.value
    }
    
    func requestData(page: Int = 1) {
        let observable = DouyinApiProvider.rx.request(.timeline(page: page)).map([TimeLine].self, atKeyPath: "dongtai_list", using: JSONDecoder(), failsOnEmptyData: false).asObservable()
        _ = observable.subscribe(onNext: { [weak self] timelines in
            guard let `self` = self else { return }
            var newArray = self.timelineDataSource.value
            newArray.append(contentsOf: timelines.map { TimeLineCellViewModel(aweme:$0.aweme) })
            self.timelineDataSource.accept(newArray)
        })
    }
}
