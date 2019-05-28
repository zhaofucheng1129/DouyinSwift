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

class VideoFeedViewController: UIViewController {
    
    fileprivate var currentSubject: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    fileprivate var bag: DisposeBag = DisposeBag()
    fileprivate var currentObserver: Disposable?
    
    var tableView: UITableView
    let viewModel: VideoFeedViewModel = VideoFeedViewModel()
    
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
        
        viewModel.requestFeedData()
        viewModel.dataSourceDriver.debug().drive(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.tableView.reloadData()
            self.setUpCurrentCellObserver()
        }, onCompleted: {
        }).disposed(by: bag)
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
                            cell.startPlayOnReady = { [weak cell] in
                                guard let cell = cell, let indexPath = self.tableView.indexPath(for: cell) else { return }
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
        backgroundImage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        backgroundImage.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        backgroundImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    
    func addTableView() {
        tableView.backgroundColor = UIColor(red: 29.0/255.0, green: 22.0/255.0, blue: 33.0/255.0, alpha: 1)
        tableView.register(VideoFeedCell.self, forCellReuseIdentifier: "VideoFeedCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isPagingEnabled = true
        tableView.estimatedRowHeight = self.view.frame.height
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalToSystemSpacingAfter: view.leftAnchor, multiplier: 0).isActive = true
        tableView.rightAnchor.constraint(equalToSystemSpacingAfter: view.rightAnchor, multiplier: 0).isActive = true
        tableView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 0).isActive = true
        tableView.bottomAnchor.constraint(equalToSystemSpacingBelow: view.bottomAnchor, multiplier: 0).isActive = true
        
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
