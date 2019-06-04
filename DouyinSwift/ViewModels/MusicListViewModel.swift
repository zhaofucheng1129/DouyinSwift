//
//  MusicListViewModel.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/5.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MusicListViewModel {
    private var musicDataSource: BehaviorRelay<[MusicCellViewModel]> = BehaviorRelay(value: [])
    
    public var dataSourceDriver: Driver<[MusicCellViewModel]> {
        return musicDataSource.asDriver().skip(1)
    }
    public var dataSource: [MusicCellViewModel] {
        return musicDataSource.value
    }
    
    func requestData(page: Int = 1) {
        let observable = DouyinApiProvider.rx.request(.music(page: page)).map([Music].self, atKeyPath: "music", using: JSONDecoder(), failsOnEmptyData: false).asObservable()
        _ = observable.subscribe(onNext: { [weak self] musics in
            guard let `self` = self else { return }
            var newArray = self.musicDataSource.value
            newArray.append(contentsOf: musics.map { MusicCellViewModel(music: $0) })
            self.musicDataSource.accept(newArray)
        })
    }
}
