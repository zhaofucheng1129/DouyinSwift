//
//  NavigationViewController.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/5.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let interactivePopGes = interactivePopGestureRecognizer else { return }
        guard let interactivePopView = interactivePopGes.view else { return }
//        print(interactivePopView)
//        var count: UInt32 = 0
//        let ivars = class_copyIvarList(UIGestureRecognizer.self, &count)!
//        (0..<count).forEach { (i) in
//            let ivar = ivars[Int(i)]
//            let name = ivar_getName(ivar)
//            print(String(cString: name!))
//        }
        
        guard let targets = interactivePopGes.value(forKey: "_targets") as? [NSObject] else { return }
        guard let target = targets.first?.value(forKey: "target") else { return }
//        print(target)
        let action = Selector(("handleNavigationTransition:"))

        let pan = UIPanGestureRecognizer()
        interactivePopView.addGestureRecognizer(pan)
        pan.addTarget(target, action: action)
        pan.delegate = self
        
        
        navigationBar.barTintColor = UIColor("171823")
        navigationBar.isTranslucent = false
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationBar.shadowImage = UIImage(color: UIColor(white: 1, alpha: 0.5), size: CGSize(width: 0.5, height: 0.5))
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if viewControllers.count >= 1 {
            viewController.hidesBottomBarWhenPushed = true
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension NavigationViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if viewControllers.count <= 1 {
            return false
        }
        
        if (self.value(forKey: "_isTransitioning") as? Bool ?? false) {
            return false
        }
        
        let translation = gestureRecognizer.location(in: gestureRecognizer.view)
        if translation.x <= 0 {
            return false
        }
        
        return true
    }
}

// MARK: - 解决全屏滑动时的手势冲突
extension UIScrollView: UIGestureRecognizerDelegate {
    
    // 当UIScrollView在水平方向滑动到第一个时，默认是不能全屏滑动返回的，通过下面的方法可实现其滑动返回。
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if panBack(gestureRecognizer: gestureRecognizer) {
            return false
        }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if panBack(gestureRecognizer: gestureRecognizer) {
            return true
        }
        return false
    }
    
    func panBack(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.panGestureRecognizer {
            let point = self.panGestureRecognizer.translation(in: self)
            let state = gestureRecognizer.state
            
            // 设置手势滑动的位置距屏幕左边的区域
            let locationDistance = UIScreen.main.bounds.size.width
            
            if state == UIGestureRecognizer.State.began || state == UIGestureRecognizer.State.possible {
                let location = gestureRecognizer.location(in: self)
                if point.x > 0 && location.x < locationDistance && self.contentOffset.x <= 0 {
                    return true
                }
            }
        }
        return false
    }
}
