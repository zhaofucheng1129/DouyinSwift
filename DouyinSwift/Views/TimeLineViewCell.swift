//
//  TimeLineViewCell.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/5.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Lottie

class TimeLineViewCell: UITableViewCell {
    
    private var avatarImage: ImageView!
    private var nickName: UILabel!
    private var desc: ZLabel!
    private var videoView: ZPlayerView!
    private var locationBtn: UIButton!
    private var dataLabel: UILabel!
    private var shareBtn: UIButton!
    private var commentBtn: UIButton!
    private var likeAnimation: AnimationView!
    private var btnStackView: UIStackView!
    private var diggLabel: UILabel!
    private var comentLabel: UILabel!
    private var addCommentStack: UIStackView!
    
    private var bag: DisposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
    func bind(viewModel: TimeLineCellViewModel) {
        viewModel.avatarUrl.drive(onNext: { [weak self] url in
            guard let `self` = self, let url = url else { return }
            self.avatarImage.load.image(with: url, completionHandler: { result -> UIImage? in
                switch result {
                case .failure:
                    return nil
                case .success(let image):
                    return image.roundedCorner(radius: image.imageSize.width / 2)
                }
            })
        }).disposed(by: bag)
        viewModel.nickName.drive(nickName.rx.text).disposed(by: bag)
        viewModel.desc.drive(desc.rx.text).disposed(by: bag)
        viewModel.playUrl.drive(videoView.rx.playUrl).disposed(by: bag)
        viewModel.location.drive(locationBtn.rx.title(for: .normal)).disposed(by: bag)
        viewModel.date.drive(dataLabel.rx.text).disposed(by: bag)
        viewModel.diggText.drive(diggLabel.rx.text).disposed(by: bag)
        viewModel.comentText.drive(comentLabel.rx.text).disposed(by: bag)
    }
    
}

extension TimeLineViewCell {
    func setUpUI() {
        selectionStyle = .none
        contentView.backgroundColor = UIColor("171823")
        addAvatarImage()
        addNickName()
        addDescLabel()
        addVideoView()
        addLocationBtn()
        addBtnStackView()
        addDataLabel()
        addInteractionView()
    }
    
    func addAvatarImage() {
        avatarImage = ImageView()
        contentView.addSubview(avatarImage)
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        avatarImage.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        avatarImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        avatarImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
        avatarImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
        avatarImage.setContentCompressionResistancePriority(.required, for: .vertical)
        avatarImage.setContentHuggingPriority(.required, for: .vertical)
    }
    
