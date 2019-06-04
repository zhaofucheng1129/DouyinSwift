//
//  UserPageHeaderView.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/2.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

var segmentViewHeight: CGFloat { return 40 }

class UserPageHeaderView: UICollectionReusableView {
    
    private var bag: DisposeBag = DisposeBag()
    
    private var headerImage: ImageView!
    private var avatarBtn: UIButton!
    private var bgContainerView: UIView!
    private var recommendBtn: UserFollowRecommendBtn!
    private var followBtn: UserFollowBtn!
    private var sendMsgBtn: UserSendMessageBtn!
    private var btnStack: UIStackView!
    private var nickNameStack: UIStackView!
    private var splitLine: UIView!
    private var userDesc: UILabel!
    private var userInfoTagStack: UIStackView!
    private var statisticStack: UIStackView!
    public var segmentView: UserPageSegmentView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
    override var reuseIdentifier: String? {
        return UserPageHeaderView.self.description()
    }
}

// MARK: - UI 相关方法
extension UserPageHeaderView {
    fileprivate func setUpUI() {
        addBackgroundImage()
        addBgContainerView()
        addAvatarBtn()
        addBtnStack()
        addFollowBtn()
        addSendMessageBtn()
        addRecommendBtn()
        addNickNameAndDesc()
        addSplitLine()
        addUserDesc()
        addUserInfoTag()
        addStatisticInfo()
        addSegmentView()
    }
    
    private func addBackgroundImage() {
        headerImage = ImageView()
        headerImage.load.image(with: URL(string: "https://p3-dy.byteimg.com/obj/2406a00005d38ce848bc6")!)
        headerImage.contentMode = .scaleAspectFill
        addSubview(headerImage)
        headerImage.translatesAutoresizingMaskIntoConstraints = false
        headerImage.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        headerImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        headerImage.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        headerImage.heightAnchor.constraint(equalTo: headerImage.widthAnchor, multiplier: 280.0 / 750.0).isActive = true
    }
    
    private func addBgContainerView() {
        bgContainerView = UIView()
        bgContainerView.backgroundColor = UIColor("171823")
        addSubview(bgContainerView)
        bgContainerView.translatesAutoresizingMaskIntoConstraints = false
        bgContainerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bgContainerView.topAnchor.constraint(equalTo: headerImage.bottomAnchor, constant: -15).isActive = true
        bgContainerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bgContainerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    private func addAvatarBtn() {
        avatarBtn = UIButton(type: .system)
        avatarBtn.load.image(with: URL(string: "http://p1-dy.byteimg.com/img/mosaic-legacy/2405300041b28c046fc8e~300x300.webp")!, for: .normal, placeholder: UIImage(named: "img_find_default"), completionHandler: { (result) -> UIImage? in
            switch result {
            case .failure:
                return nil
            case .success(let image):
                return image.roundedCorner(radius: image.imageSize.width / 2, borderWidth: 5, borderColor: UIColor("1D1621"))
            }
        })
        bgContainerView.addSubview(avatarBtn)
        avatarBtn.translatesAutoresizingMaskIntoConstraints = false
        avatarBtn.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        avatarBtn.topAnchor.constraint(equalTo: bgContainerView.topAnchor, constant: -20).isActive = true
        avatarBtn.widthAnchor.constraint(equalToConstant: 100).isActive = true
        avatarBtn.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    private func addBtnStack() {
        btnStack = UIStackView()
        btnStack.axis = .horizontal
        btnStack.alignment = .fill
        btnStack.distribution = .fill
        btnStack.spacing = 5
        bgContainerView.addSubview(btnStack)
        btnStack.translatesAutoresizingMaskIntoConstraints = false
        btnStack.topAnchor.constraint(equalTo: bgContainerView.topAnchor, constant: 20).isActive = true
        btnStack.rightAnchor.constraint(equalTo: bgContainerView.rightAnchor, constant: -20).isActive = true
        btnStack.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnStack.leftAnchor.constraint(equalTo: avatarBtn.rightAnchor, constant: 20).isActive = true
    }
    
    private func addRecommendBtn() {
        recommendBtn = UserFollowRecommendBtn()
        recommendBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        recommendBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        recommendBtn.cornerRadius = 2.5
        btnStack.addArrangedSubview(recommendBtn)
    }
    
    private func addSendMessageBtn() {
        sendMsgBtn = UserSendMessageBtn()
        sendMsgBtn.cornerRadius = 2.5
        sendMsgBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        sendMsgBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        sendMsgBtn.isHidden = true
        btnStack.addArrangedSubview(sendMsgBtn)
    }
    
    private func addFollowBtn() {
        followBtn = UserFollowBtn()
        followBtn.cornerRadius = 2.5
        followBtn.setContentHuggingPriority(.defaultLow, for: .horizontal)
        btnStack.addArrangedSubview(followBtn)
        followBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            UIView.animate(withDuration: 0.25, animations: {
                self.sendMsgBtn.isHidden = !self.followBtn.isSelected
                self.sendMsgBtn.superview?.setNeedsLayout()
            })
        }).disposed(by: bag)
    }
    
