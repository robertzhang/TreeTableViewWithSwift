# TreeTableViewWithSwift
TreeTableViewWithSwift是用Swift编写的树形结构显示的TableView控件。


## TreeTableViewWithSwift的由来
在开发企业通讯录的时候需要层级展示。之前开发Android的时候有做过类似的功能，也是通过一些开源的内容进行改造利用。此次，在做ios的同类产品时，调研发现树形结构的控件并不是很多，虽然也有但大多看起来都比较负责，而且都是用OC编写的。介于我的项目是Swift开发的，并且TreeTableView貌似没有人用Swift编写过（也可能是我没找到）。所以打算自己动手写一个，从而丰衣足食。


## TreeTableViewWithSwift简介
>~~开发环境：Swift 2.0，Xcode版本：7.0.1 ，ios 9.0~~
升级到 Swift 3.0， Xcode 版本 8.2.1  

也可以通过简书查看：[简书](http://www.jianshu.com/p/75bcd49f144e)
### 1、运行效果

![image](https://github.com/robertzhang/TreeTableViewWithSwift/raw/master/screenshots/treetableview-01.png)

### 2、关键代码的解读
TreeTableViewWithSwift其实是对tableview的扩展。在此之前需要先创建一个TreeNode类用于存储我们的数据

``` Swift
public class TreeNode {
    
    static let NODE_TYPE_G: Int = 0 //表示该节点不是叶子节点
    static let NODE_TYPE_N: Int = 1 //表示节点为叶子节点
    var type: Int?
    var desc: String? // 对于多种类型的内容，需要确定其内容
    var id: String?
    var pId: String?
    var name: String?
    var level: Int?
    var isExpand: Bool = false
    var icon: String?
    var children: [TreeNode] = []
    var parent: TreeNode?
    
    init (desc: String?, id:String? , pId: String? , name: String?) {
        self.desc = desc
        self.id = id
        self.pId = pId
        self.name = name
    }
    
    //是否为根节点
    func isRoot() -> Bool{
        return parent == nil
    }
    
    //判断父节点是否打开
    func isParentExpand() -> Bool {
        if parent == nil {
            return false
        }
        return (parent?.isExpand)!
    }
    
    //是否是叶子节点
    func isLeaf() -> Bool {
        return children.count == 0
    }
    
    //获取level,用于设置节点内容偏左的距离
    func getLevel() -> Int {
        return parent == nil ? 0 : (parent?.getLevel())!+1
    }
    
    //设置展开
    func setExpand(isExpand: Bool) {
        self.isExpand = isExpand
        if !isExpand {
            for (var i=0;i<children.count;i++) {
                children[i].setExpand(isExpand)
            }
        }
    }
    
}
```

这里需要讲解一下，id和pId分别对于当前Node的ID标示和其父节点ID标示。节点直接建立关系它们是很关键的属性。children是一个TreeNode的数组，用来存放当前节点的直接子节点。通过children和parent两个属性，就可以很快的找到当前节点的关系节点。
为了能够操作我们的TreeNode数据，我还创建了一个TreeNodeHelper类。

 ``` Swift
 class TreeNodeHelper {
    
    // 单例模式
    class var sharedInstance: TreeNodeHelper {
        struct Static {
            static var instance: TreeNodeHelper?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) { // 该函数意味着代码仅会被运行一次，而且此运行是线程同步
            Static.instance = TreeNodeHelper()
        }
        return Static.instance!
    }

 ```    
TreeNodeHelper是一个单例模式的工具类。通过TreeNodeHelper.sharedInstance就能获取类实例

 ``` Swift
    //传入普通节点，转换成排序后的Node
    func getSortedNodes(groups: NSMutableArray, defaultExpandLevel: Int) -> [TreeNode] {
        var result: [TreeNode] = []
        var nodes = convetData2Node(groups)
        var rootNodes = getRootNodes(nodes)
        for item in rootNodes{
            addNode(&result, node: item, defaultExpandLeval: defaultExpandLevel, currentLevel: 1)
        }
        
        return result
    }
    
    
 ```
getSortedNodes是TreeNode的入口方法。调用该方法的时候需要传入一个Array类型的数据集。这个数据集可以是任何你想用来构建树形结构的内容。在这里我虽然只传入了一个groups参数，但其实可以根据需要重构这个方法，传入多个类似groups的参数。例如，当我们需要做企业通讯录的时候，企业通讯录的数据中存在部门集合和用户集合。部门之间有层级关系，用户又属于某个部门。我们可以将部门和用户都转换成TreeNode元数据。这样修改方法可以修改为：

 ```
 func getSortedNodes(groups: NSMutableArray, users: NSMutableArray, defaultExpandLevel: Int) -> [TreeNode]
 ```
是不是感觉很有意思呢？

 ``` Swift
    //过滤出所有可见节点
    func filterVisibleNode(nodes: [TreeNode]) -> [TreeNode] {
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
    func convetData2Node(groups: NSMutableArray) -> [TreeNode] {
        var nodes: [TreeNode] = []
        
        var node: TreeNode
        var desc: String?
        var id: String?
        var pId: String?
        var label: String?
        var type: Int?
        
        for item in groups {
            desc = item["description"] as? String
            id = item["id"] as? String
            pId = item["pid"] as? String
            label = item["name"] as? String
            
            node = TreeNode(desc: desc, id: id, pId: pId, name: label)
            nodes.append(node)
        }
        
        /**
        * 设置Node间，父子关系;让每两个节点都比较一次，即可设置其中的关系
        */
        var n: TreeNode
        var m: TreeNode
        for (var i=0; i<nodes.count; i++) {
            n = nodes[i]
            
            for (var j=i+1; j<nodes.count;j++) {
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
 ```
 
 convetData2Node方法将数据转换成TreeNode，同时也构建了TreeNode之间的关系。
 
 ``` Swift
    // 获取根节点集
    func getRootNodes(nodes: [TreeNode]) -> [TreeNode] {
        var root: [TreeNode] = []
        for item in nodes {
            if item.isRoot() {
                root.append(item)
            }
        }
        return root
    }
    
    //把一个节点的所有子节点都挂上去
    func addNode(inout nodes: [TreeNode], node: TreeNode, defaultExpandLeval: Int, currentLevel: Int) {
        nodes.append(node)
        if defaultExpandLeval >= currentLevel {
            node.setExpand(true)
        }
        if node.isLeaf() {
            return
        }
        for (var i=0; i<node.children.count;i++) {
            addNode(&nodes, node: node.children[i], defaultExpandLeval: defaultExpandLeval, currentLevel: currentLevel+1)
        }
    }
    
    // 设置节点图标
    func setNodeIcon(node: TreeNode) {
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
 ```
剩下的代码难度不大，很容易理解。需要多说一句的TreeNode.NODE\_TYPE\_G和TreeNode.NODE\_TYPE\_N是用来告诉TreeNode当前的节点的类型。正如上面提到的企业通讯录，这个两个type就可以用来区分node数据。

TreeTableView我的重头戏来了。它继承了UITableView， UITableViewDataSource，UITableViewDelegate。

 ``` Swift
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 通过nib自定义tableviewcell
        let nib = UINib(nibName: "TreeNodeTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: NODE_CELL_ID)
        
        var cell = tableView.dequeueReusableCellWithIdentifier(NODE_CELL_ID) as! TreeNodeTableViewCell
        
        var node: TreeNode = mNodes![indexPath.row]
        
        //cell缩进
        cell.background.bounds.origin.x = -20.0 * CGFloat(node.getLevel())
        
        //代码修改nodeIMG---UIImageView的显示模式.
        if node.type == TreeNode.NODE_TYPE_G {
            cell.nodeIMG.contentMode = UIViewContentMode.Center
            cell.nodeIMG.image = UIImage(named: node.icon!)
        } else {
            cell.nodeIMG.image = nil
        }
        
        cell.nodeName.text = node.name
        cell.nodeDesc.text = node.desc
        return cell
    }
 ```
tableView:cellForRowAtIndexPath方法中,我们使用了UINib，因为我通过自定义TableViewCell,来填充tableview。这里也使用了cell的复用机制。

下面我们来看控制树形结构展开的关键代码

 ```
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var parentNode = mNodes![indexPath.row]
        
        var startPosition = indexPath.row+1
        var endPosition = startPosition
        
        if parentNode.isLeaf() {// 点击的节点为叶子节点
            // do something
        } else {
            expandOrCollapse(&endPosition, node: parentNode)
            mNodes = TreeNodeHelper.sharedInstance.filterVisibleNode(mAllNodes!) //更新可见节点
            
            //修正indexpath
            var indexPathArray :[NSIndexPath] = []
            var tempIndexPath: NSIndexPath?
            for (var i = startPosition; i < endPosition ; i++) {
                tempIndexPath = NSIndexPath(forRow: i, inSection: 0)
                indexPathArray.append(tempIndexPath!)
            }
            
            // 插入和删除节点的动画
            if parentNode.isExpand {
                self.insertRowsAtIndexPaths(indexPathArray, withRowAnimation: UITableViewRowAnimation.None)
            } else {
                self.deleteRowsAtIndexPaths(indexPathArray, withRowAnimation: UITableViewRowAnimation.None)
            }
            //更新被选组节点
            self.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            
        }
        
    }
    
    //展开或者关闭某个节点
    func expandOrCollapse(inout count: Int, node: TreeNode) {
        if node.isExpand { //如果当前节点是开着的，需要关闭节点下的所有子节点
            closedChildNode(&count,node: node)
        } else { //如果节点是关着的，打开当前节点即可
            count += node.children.count
            node.setExpand(true)
        }
        
    }
    
    //关闭某个节点和该节点的所有子节点
    func closedChildNode(inout count:Int, node: TreeNode) {
        if node.isLeaf() {
            return
        }
        if node.isExpand {
            node.isExpand = false
            for item in node.children { //关闭子节点
                count++ // 计算子节点数加一
                closedChildNode(&count, node: item)
            }
        } 
    }

 ```
我们点击某一个非叶子节点的时候，将该节点的子节点添加到我们的tableView中，并给它们加上动画。这就是我们需要的树形展开视图。首先我们要计算出该节点的子节点数（在关闭节点的时候，还需要计算对应的子节点的子节点的展开节点数），然后获取这些子节点的集合，通过tableview的insertRowsAtIndexPaths和deleteRowsAtIndexPaths方法进行插入节点和删除节点。

tableview:didSelectRowAtIndexPath还算好理解，关键是expandOrCollapse和closedChildNode方法。

expandOrCollapse的作用是打开或者关闭点击节点。当操作为打开一个节点的时候，只需要设置该节点为展开，并且计算其子节点数就可以。而关闭一个节点就相对麻烦。因为我们要计算子节点是否是打开的，如果子节点是打开的，那么子节点的子节点的数也要计算进去。可能这里听起来有点绕口，建议运行程序后看着实例进行理解。

### 3、鸣谢
借鉴的资料有：

* [swift 可展开可收缩的表视图](http://www.jianshu.com/p/706dcc4ccb2f)

* [Android 打造任意层级树形控件 考验你的数据结构和设计](http://blog.csdn.net/lmj623565791/article/details/40212367)

有兴趣的朋友也可以参考以上两篇blog。

## License
All source code is licensed under the MIT License.




