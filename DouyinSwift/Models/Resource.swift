//
//  Avatar.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/5/27.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import Foundation

struct Resource: Codable {
    var uri: String
    var urlList: [String]
    var width: Int?
    var height: Int?
    
    enum CodingKeys: String, CodingKey {
        case uri
        case urlList = "url_list"
        case width
        case height
    }
}
