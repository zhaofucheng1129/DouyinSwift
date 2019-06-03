//
//  VideoFeedViewNavController.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/1.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

class VideoFeedViewNavController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarHidden(true, animated: animated)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
