//
//  TabBarViewController.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/5.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension TabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        customTabBar.setSelected(selected: true, index: selectedIndex)
        if selectedIndex == 0 {
            customTabBar.isTranslucent = true
            customTabBar.barTintColor = nil
        } else {
            customTabBar.isTranslucent = false
            customTabBar.barTintColor = UIColor("171823")
        }
    }
}

class TabBarViewController: UITabBarController {
    
    var customTabBar = CustomTabBar()
    
    func configViewControllers() {
        let childClassNames = [
            ["ClassName": "VideoFeedViewController", "Name": "首页"],
            ["ClassName": "TimeLineViewController", "Name": "关注"],
            ["ClassName": "", "Image": "btn_home_add75x49"],
            ["ClassName": "", "Name": "消息"],
            ["ClassName": "", "Name": "我"],
        ]
        
        var childVCs: [UIViewController] = []
        var childItem: [CustomTabbarItem] = []
        childClassNames.forEach { (dict) in
            childVCs.append(buildViewController(from: dict))
            childItem.append(buildTabbarItem(from: dict))
        }
        
        viewControllers = childVCs
        
        customTabBar.tabItems = childItem
        setValue(customTabBar, forKey: "tabBar")
    }
    
    func buildViewController(from conf:Dictionary<String, String>) -> UIViewController {
        guard let className = conf["ClassName"],
            let vcCls = NSClassFromString(Bundle.appBundleName + ".\(className)") as? UIViewController.Type
        
        else {
            let temp = UIViewController()
            temp.view.backgroundColor = UIColor(red: 59, green: 89, blue: 152)
            return temp
        }
        
        let viewController = vcCls.init()
        let navVC = NavigationViewController(rootViewController: viewController)
        return navVC
    }
    
    func buildTabbarItem(from conf: Dictionary<String, String>) -> CustomTabbarItem {
        guard let name = conf["Name"] else {
            guard let image = conf["Image"] else {
                return TitleTabbarItem(title: "未知")
            }
            return ButtonTabbarItem(image: image)
        }
        return TitleTabbarItem(title: name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configViewControllers()
        delegate = self
    }
}

protocol CustomTabbarItem: UIView {
    var selectedStatus: Bool { get set }
}

class ButtonTabbarItem: UIControl, CustomTabbarItem {
    var selectedStatus: Bool = false
    
    var image: UIImageView
    
    init(image: String) {
        self.image = UIImageView(image: UIImage(named: image))
        super.init(frame: CGRect.zero)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        UIView.animate(withDuration: 0.1) {
            self.image.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
        return super.beginTracking(touch, with: event)
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        UIView.animate(withDuration: 0.1) {
            self.image.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        UIView.animate(withDuration: 0.1) {
            self.image.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}

class TitleTabbarItem: UIView, CustomTabbarItem {
    var btn: UIButton!
    var indicatorView: UIView!
    var title: String = ""
    init(title: String) {
        self.title = title
        super.init(frame: CGRect.zero)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var selectedStatus: Bool = false {
        didSet {
            if selectedStatus {
                btn.isSelected = true
                indicatorView.isHidden = false
            } else {
                btn.isSelected = false
                indicatorView.isHidden = true
            }
        }
    }
    
    func setUpUI() {
        
        btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        let normalStr = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15),NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.6)])
        btn.setAttributedTitle(normalStr, for: .normal)
        let selectedStr = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),NSAttributedString.Key.foregroundColor: UIColor.white])
        btn.setAttributedTitle(selectedStr, for: .selected)
        addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        btn.topAnchor.constraint(equalTo: topAnchor).isActive = true
        btn.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        btn.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        indicatorView = UIView()
        indicatorView.backgroundColor = UIColor.white
        indicatorView.cornerRadius = 1
        addSubview(indicatorView)
        indicatorView.isHidden = true
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.centerXAnchor.constraint(equalTo: btn.centerXAnchor).isActive = true
        indicatorView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        indicatorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        guard let title = btn.title(for: .normal) else { return }
        let titleW = title.width(for: .boldSystemFont(ofSize: 16))
        indicatorView.widthAnchor.constraint(equalToConstant: titleW).isActive = true
    }
    
}

class CustomTabBar: UITabBar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundImage = UIImage()
        shadowImage = UIImage(color: UIColor(white: 1, alpha: 0.5), size: CGSize(width: 0.5, height: 0.5))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutTabbarItem()
    }
    
    var tabItems: [CustomTabbarItem]? {
        didSet {
            guard let items = tabItems else {
                return
            }
            removeSubviews()
            items.forEach{
                if $0 is TitleTabbarItem {
                    addSubview($0)
                }
            }
        }
    }
    
    private func layoutTabbarItem()
    {
        guard let items = tabItems else { return }
        let itemW = width / CGFloat(items.count)
        for (index, item) in items.enumerated() {
            if item.frame != CGRect.zero { return }
            if index == 0 {
                item.selectedStatus = true
            }
            if item is TitleTabbarItem {
                item.frame = CGRect(x: itemW * CGFloat(index), y: 0, width: itemW, height: height)
            } else if item is ButtonTabbarItem {
                addSubview(item)
                item.frame = CGRect(x: itemW * CGFloat(index), y: 0, width: itemW, height: height)
            }
        }
    }
    
    public func setSelected(selected: Bool, index: Int) {
        guard let items = tabItems else { return }
        for (i, item) in items.enumerated() {
            if i == index {
                item.selectedStatus = true
            } else {
                item.selectedStatus = false
            }
        }
    }
}
