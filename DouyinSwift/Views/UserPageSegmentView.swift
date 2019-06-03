//
//  UserPageSegmentView.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/3.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

class UserPageSegmentView: UIView {
    private var labels: [UILabel] = []
    private var indicateView: UIView!
    private var currentTag: Int = 0

    init() {
        super.init(frame: CGRect.zero)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalCentering
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stack.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        stack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        indicateView = UIView()
        indicateView.backgroundColor = UIColor("FACE16")
        addSubview(indicateView)
        indicateView.translatesAutoresizingMaskIntoConstraints = false
        indicateView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        indicateView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        let titles = ["音乐", "作品", "动态", "喜欢"]
        for (index, title) in titles.enumerated() {
            let titleLab = UILabel(text: title, font: .systemFont(ofSize: 16))
            titleLab.tag = index
            stack.addArrangedSubview(titleLab)
            if index == currentTag {
                titleLab.textColor = UIColor.init(white: 1, alpha: 1)
                titleLab.font = .boldSystemFont(ofSize: 17)
                indicateView.centerXAnchor.constraint(equalTo: titleLab.centerXAnchor).isActive = true
                indicateView.widthAnchor.constraint(equalTo: titleLab.widthAnchor, multiplier: 1.2).isActive = true
            } else {
                titleLab.textColor = UIColor.init(white: 1, alpha: 0.6)
                titleLab.font = .systemFont(ofSize: 16)
            }
        }
        
    }
    
}
