//
//  User.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/5/27.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import Foundation


struct Author: Codable {
    var uid: String
    var nickName: String
    var signature: String?
    var avatarLarger: Resource
    var avatarThumb: Resource
    var avatarMedium: Resource
    var birthday: String
    var isVerified: Bool
    var followStatus: Int
    var awemeCount: Int?
    var followingCount: Int?
    var followerCount: Int?
    var favoritingCount: Int?
    var totalFavorited: Int?
    var constellation: Int
    
    enum CodingKeys: String, CodingKey {
        case uid
        case nickName = "nickname"
        case signature
        case avatarLarger = "avatar_larger"
        case avatarThumb = "avatar_thumb"
        case avatarMedium = "avatar_medium"
        case birthday
        case isVerified = "is_verified"
        case followStatus = "follow_status"
        case awemeCount = "aweme_count"
        case followingCount = "following_count"
        case followerCount = "follower_count"
        case favoritingCount = "favoriting_count"
        case totalFavorited = "total_favorited"
        case constellation
    }
}