    private func addNickNameAndDesc() {
        nickNameStack = UIStackView()
        nickNameStack.alignment = .fill
        nickNameStack.axis = .vertical
        nickNameStack.distribution = .equalSpacing
        nickNameStack.spacing = 8
        bgContainerView.addSubview(nickNameStack)
        nickNameStack.translatesAutoresizingMaskIntoConstraints = false
        nickNameStack.leftAnchor.constraint(equalTo: avatarBtn.leftAnchor).isActive = true
        nickNameStack.topAnchor.constraint(equalTo: avatarBtn.bottomAnchor, constant: 10).isActive = true
        nickNameStack.rightAnchor.constraint(equalTo: bgContainerView.rightAnchor, constant: -16).isActive = true
        
        let nickName = UILabel(text: "我叫Abbily", font: .boldSystemFont(ofSize: 26))
        nickName.textColor = UIColor.white
        nickNameStack.addArrangedSubview(nickName)
        
        let douyinId = UILabel(text: "抖音号:abbily", font: .systemFont(ofSize: 12))
        douyinId.textColor = UIColor.white
        nickNameStack.addArrangedSubview(douyinId)
        
        let tagStack = UIStackView()
        tagStack.axis = .horizontal
        tagStack.alignment = .center
        tagStack.distribution = .equalCentering
        nickNameStack.addArrangedSubview(tagStack)
        
        let douyinTagStack = UIStackView()
        douyinTagStack.spacing = 4
        
        let douyinTagIcon = UIImageView(image: UIImage(named: "im_musicianVerified20x20"))
        douyinTagIcon.widthAnchor.constraint(equalToConstant: 12).isActive = true
        douyinTagIcon.heightAnchor.constraint(equalToConstant: 12).isActive = true
        douyinTagStack.addArrangedSubview(douyinTagIcon)
        let douyInLabel = UILabel(text: "抖音音乐人", font: .systemFont(ofSize: 14))
        douyInLabel.textColor = UIColor.white
        douyinTagStack.addArrangedSubview(douyInLabel)
        
        tagStack.addArrangedSubview(douyinTagStack)
        
        let toutiaoTagIcon = UIImageView(image: UIImage(named: "iconProfileToutiao20x20"))
        toutiaoTagIcon.widthAnchor.constraint(equalToConstant: 12).isActive = true
        toutiaoTagIcon.heightAnchor.constraint(equalToConstant: 12).isActive = true
        douyinTagStack.addArrangedSubview(toutiaoTagIcon)
        let toutiaoLabel = UILabel(text: "头条主页", font: .systemFont(ofSize: 14))
        toutiaoLabel.textColor = UIColor.white
        douyinTagStack.addArrangedSubview(toutiaoLabel)
        
        tagStack.addArrangedSubview(douyinTagStack)
    }
    
