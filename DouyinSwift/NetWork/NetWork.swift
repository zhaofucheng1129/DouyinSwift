//
//  NetWork.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/5/28.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import Foundation
import Moya

let DouyinApiProvider = MoyaProvider<DouyinApiManager>(stubClosure: MoyaProvider.delayedStub(2) ,plugins: [NetworkLoggerPlugin(verbose: true)])

enum DouyinApiManager {
    case feed(page: Int)
    case post(page: Int)
    case music(page: Int)
    case favorite(page: Int)
    case timeline(page: Int)
}

extension DouyinApiManager: TargetType {
    var baseURL: URL {
        return URL(string: "https://aweme-eagle-hl.snssdk.com")!
    }
    
    var path: String {
        switch self {
        case .feed:
            return "/aweme/v1/feed/"
        case .post:
            return "/aweme/v1/aweme/post/"
        case .music:
            return "/aweme/v1/original/music/list/"
        case .favorite:
            return "/aweme/v1/aweme/favorite/"
        case .timeline:
            return "/aweme/v1/forward/list/"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        switch self {
        case .feed(let page):
            return stubbedResponse("Feed\(page)")
        case .post:
            return stubbedResponse("UserVideoList")
        case .music:
            return stubbedResponse("UserMusicList")
        case .favorite:
            return stubbedResponse("UserFavoriteList")
        case .timeline:
            return stubbedResponse("UserTimeline")
        }
    }
    
    var task: Task {
        switch self {
        case .feed, .post, .music, .favorite, .timeline:
            return .requestPlain            
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    func stubbedResponse(_ filename: String) -> Data {
        guard FileManager.fileExistInMainBundle(fileName: "\(filename).json") else { return Data([]) }
        guard let path = Bundle.main.url(forResource: filename, withExtension: "json") else { return Data([]) }
        guard let data = try? Data(contentsOf: path) else { return Data([]) }
        return data
    }
}


