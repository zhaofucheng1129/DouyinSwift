//
//  ImageFrame.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/15.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

/// 清除方式
///
/// - none: 把当前帧增量绘制到画布上，不清空画布。
/// - background: 绘制当前帧之前，先把画布清空为默认背景色。
/// - previous: 绘制下一帧前，把先把画布恢复为当前帧的前一帧
enum ImageDisposeMethod {
    case none
    case background
    case previous
}

/// 混合模式
///
/// - none: 绘制时，全部通道（包含Alpha通道）都会覆盖到画布，相当于绘制前先清空画布的指定区域。
/// - over: 绘制时，Alpha 通道会被合成到画布，即通常情况下两张图片重叠的效果。
enum ImageBlendMode {
    case none
    case over
}

struct ImageDecoderFrame {
    var index = 0
    var width = 0
    var height = 0
    var offsetX = 0
    var offsetY = 0
    var duration: TimeInterval = 0
    var hasAlpha = true
    var isFullSize = true
    var blendFromIndex = 0
    var dispose: ImageDisposeMethod = .none
    var blend: ImageBlendMode = .none
}

struct AnimationFrame {
    let image: CGImage?
    let duration: TimeInterval
    var placeholderFrame: AnimationFrame {
        return AnimationFrame(image: nil, duration: duration)
    }
    var isPlaceholder: Bool {
        return image == nil
    }
    func makeAnimationFrame(image: CGImage?) -> AnimationFrame {
        return AnimationFrame(image: image, duration: duration)
    }
}
