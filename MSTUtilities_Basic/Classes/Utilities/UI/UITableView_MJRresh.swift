//
//  UITableView_MJRresh.swift
//  Citizen_Swift
//
//  Created by Mustard on 2019/12/6.
//  Copyright © 2019 GaoBang. All rights reserved.
//

import UIKit
import MJRefresh

public extension UITableView {
    func mst_addRefresh(target: Any, action: Selector) {
        let header = MJRefreshNormalHeader(refreshingTarget: target, refreshingAction: action)
        
        mj_header = header
    }
    
    func mst_addLoadMore(target: Any, action: Selector) {
        let footer = MJRefreshAutoNormalFooter(refreshingTarget: target, refreshingAction: action)
        
        mj_footer = footer
    }
}

public extension UITableView {
    func mst_beginRefresh() {
        mj_header?.beginRefreshing()
    }
    
    func mst_endRefreshing() {
        if mj_header?.isRefreshing ?? false {
            mj_header?.endRefreshing()
        }
        
        if mj_footer?.isRefreshing ?? false {
            mj_footer?.endRefreshing()
        }
    }
    
    func mst_endRefreshingAfter(_ timeInterval: Double) {
        MSTTools.doTask(deadline: timeInterval) {
            self.mst_endRefreshing()
        }
    }
    
    func mst_endRefreshingWithNoMoreData() {
        mst_endRefreshing()
        
        mj_footer?.endRefreshingWithNoMoreData()
    }
}

public extension UITableView {
    func mst_removeHeader() {
        mj_header = nil
    }
    
    func mst_removeFooter() {
        mj_footer = nil
    }
}
