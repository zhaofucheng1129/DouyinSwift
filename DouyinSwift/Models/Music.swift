//
//  Music.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/5/27.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import Foundation

struct Music: Codable {
    var id: Int
    var idStr: String
    var title: String
    var author: String
    var album: String?
    var coverHd: Resource
    var coverLarge: Resource
    var coverMedium: Resource
    var coverThumb: Resource
    var playUrl: Resource
    var ownerId: String?
    var ownerNickname: String
    var isOriginal: Bool
    var userCount: Int
    var duration: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case idStr = "id_str"
        case title
        case author
        case album
        case coverHd = "cover_hd"
        case coverLarge = "cover_large"
        case coverMedium = "cover_medium"
        case coverThumb = "cover_thumb"
        case playUrl = "play_url"
        case ownerId = "owner_id"
        case ownerNickname = "owner_nickname"
        case isOriginal = "is_original"
        case userCount = "user_count"
        case duration
    }
}
