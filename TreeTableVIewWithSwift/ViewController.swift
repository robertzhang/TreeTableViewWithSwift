//
//  ViewController.swift
//  TreeTableVIewWithSwift
//
//  Created by Robert Zhang on 15/10/24.
//  Copyright © 2015年 robertzhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //获取资源
        let plistpath = NSBundle.mainBundle().pathForResource("DataInof", ofType: "plist")!
        let data = NSMutableArray(contentsOfFile: plistpath)
        
        // 初始化TreeNode数组
        let nodes = TreeNodeHelper.sharedInstance.getSortedNodes(data!, defaultExpandLevel: 0)
        
        // 初始化自定义的tableView
        let tableview: TreeTableView = TreeTableView(frame: CGRectMake(0, 20, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-20), withData: nodes)
        self.view.addSubview(tableview)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

