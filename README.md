# ZXBaseTableView
## 创建一个常见的tableView示例

* 首先我们创建一个ZXBaseTableView  

```
//调用控制器分类中的creatTableView即可创建一个ZXBaseTableView，frame内部自动计算了。
ZXBaseTableView *tableView = [self creatTableView];
```

* 设置tableView中显示的数据的数组，和往常的设置数据源习惯一样，无需任何额外处理。

```
tableView.zxDatas = self.dataArr;
```

* 告诉ZXBaseTableView需要显示的cell的类
```
tableView.cellClassAtIndexPath = ^Class(NSIndexPath *indexPath) {
    //如果是第0行，则显示XibTestCell，否则显示CustomTestCell，如果只有一个类型cell，不用判断indexPath
    if(indexPath.row == 0){
        return [XibTestCell class];
    }else{
        return [CustomTestCell class];
    }
};
```
* 告诉ZXBaseTableView需要显示的HeaderView的类（FooterView亦然）

```
tableView.headerClassInSection = ^Class(NSInteger section) {
     return [TestHeaderView class];
};
```

* 在XibTestCell与CustomTestCell中，设置cell中显示的数据，同样您无需更改习惯的设计模式，也无需继承任何自定义cell  
以XibTestCell为例，您只需在.h或.m中声明： 
```
@property (strong, nonatomic) XibTestModel *testModel;   
```
(model的类名可以随便取，但是需要包含字符串“model”，您也可以在配置文件ZXBaseTableViewConfig.h中更改这个设置)  

然后重写model的set方法即可：  

```
-(void)setTestModel:(XibTestModel *)testModel{
    _testModel = testModel;
    //在这里做数据赋值操作
    
}
```

* 之后，我们可能需要获取tableView的对应cell的点击事件，并进行相应处理  
```
//选中某一indexPath
tableView.didSelectedAtIndexPath = ^(NSIndexPath *indexPath,id model,UITableViewCell *cell) {
    NSLog(@"选中了%lu-%lu,选中model-%@,选中cell-%@",indexPath.section,indexPath.row,model,cell);
};
```

_至此，一个普通的tableView已创建完毕，运行程序即可正常显示这个tableView，此示例可以适应大多数使用场景_

## ZXBaseTableView使用进阶
我们有些时候可能需要额外的处理，以下是较常见的其他关于tableView的处理：  
* 获取tableView中的cell，并进行额外处理

```
//获取对应indexPath的cell 可以在这里对cell赋值或者修改cell的一些属性或者绑定cell中button的点击事件
tableView.cellAtIndexPath = ^(NSIndexPath *indexPath, UITableViewCell *cell, id model) {
    if([cell isKindOfClass:[CustomTestCell class]]){
        ((CustomTestCell *)cell).backgroundColor = [UIcolor redColor];
    }
};
```
* 手动设置cell高度(cell动态高度时候常用，若cell高度不变，则无需设置)
```
tableView.cellHAtIndexPath = ^CGFloat(NSIndexPath *indexPath) {
    if(indexPath.row == 0){
        return 100;
    }else{
        return 60;
    }
};
```
* 创建headerView或footerView对象并设置为对应的headerView或footerView（不常用，一般直接返回对应对象名即可，ZXBaseTableView会自动创建并设置高度）
```
//声明tableView的footerView
tableView.viewForFooterInSection = ^UIView *(NSInteger section) {
    UILabel *footerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, KSCREENWIDTH, 40)];
    footerLabel.textAlignment = NSTextAlignmentCenter;
    footerLabel.text = @"footerLabel";
    footerLabel.backgroundColor = [UIColor orangeColor];
    footerLabel.textColor = [UIColor whiteColor];
    return footerLabel;
};
```
```
//声明footerView高度
tableView.heightForFooterInSection = ^CGFloat(NSInteger section) {
    if(section == 3){
        return 40;
    }else{
        return 0.01;
    }
};
```
* tableView滚动事件
```
tableView.scrollViewDidScroll = ^(UIScrollView *scrollView) {
    //NSLog(@"滚动到--%lf",scrollView.contentOffset.y);
};
```
 
