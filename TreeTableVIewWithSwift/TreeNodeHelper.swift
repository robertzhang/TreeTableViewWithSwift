//
//  TreeNodeHelper.swift
//  TreeTableVIewWithSwift
//
//  Created by Robert Zhang on 15/10/24.
//  Copyright © 2015年 robertzhang. All rights reserved.
//

import Foundation


class TreeNodeHelper {
    
    // 单例模式
    class var sharedInstance: TreeNodeHelper {
        struct Static {
            static var instance: TreeNodeHelper? = TreeNodeHelper()

        }
        return Static.instance!
    }
    
    
    //传入普通节点，转换成排序后的Node
    func getSortedNodes(_ groups: NSMutableArray, defaultExpandLevel: Int) -> [TreeNode] {
        var result: [TreeNode] = []
        let nodes = convetData2Node(groups)
        let rootNodes = getRootNodes(nodes)
        for item in rootNodes{
            addNode(&result, node: item, defaultExpandLeval: defaultExpandLevel, currentLevel: 1)
        }
        
        return result
    }
    
    //过滤出所有可见节点
    func filterVisibleNode(_ nodes: [TreeNode]) -> [TreeNode] {
        var result: [TreeNode] = []
        for item in nodes {
            if item.isRoot() || item.isParentExpand() {
                setNodeIcon(item)
                result.append(item)
            }
        }
        return result
    }
    
    //将数据转换成书节点
    func convetData2Node(_ groups: NSMutableArray) -> [TreeNode] {
        var nodes: [TreeNode] = []
        
        var node: TreeNode
        var desc: String?
        var id: String?
        var pId: String?
        var label: String?
        
        for element in groups {
            let item = element as? [String:Any]
            desc = item?["description"] as? String
            id = item?["id"] as? String
            pId = item?["pid"] as? String
            label = item?["name"] as? String
            
            
            node = TreeNode(desc: desc, id: id, pId: pId, name: label)
            nodes.append(node)
        }
        
        /**
        * 设置Node间，父子关系;让每两个节点都比较一次，即可设置其中的关系
        */
        var n: TreeNode
        var m: TreeNode
        for i in 0 ..< nodes.count {
            n = nodes[i]
            
            for j in i+1 ..< nodes.count {
                m = nodes[j]
                if m.pId == n.id {
                    n.children.append(m)
                    m.parent = n
                } else if n.pId == m.id {
                    m.children.append(n)
                    n.parent = m
                }
            }
        }
        for item in nodes {
            setNodeIcon(item)
        }
        
        return nodes
    }
    
    // 获取根节点集
    func getRootNodes(_ nodes: [TreeNode]) -> [TreeNode] {
        var root: [TreeNode] = []
        for item in nodes {
            if item.isRoot() {
                root.append(item)
            }
        }
        return root
    }
    
    //把一个节点的所有子节点都挂上去
    func addNode(_ nodes: inout [TreeNode], node: TreeNode, defaultExpandLeval: Int, currentLevel: Int) {
        nodes.append(node)
        if defaultExpandLeval >= currentLevel {
            node.setExpand(true)
        }
        if node.isLeaf() {
            return
        }
        for i in 0 ..< node.children.count {
            addNode(&nodes, node: node.children[i], defaultExpandLeval: defaultExpandLeval, currentLevel: currentLevel+1)
        }
    }
    
    // 设置节点图标
    func setNodeIcon(_ node: TreeNode) {
        if node.children.count > 0 {
            node.type = TreeNode.NODE_TYPE_G
            if node.isExpand {
                // 设置icon为向下的箭头
                node.icon = "tree_ex.png"
            } else if !node.isExpand {
                // 设置icon为向右的箭头
                node.icon = "tree_ec.png"
            }
        } else {
            node.type = TreeNode.NODE_TYPE_N
        }
    }
    
    
}
