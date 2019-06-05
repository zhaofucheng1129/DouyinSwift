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