    func addNickName() {
        nickName = UILabel(text: "", font: .boldSystemFont(ofSize: 15))
        nickName.textColor = UIColor.white
        contentView.addSubview(nickName)
        nickName.translatesAutoresizingMaskIntoConstraints = false
        nickName.leftAnchor.constraint(equalTo: avatarImage.rightAnchor, constant: 5).isActive = true
        nickName.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor).isActive = true
    }
    
    func addDescLabel() {
        desc = ZLabel(frame: CGRect.zero)
        desc.textColor = UIColor.white
        desc.font = .systemFont(ofSize: 15)
        desc.linkTextFont = .boldSystemFont(ofSize: 15)
        desc.linkTextColor = UIColor("FACE16")!
        desc.linkTextSelectedColor = UIColor("FACE16")!
        desc.numberOfLines = 0
        contentView.addSubview(desc)
        desc.translatesAutoresizingMaskIntoConstraints = false
        desc.leftAnchor.constraint(equalTo: avatarImage.leftAnchor).isActive = true
        desc.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 10).isActive = true
        desc.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
    }
    
    func addVideoView() {
        videoView = ZPlayerView()
        videoView.cornerRadius = 5
        videoView.layer.masksToBounds = true
        videoView.videoGravity = .resizeAspectFill
        contentView.addSubview(videoView)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.leftAnchor.constraint(equalTo: avatarImage.leftAnchor).isActive = true
        videoView.topAnchor.constraint(equalTo: desc.bottomAnchor, constant: 10).isActive = true
        videoView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75).isActive = true
        videoView.heightAnchor.constraint(equalTo: videoView.widthAnchor, multiplier: 3.0 / 2.2).isActive = true
    }
    
    func addLocationBtn() {
        locationBtn = UIButton(type: .system)
        locationBtn.setImage(UIImage(named: "poi_bigLocationIcon20x20")?.resize(to: CGSize(width: 14, height: 14))?.withRenderingMode(.alwaysOriginal), for: .normal)
        locationBtn.setTitle("", for: .normal)
        locationBtn.setTitleColor(UIColor(white: 1, alpha: 0.8), for: .normal)
        locationBtn.titleLabel?.font = .systemFont(ofSize: 13)
        locationBtn.titleLabel?.setContentHuggingPriority(.required, for: .horizontal)
        locationBtn.backgroundColor = UIColor("232630")
        locationBtn.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        locationBtn.cornerRadius = 2.5
        contentView.addSubview(locationBtn)
        locationBtn.translatesAutoresizingMaskIntoConstraints = false
        locationBtn.leftAnchor.constraint(equalTo: videoView.leftAnchor).isActive = true
        locationBtn.topAnchor.constraint(equalTo: videoView.bottomAnchor, constant: 10).isActive = true
    }
    
    func addBtnStackView() {
        btnStackView = UIStackView()
        btnStackView.axis = .horizontal
        btnStackView.spacing = 15
        contentView.addSubview(btnStackView)
        btnStackView.translatesAutoresizingMaskIntoConstraints = false
        btnStackView.topAnchor.constraint(equalTo: locationBtn.bottomAnchor, constant: 18).isActive = true
        btnStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        
        btnStackView.addArrangedSubview(btnStackView(image: "icon_modern_feed_repost25x25", title: "转发"))
        btnStackView.addArrangedSubview(btnStackView(image: "icon_home_comment40x40", title: "评论"))
        btnStackView.addArrangedSubview(btnStackView(image: "icon_home_like_before40x40", title: "赞"))
    }
    
    func btnStackView(image: String, title: String) -> UIStackView {
        shareBtn = UIButton(type: .system)
        shareBtn.setImage(UIImage(named: image)?.withRenderingMode(.alwaysOriginal), for: .normal)
        shareBtn.widthAnchor.constraint(equalToConstant: 25).isActive = true
        shareBtn.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        let label = UILabel(text: "转发", font: .systemFont(ofSize: 14))
        label.textColor = UIColor.white
        
        let innerBtnStack = UIStackView()
        innerBtnStack.axis = .horizontal
        innerBtnStack.spacing = 5
        
        innerBtnStack.addArrangedSubview(shareBtn)
        innerBtnStack.addArrangedSubview(label)
        
        return innerBtnStack
    }
    
    func addDataLabel() {
        dataLabel = UILabel(text: "", font: .systemFont(ofSize: 12))
        dataLabel.textColor = UIColor(white: 1, alpha: 0.7)
        contentView.addSubview(dataLabel)
        dataLabel.translatesAutoresizingMaskIntoConstraints = false
        dataLabel.leftAnchor.constraint(equalTo: videoView.leftAnchor).isActive = true
        dataLabel.centerYAnchor.constraint(equalTo: btnStackView.centerYAnchor).isActive = true
    }
    
    func addInteractionView() {
        let interactionView = UIView(frame: CGRect.zero)
        interactionView.backgroundColor = UIColor("1D202A")
        contentView.addSubview(interactionView)
        interactionView.translatesAutoresizingMaskIntoConstraints = false
        interactionView.leftAnchor.constraint(equalTo: avatarImage.leftAnchor).isActive = true
        interactionView.topAnchor.constraint(equalTo: btnStackView.bottomAnchor, constant: 10).isActive = true
        interactionView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        interactionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        
        diggLabel = UILabel(text: "", font: .systemFont(ofSize: 13))
        diggLabel.textColor = UIColor(white: 1, alpha: 0.9)
        interactionView.addSubview(diggLabel)
        diggLabel.translatesAutoresizingMaskIntoConstraints = false
        diggLabel.leftAnchor.constraint(equalTo: interactionView.leftAnchor, constant: 10).isActive = true
        diggLabel.topAnchor.constraint(equalTo: interactionView.topAnchor, constant: 10).isActive = true
        diggLabel.rightAnchor.constraint(equalTo: interactionView.rightAnchor, constant: -10).isActive = true
        
        let line = UIView()
        line.backgroundColor = UIColor("2B2C36")
        interactionView.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.leftAnchor.constraint(equalTo: interactionView.leftAnchor).isActive = true
        line.topAnchor.constraint(equalTo: diggLabel.bottomAnchor, constant: 10).isActive = true
        line.rightAnchor.constraint(equalTo: interactionView.rightAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        comentLabel = UILabel(text: "", font: .systemFont(ofSize: 14))
        comentLabel.textColor = UIColor(white: 1, alpha: 0.7)
        interactionView.addSubview(comentLabel)
        comentLabel.translatesAutoresizingMaskIntoConstraints = false
        comentLabel.leftAnchor.constraint(equalTo: interactionView.leftAnchor, constant: 10).isActive = true
        comentLabel.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 10).isActive = true
        comentLabel.rightAnchor.constraint(equalTo: interactionView.rightAnchor, constant: -10).isActive = true
        
        addCommentStack = UIStackView()
        addCommentStack.axis = .horizontal
        addCommentStack.spacing = 10
        interactionView.addSubview(addCommentStack)
        addCommentStack.translatesAutoresizingMaskIntoConstraints = false
        addCommentStack.leftAnchor.constraint(equalTo: interactionView.leftAnchor, constant: 10).isActive = true
        addCommentStack.topAnchor.constraint(equalTo: comentLabel.bottomAnchor, constant: 10).isActive = true
        addCommentStack.rightAnchor.constraint(equalTo: interactionView.rightAnchor, constant: -10).isActive = true
        addCommentStack.bottomAnchor.constraint(equalTo: interactionView.bottomAnchor, constant: -10).isActive = true
        
        let icon = UIImageView(image: UIImage(named: "icon_moment_feed_add_comment16x16"))
        icon.setContentHuggingPriority(.required, for: .horizontal)
        addCommentStack.addArrangedSubview(icon)
        
        let addCommentLabel = UILabel(text: "添加评论...", font: .systemFont(ofSize: 13))
        addCommentLabel.textColor = UIColor.init(white: 1, alpha: 0.7)
        addCommentStack.addArrangedSubview(addCommentLabel)
    }
}
