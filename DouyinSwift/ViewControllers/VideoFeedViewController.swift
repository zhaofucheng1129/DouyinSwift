//
//  VideoFeedViewController.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/5/23.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MediaPlayer

class VideoFeedViewController: UIViewController {
    
    fileprivate var currentSubject: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    fileprivate var bag: DisposeBag = DisposeBag()
    fileprivate var currentObserver: Disposable?
    
    var tableView: UITableView
    let viewModel: VideoListViewModel = VideoListViewModel(style: .feed)
    
    required init() {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackgroundImage()
        addTableView()
        
        viewModel.requestData()
        viewModel.dataSourceDriver.drive(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.tableView.reloadData()
            self.setUpCurrentCellObserver()
        }).disposed(by: bag)
        
        viewModel.loadUserPageEventDriver.drive(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            ZPlayerManager.shared.pasueAll()
            self.navigationController?.pushViewController(UserPageViewController(), animated: true)
        }).disposed(by: bag)
        
        let pan = UIPanGestureRecognizer { (gesture) in
            print("滑动手势")
        }
        pan.isEnabled = false
        self.view.addGestureRecognizer(pan)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ZPlayerManager.shared.pause(owner: self)
    }
    
    func setUpCurrentCellObserver() {
        guard let _ = currentObserver else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.currentObserver = self.currentSubject.asDriver().drive(
                    onNext: { [weak self](index) in
                        guard let `self` = self ,let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? VideoFeedCell else { return }
                        if cell.isReadyToPlay {
                            cell.play()
                        } else {
                            ZPlayerManager.shared.pasueAll()
                            cell.startPlayOnReady = { [weak cell, weak self] in
                                guard let `self` = self, let cell = cell, let indexPath = self.tableView.indexPath(for: cell) else { return }
                                if self.currentSubject.value == indexPath.row {
                                    cell.play()
                                }
                            }
                        }
                })
                self.currentObserver?.disposed(by: self.bag)
            }
            return
        }
        
    }
}

extension VideoFeedViewController {
    func addBackgroundImage() {
        let backgroundImage = UIImageView()
        backgroundImage.image = UIImage(named: "img_video_loading_max375x685")
        view.addSubview(backgroundImage)
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImage.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundImage.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func addTableView() {
        tableView.backgroundColor = UIColor(red: 29.0/255.0, green: 22.0/255.0, blue: 33.0/255.0, alpha: 1)
        tableView.register(VideoFeedCell.self, forCellReuseIdentifier: "VideoFeedCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isPagingEnabled = true
        tableView.estimatedRowHeight = self.view.frame.height
        tableView.showsVerticalScrollIndicator = false
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
}

extension VideoFeedViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height
    }
}

extension VideoFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoFeedCell", for: indexPath) as! VideoFeedCell
        let cellViewModel = viewModel.dataSource[indexPath.row]
        cell.bind(viewModel: cellViewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
}

extension VideoFeedViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let cell = tableView.visibleCells.first, let index = tableView.indexPath(for: cell) else { return }
        guard currentSubject.value != index.row else { return }
        currentSubject.accept(index.row)
    }

}
