//
//  TreeTableView.swift
//  TreeTableVIewWithSwift
//
//  Created by Robert Zhang on 15/10/24.
//  Copyright © 2015年 robertzhang. All rights reserved.
//

import UIKit

protocol TreeTableViewCellDelegate: NSObjectProtocol {
    func cellClick() //参数还没加，TreeNode表示节点
}


class TreeTableView: UITableView, UITableViewDataSource,UITableViewDelegate{
    
    var mAllNodes: [TreeNode]? //所有的node
    var mNodes: [TreeNode]? //可见的node
    
    //    var treeTableViewCellDelegate: TreeTableViewCellDelegate?
    
    let NODE_CELL_ID: String = "nodecell"
    
    init(frame: CGRect, withData data: [TreeNode]) {
        super.init(frame: frame, style: UITableViewStyle.plain)
        self.delegate = self
        self.dataSource = self
        mAllNodes = data
        mNodes = TreeNodeHelper.sharedInstance.filterVisibleNode(mAllNodes!)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 通过nib自定义tableviewcell
        let nib = UINib(nibName: "TreeNodeTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: NODE_CELL_ID)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NODE_CELL_ID) as! TreeNodeTableViewCell
        
        let node: TreeNode = mNodes![indexPath.row]
        
        //cell缩进
        cell.background.bounds.origin.x = -20.0 * CGFloat(node.getLevel())
        
        //代码修改nodeIMG---UIImageView的显示模式.
        if node.type == TreeNode.NODE_TYPE_G {
            cell.nodeIMG.contentMode = UIViewContentMode.center
            cell.nodeIMG.image = UIImage(named: node.icon!)
        } else {
            cell.nodeIMG.image = nil
        }
        
        cell.nodeName.text = node.name
        cell.nodeDesc.text = node.desc
        return cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (mNodes?.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parentNode = mNodes![indexPath.row]
        
        let startPosition = indexPath.row+1
        var endPosition = startPosition
        
        if parentNode.isLeaf() {// 点击的节点为叶子节点
            // do something
        } else {
            expandOrCollapse(&endPosition, node: parentNode)
            mNodes = TreeNodeHelper.sharedInstance.filterVisibleNode(mAllNodes!) //更新可见节点
            
            //修正indexpath
            var indexPathArray :[IndexPath] = []
            var tempIndexPath: IndexPath?
            for i in startPosition ..< endPosition {
                tempIndexPath = IndexPath(row: i, section: 0)
                indexPathArray.append(tempIndexPath!)
            }
            
            // 插入和删除节点的动画
            if parentNode.isExpand {
                self.insertRows(at: indexPathArray, with: UITableViewRowAnimation.none)
            } else {
                self.deleteRows(at: indexPathArray, with: UITableViewRowAnimation.none)
            }
            //更新被选组节点
            self.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            
        }
        
    }
    
    //展开或者关闭某个节点
    func expandOrCollapse(_ count: inout Int, node: TreeNode) {
        if node.isExpand { //如果当前节点是开着的，需要关闭节点下的所有子节点
            closedChildNode(&count,node: node)
        } else { //如果节点是关着的，打开当前节点即可
            count += node.children.count
            node.setExpand(true)
        }
        
    }
    
    //关闭某个节点和该节点的所有子节点
    func closedChildNode(_ count:inout Int, node: TreeNode) {
        if node.isLeaf() {
            return
        }
        if node.isExpand {
            node.isExpand = false
            for item in node.children { //关闭子节点
                count += 1 // 计算子节点数加一
                closedChildNode(&count, node: item)
            }
        } 
    }
    
}

