//
//  Statistics.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/5/28.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import Foundation

struct Statistics: Codable {
    var awemeId: String
    var commentCount: Int
    var diggCount: Int
    var downloadCount: Int
    var playCount: Int
    var shareCount: Int
    var forwardCount: Int
    
    enum CodingKeys: String, CodingKey {
        case awemeId = "aweme_id"
        case commentCount = "comment_count"
        case diggCount = "digg_count"
        case downloadCount = "download_count"
        case playCount = "play_count"
        case shareCount = "share_count"
        case forwardCount = "forward_count"
    }
}
