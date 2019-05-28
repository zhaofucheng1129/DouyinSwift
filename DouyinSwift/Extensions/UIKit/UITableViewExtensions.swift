//
//  UITableViewExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/10.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public extension UITableView {
    
    /// 更新TableView的简便方法
    ///
    /// - Parameter callback: 执行的操作
    func update(callback:(_ tableView: UITableView)->Void) {
        beginUpdates()
        callback(self)
        endUpdates()
    }
    
    /// 滚动到指定位置
    ///
    /// - Parameters:
    ///   - row: 行索引
    ///   - inSection: section索引
    ///   - atPosition: 滚动的位置
    ///   - animated: 是否启用动画
    func scroll(to row: Int, inSection: Int, atPosition: UITableView.ScrollPosition = .none, animated: Bool = true) {
        let indexPath = IndexPath(row: row, section: inSection)
        scrollToRow(at: indexPath, at: atPosition, animated: animated)
    }
    
    /// 插入一行
    ///
    /// - Parameters:
    ///   - indexPath: 索引位置
    ///   - animation: 是否启用动画
    func insertRow(at indexPath: IndexPath, animation: UITableView.RowAnimation = .none) {
        insertRows(at: [indexPath], with: animation)
    }
    
    /// 插入一行
    ///
    /// - Parameters:
    ///   - row: 行索引
    ///   - inSection: Section索引
    ///   - animation: 是否启用动画
    func insertRow(row: Int, inSection: Int, animation: UITableView.RowAnimation = .none) {
        let indexPath = IndexPath(row: row, section: inSection)
        insertRow(at: indexPath, animation: animation)
    }
    
    /// 刷新指定位置的行
    ///
    /// - Parameters:
    ///   - indexPath: 索引位置
    ///   - animation: 是否启用动画
    func reload(at indexPath: IndexPath, animation: UITableView.RowAnimation = .none) {
        reloadRows(at: [indexPath], with: animation)
    }
    
    /// 刷新指定位置的行
    ///
    /// - Parameters:
    ///   - row: 行索引
    ///   - inSection: Section索引
    ///   - animation: 是否启用动画
    func reload(row: Int, inSection: Int, animation: UITableView.RowAnimation = .none) {
        let indexPath = IndexPath(row: row, section: inSection)
        reload(at: indexPath, animation: animation)
    }
    
    /// 删除指定位置的行
    ///
    /// - Parameters:
    ///   - indexPath: 索引位置
    ///   - animation: 是否启用动画
    func delete(at indexPath: IndexPath, animation: UITableView.RowAnimation = .none) {
        deleteRows(at: [indexPath], with: animation)
    }
    
    /// 删除指定位置的行
    ///
    /// - Parameters:
    ///   - row: 行索引
    ///   - inSection: Section索引
    ///   - animation: 是否启用动画
    func delete(row: Int, inSection: Int, animation: UITableView.RowAnimation = .none) {
        let indexPath = IndexPath(row: row, section: inSection)
        delete(at: indexPath, animation: animation)
    }
    
    /// 插入Section
    ///
    /// - Parameters:
    ///   - section: Section索引
    ///   - animation: 是否启用动画
    func insert(section: IndexSet.Element, animation: UITableView.RowAnimation = .none) {
        let sections = IndexSet(integer: section)
        insertSections(sections, with: animation)
    }
    
    /// 删除Section
    ///
    /// - Parameters:
    ///   - section: Section索引
    ///   - animation: 是否启用动画
    func delete(section: IndexSet.Element, animation: UITableView.RowAnimation = .none) {
        let sections = IndexSet(integer: section)
        deleteSections(sections, with: animation)
    }
    
    /// 刷新Section
    ///
    /// - Parameters:
    ///   - section: Section索引
    ///   - animation: 是否启用动画
    func reload(section: IndexSet.Element, animation: UITableView.RowAnimation = .none) {
        let sections = IndexSet(integer: section)
        reloadSections(sections, with: animation)
    }
    
    
    /// 清除所选的所有行
    ///
    /// - Parameter animated: 是否启用动画
    func clearSelectedRows(animated: Bool) {
        guard let indexs = indexPathsForSelectedRows else { return }
        indexs.forEach { deselectRow(at: $0, animated: animated) }
    }
}
