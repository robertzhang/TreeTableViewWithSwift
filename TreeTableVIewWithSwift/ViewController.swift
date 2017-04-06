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
        let plistpath = Bundle.main.path(forResource: "DataInof", ofType: "plist")!
        let data = NSMutableArray(contentsOfFile: plistpath)
        
        // 初始化TreeNode数组
        let nodes = TreeNodeHelper.sharedInstance.getSortedNodes(data!, defaultExpandLevel: 0)
        
        // 初始化自定义的tableView
        let tableview: TreeTableView = TreeTableView(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: self.view.frame.height-20), withData: nodes)
        self.view.addSubview(tableview)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

