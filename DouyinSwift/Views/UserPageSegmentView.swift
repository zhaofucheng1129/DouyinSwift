//
//  UserPageSegmentView.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/3.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

protocol UserPageSegmentViewDelegate: AnyObject {
    func pageSegment(selectedIndex index: Int)
}

class UserPageSegmentView: UIView {
    private var labels: [UILabel] = []
    private var indicateView: UIView!
    private var indicateViewCenterX:NSLayoutConstraint!
    private var currentTag: Int = 0
    
    public weak var delegate: UserPageSegmentViewDelegate?

    init() {
        super.init(frame: CGRect.zero)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        
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
            labels.append(titleLab)
            stack.addArrangedSubview(titleLab)
            if index == currentTag {
                titleLab.textColor = UIColor.init(white: 1, alpha: 1)
                titleLab.font = .boldSystemFont(ofSize: 16)
                indicateViewCenterX = indicateView.centerXAnchor.constraint(equalTo: titleLab.centerXAnchor)
                indicateViewCenterX.isActive = true
                indicateView.widthAnchor.constraint(equalTo: titleLab.widthAnchor, multiplier: 1.2).isActive = true
            } else {
                titleLab.textColor = UIColor.init(white: 1, alpha: 0.6)
                titleLab.font = .systemFont(ofSize: 16)
            }
            titleLab.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler(tapGes:)))
            titleLab.addGestureRecognizer(tap)
        }
    }
    
    @objc func tapGestureHandler(tapGes: UITapGestureRecognizer) {
        guard let targetLabel = tapGes.view as? UILabel else { return }
        
        let currentLabel = labels[currentTag]
        
        self.removeConstraint(indicateViewCenterX)
        indicateViewCenterX = self.indicateView.centerXAnchor.constraint(equalTo: targetLabel.centerXAnchor)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.indicateViewCenterX.isActive = true
            self.layoutIfNeeded()
        }, completion: { if $0 {
            currentLabel.textColor = UIColor.init(white: 1, alpha: 0.6)
            currentLabel.font = .systemFont(ofSize: 16)
            targetLabel.textColor = UIColor.init(white: 1, alpha: 1)
            targetLabel.font = .boldSystemFont(ofSize: 16)
            self.currentTag = targetLabel.tag
            } })
        delegate?.pageSegment(selectedIndex: targetLabel.tag)
    }
    
    func setTitle(progress: CGFloat, sourceIndex: Int, targetIndex: Int) {
        self.removeConstraint(indicateViewCenterX)
        let sourceLabel = labels[sourceIndex]
        let targetLabel = labels[targetIndex]
        
        let totalDistance = targetLabel.centerX - sourceLabel.centerX
        
        self.removeConstraint(indicateViewCenterX)
        indicateViewCenterX = self.indicateView.centerXAnchor.constraint(equalTo: sourceLabel.centerXAnchor, constant: totalDistance * progress)
        indicateViewCenterX.isActive = true
        
        if progress == 1 {
            if sourceIndex == targetIndex {
                let currentLabel = labels[currentTag]
                currentLabel.textColor = UIColor.init(white: 1, alpha: 0.6)
                currentLabel.font = .systemFont(ofSize: 16)
            } else {
                sourceLabel.textColor = UIColor.init(white: 1, alpha: 0.6)
                sourceLabel.font = .systemFont(ofSize: 16)
            }
            targetLabel.textColor = UIColor.init(white: 1, alpha: 1)
            targetLabel.font = .boldSystemFont(ofSize: 16)
            currentTag = targetIndex
        }
    }
}
