//
//  UIBezierPathExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/10.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public extension UIBezierPath {
    
    
    /// 绘制一个字体轮廓曲线
    ///
    /// - Parameters:
    ///   - text: 文字
    ///   - font: 字体
    /// - Returns: 曲线
    static func bezierPath(text: String, font: UIFont) -> UIBezierPath? {
        let ctFont = font.CTFontRef
        let attrs = [kCTFontAttributeName: ctFont]
        
        guard let attrString = CFAttributedStringCreate(nil, text as CFString, attrs as CFDictionary) else { return nil }
        let line = CTLineCreateWithAttributedString(attrString)
        
        let cgPath = CGMutablePath()
        let runs = CTLineGetGlyphRuns(line) as! Array<CTRun>
        runs.forEach { (run) in
            let dict = CTRunGetAttributes(run) as! Dictionary<CFString,CTFont>
            if let runFont = dict[kCTFontAttributeName] {
                (0..<CTRunGetGlyphCount(run)).forEach({ (index) in
                    let glyphRange = CFRangeMake(index, 1)
                    var glyph: CGGlyph = 0
                    var position: CGPoint = CGPoint()
                    CTRunGetGlyphs(run, glyphRange, &glyph)
                    CTRunGetPositions(run, glyphRange, &position)

                    if let glyphPath = CTFontCreatePathForGlyph(runFont, glyph, nil) {
                        let transform = CGAffineTransform(translationX: position.x, y: position.y)
                        cgPath.addPath(glyphPath, transform: transform)
                    }
                })
            }
        }

        let path = UIBezierPath(cgPath: cgPath)
        let boundingBox = cgPath.boundingBox

        path.apply(CGAffineTransform(scaleX: 1.0, y: -1.0))
        path.apply(CGAffineTransform(translationX: 0, y: boundingBox.size.height))

        return path
    }
}
