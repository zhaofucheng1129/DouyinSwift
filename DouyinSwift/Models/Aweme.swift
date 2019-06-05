//
//  aweme.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/5/27.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import Foundation

struct Aweme: Codable {
    var awemeId: String
    var desc:String?
    var createTime:Date
    var author: Author
    var music: Music?
    var video: Video
    var statistics: Statistics
    var authorUserId: Int
    var rate: Int
    var isTop: Int
    var labelTop: Resource?
    var isAds: Bool
    var duration: Int?
    
    enum CodingKeys: String, CodingKey {
        case awemeId = "aweme_id"
        case desc
        case createTime = "create_time"
        case author
        case music
        case video
        case statistics
        case authorUserId = "author_user_id"
        case rate
        case isTop = "is_top"
        case labelTop = "label_top"
        case isAds = "is_ads"
        case duration
    }
}
