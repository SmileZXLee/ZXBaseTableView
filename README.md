# ZXBaseTableView
· 基于系统UITableView的封装，简约的代码风格，无需设置代理和数据源。  
· 实现一个普通的tableView仅需声明cell类名，headerView类名，footerView类名，赋值tableView数据数组，在cell类中重写model的set方法即可，无需处理cell等视图高度，数组多section亦会自动处理，cell点击等事件采取block方式导出，并可以直接获取对应indexPath的model等信息，大大缩减代码量，减少重复的冗余代码。  
·包含分页封装，无需处理分页逻辑，自动显示网络错误占位图，无数据占位图，网络错误点击重新加载等附加功能。

```  

    //初始化数据
    [self setData];
    //初始化tableView
    ZXBaseTableView *tableView = [self creatTableView];
    //设置tableView数据 此set方法会刷新tableView
    tableView.zxDatas = self.dataSource;
    //设置对应indexPath的cell类
    tableView.cellClassAtIndexPath = ^Class(NSIndexPath *indexPath) {
        //是否为xib并且如何加载内部会自动处理
        if(indexPath.row == 0){
            return [XibTestCell class];
        }else{
            return [CustomTestCell class];
        }
    };
    
    //获取对应indexPath的cell 可以在这里对cell赋值或者修改cell的一些属性或者绑定cell中button的点击事件 注意：若您的自定义cell中.h文件中model属性名称叫作“model”，则无需手动给cell赋值，ZXBaseTableView会自动查找cell中的model字段并且赋值，您直接在setModel中进行cell的赋值即可。您可以在ZXBaseTableViewConfig.h中更改model的匹配属性名
    /*
    tableView.cellAtIndexPath = ^(NSIndexPath *indexPath, UITableViewCell *cell, id model) {
        if([cell isKindOfClass:[CustomTestCell class]]){
            ((CustomTestCell *)cell).model = model;
        }
    };
     */
    
    //设置cell的高度，因tableview的heightforrow方法在cellforrow之前调用，因此需要model寄存cell高度，若您的cell对应model中含有cellH属性，则无需手动给cell设置高度，ZXBaseTableView会根据当前cell的高度来设置cell高度，无需调用此方法，您也可以在model的cellH中设置自己计算好的高度，则ZXBaseTableView不会去根据获取到的cell高度去给cell赋值高度，而是使用您赋值的cellH，若您实现下方方法，则ZXBaseTableView自动计算高度无效，若您使用了cell自适应高度，则ZXBaseTableView自动计算高度也无效。您可以在ZXBaseTableViewConfig.h中更改cellH的匹配属性名。
    /*
    tableView.cellHAtIndexPath = ^CGFloat(NSIndexPath *indexPath) {
        if(indexPath.row == 0){
            return 100;
        }else{
            return 60;
        }
    };
    */

    //设置HeaderView
    tableView.headerClassInSection = ^Class(NSInteger section) {
        return [TestHeaderView class];
    };

    //设置FooterView
    tableView.viewForFooterInSection = ^UIView *(NSInteger section) {
        UILabel *footerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, KSCREENWIDTH, 40)];
        footerLabel.textAlignment = NSTextAlignmentCenter;
        footerLabel.text = @"footerLabel";
        footerLabel.backgroundColor = [UIColor orangeColor];
        footerLabel.textColor = [UIColor whiteColor];
        return footerLabel;
    };
    tableView.heightForFooterInSection = ^CGFloat(NSInteger section) {
        if(section == 3){
            return 40;
        }else{
            return 0.01;
        }
    };
    //选中某一indexPath
    tableView.didSelectedAtIndexPath = ^(NSIndexPath *indexPath,id model,UITableViewCell *cell) {
        NSLog(@"选中了%lu-%lu,选中model-%@,选中cell-%@",indexPath.section,indexPath.row,model,cell);
    };
    //tableView的滚动事件
    tableView.scrollViewDidScroll = ^(UIScrollView *scrollView) {
        //NSLog(@"滚动到--%lf",scrollView.contentOffset.y);
    };
    self.tableView = tableView;
    
    //同时支持系统原生的代理和数据源方法 设置代理和数据源 遵循相应代理和数据源即可 若您重写了对应的方法 这对应的block方法将失效
    /*
    tableView.zxDataSource = self;
    tableView.zxDelegate = self;
     */

```
 