    private func addSplitLine() {
        splitLine = UIView()
        splitLine.backgroundColor = UIColor(white: 1, alpha: 0.2)
        bgContainerView.addSubview(splitLine)
        splitLine.translatesAutoresizingMaskIntoConstraints = false
        splitLine.leftAnchor.constraint(equalTo: nickNameStack.leftAnchor).isActive = true
        splitLine.topAnchor.constraint(equalTo: nickNameStack.bottomAnchor, constant: 10).isActive = true
        splitLine.rightAnchor.constraint(equalTo: nickNameStack.rightAnchor).isActive =  true
        splitLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    private func addUserDesc() {
        let textAttr = NSMutableAttributedString(string: "👤Ta正在关注你哦\n网络歌手\\平面模特\\个人舞蹈练习生\n路人视角在喜欢列表")
        textAttr.addAttribute(.foregroundColor, value: UIColor(white: 1, alpha: 1), range: NSRange(location: 0, length: textAttr.length))
        textAttr.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: textAttr.length))
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        style.alignment = .natural
        textAttr.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: textAttr.length))
        
        userDesc = UILabel()
        userDesc.attributedText = textAttr
        userDesc.numberOfLines = 0
        bgContainerView.addSubview(userDesc)
        userDesc.translatesAutoresizingMaskIntoConstraints = false
        userDesc.leftAnchor.constraint(equalTo: nickNameStack.leftAnchor).isActive = true
        userDesc.topAnchor.constraint(equalTo: splitLine.bottomAnchor, constant: 10).isActive = true
    }
    
    private func addUserInfoTag() {
        userInfoTagStack = UIStackView()
        userInfoTagStack.axis = .horizontal
        userInfoTagStack.spacing = 5
        bgContainerView.addSubview(userInfoTagStack)
        userInfoTagStack.translatesAutoresizingMaskIntoConstraints = false
        userInfoTagStack.leftAnchor.constraint(equalTo: userDesc.leftAnchor).isActive = true
        userInfoTagStack.topAnchor.constraint(equalTo: userDesc.bottomAnchor, constant: 10).isActive = true
    
        userInfoTagStack.addArrangedSubview(userInfoTagBtn(title: "20岁", imageName: "icon_girl12x12"))
        userInfoTagStack.addArrangedSubview(userInfoTagBtn(title: "北京·朝阳"))
        userInfoTagStack.addArrangedSubview(userInfoTagBtn(title: "清华大学"))
        
    }
    
    private func userInfoTagBtn(title: String, imageName: String? = nil) -> UIButton {
        let btn = UIButton(type: .system)
        if let imgName = imageName {
            btn.setImage(UIImage(named: imgName)?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.backgroundColor = UIColor(white: 1, alpha: 0.2)
        btn.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        btn.cornerRadius = 2.5
        return btn
    }
    
    private func addStatisticInfo() {
        statisticStack = UIStackView()
        statisticStack.axis = .horizontal
        statisticStack.spacing = 20
        bgContainerView.addSubview(statisticStack)
        statisticStack.translatesAutoresizingMaskIntoConstraints = false
        statisticStack.leftAnchor.constraint(equalTo: userInfoTagStack.leftAnchor).isActive = true
        statisticStack.topAnchor.constraint(equalTo: userInfoTagStack.bottomAnchor, constant: 20).isActive = true
        
        statisticStack.addArrangedSubview(statisticLab(count: "3621.0w", name: "获赞"))
        statisticStack.addArrangedSubview(statisticLab(count: "107", name: "关注"))
        statisticStack.addArrangedSubview(statisticLab(count: "721.7w", name: "粉丝"))
    }
    
    private func statisticLab(count: String, name: String) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        
        let countLab = UILabel(text: count, font: .boldSystemFont(ofSize: 16))
        countLab.textColor = UIColor.white
        
        let nameLab = UILabel(text: name, font: .systemFont(ofSize: 15))
        nameLab.textColor = UIColor(white: 1, alpha: 0.7)
        
        stack.addArrangedSubview(countLab)
        stack.addArrangedSubview(nameLab)
        return stack
    }
    
    private func addSegmentView() {
        segmentView = UserPageSegmentView()
        bgContainerView.addSubview(segmentView)
        segmentView.translatesAutoresizingMaskIntoConstraints = false
        segmentView.leftAnchor.constraint(equalTo: statisticStack.leftAnchor).isActive = true
        segmentView.rightAnchor.constraint(equalTo: bgContainerView.rightAnchor, constant: -16).isActive = true
        segmentView.bottomAnchor.constraint(equalTo: bgContainerView.bottomAnchor).isActive = true
        segmentView.heightAnchor.constraint(equalToConstant: segmentViewHeight).isActive = true
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(white: 1, alpha: 0.2)
        bgContainerView.addSubview(bottomLine)
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.leftAnchor.constraint(equalTo: bgContainerView.leftAnchor).isActive = true
        bottomLine.bottomAnchor.constraint(equalTo: bgContainerView.bottomAnchor).isActive = true
        bottomLine.rightAnchor.constraint(equalTo: bgContainerView.rightAnchor).isActive =  true
        bottomLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    func backgroundImageAnimation(offset: CGFloat) {
        let rotio = CGFloat(fabsf(Float(offset))) / width
        let height = (rotio * width) / 2
        headerImage.transform = CGAffineTransform(scaleX: rotio + 1, y: rotio + 1).concatenating(CGAffineTransform(translationX: 0, y: -height))
        
    }
}
