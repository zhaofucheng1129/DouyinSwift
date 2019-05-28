//
//  FileManagerExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/10.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public extension FileManager {
    static func fileExistInMainBundle(fileName: String) -> Bool {
        return FileManager.default.fileExists(atPath: Bundle.main.bundlePath.appending("/\(fileName)"))
    }
}
