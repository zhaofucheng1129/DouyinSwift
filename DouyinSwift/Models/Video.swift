//
//  Video.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/5/27.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import Foundation

struct Video: Codable {
    var playAddr: Resource
    var cover: Resource
    var height: Int?
    var width: Int?
    var dynamicCover: Resource
    var originCover: Resource
    var ratio: String
    var downloadAddr: Resource
    var hasWatermark: Bool
    var playAddrLowbr: Resource
    var duration: Int?
    
    enum CodingKeys: String, CodingKey {
        case playAddr = "play_addr"
        case cover
        case height
        case width
        case dynamicCover = "dynamic_cover"
        case originCover = "origin_cover"
        case ratio
        case downloadAddr = "download_addr"
        case hasWatermark = "has_watermark"
        case playAddrLowbr = "play_addr_lowbr"
        case duration
    }
}
