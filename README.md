# ZXBaseTableView
## 停止维护，推荐使用精简版的[ZXTableView](https://github.com/SmileZxLee/ZXTableView)
## 创建一个常见的tableView示例

* 首先我们创建一个ZXBaseTableView  

```objective-c
//调用控制器分类中的creatTableView即可创建一个ZXBaseTableView，frame内部自动计算了。
ZXBaseTableView *tableView = [self creatTableView];
```
* 告诉ZXBaseTableView需要显示的cell的类
```objective-c
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

```objective-c
tableView.headerClassInSection = ^Class(NSInteger section) {
     return [TestHeaderView class];
};
```
* 设置tableView中显示的数据的数组，和往常的设置数据源习惯一样，无需任何额外处理，self.dataArr中存放model数组（NSString之类的系统对象也可以），多级数组嵌套即为多section的情况。

```objective-c
tableView.zxDatas = self.dataArr;
```
* 在XibTestCell与CustomTestCell中，设置cell中显示的数据，同样您无需更改习惯的设计模式，也无需继承任何自定义cell  
以XibTestCell为例，您只需在.h或.m中声明： 
```objective-c
@property (strong, nonatomic) XibTestModel *testModel;   
```
(model的类名可以随便取，但是需要包含字符串“model”(大小写不影响)，您也可以在配置文件ZXBaseTableViewConfig.h中更改这个设置)  

然后重写model的set方法即可：  

```objective-c
-(void)setXibTestModel:(XibTestModel *)testModel{
    _testModel = testModel;
    //在这里做数据赋值操作
    
}
```

* 之后，我们可能需要获取tableView中对应cell的点击事件，并进行相应处理  
```objective-c
//选中某一indexPath
tableView.didSelectedAtIndexPath = ^(NSIndexPath *indexPath,id model,UITableViewCell *cell) {
    NSLog(@"选中了%lu-%lu,选中model-%@,选中cell-%@",indexPath.section,indexPath.row,model,cell);
};
```

_至此，一个普通的tableView已创建完毕，运行程序即可正常显示这个tableView，此示例可以适应大多数使用场景_

## ZXBaseTableView使用进阶
我们有些时候可能需要额外的处理，以下是较常见的其他关于tableView的处理：  
* 获取tableView中的cell，并进行额外处理

```objective-c
//获取对应indexPath的cell 可以在这里对cell赋值或者修改cell的一些属性或者绑定cell中button的点击事件
tableView.cellAtIndexPath = ^(NSIndexPath *indexPath, UITableViewCell *cell, id model) {
    if([cell isKindOfClass:[CustomTestCell class]]){
        ((CustomTestCell *)cell).backgroundColor = [UIcolor redColor];
    }
};
```
* 获取ZXBaseTableView的headerView，可以做一些赋值操作

```objective-c
tableView.headerViewInSection = ^(NSUInteger section, UIView *headerView,  NSMutableArray *secArr) {
    if(section == 1){
        headerView.backgroundColor = [UIColor redColor];
    }
};
```
* 手动设置cell高度（一般用不到）
```objective-c
tableView.cellHAtIndexPath = ^CGFloat(NSIndexPath *indexPath) {
    if(indexPath.row == 0){
        return 100;
    }else{
        return 60;
    }
};
```
* 根据文字内容自动设置cell高度
```objective-c
//通常做法是在cell对应的model中定义一个用于存储cell高度的属性，重写cell中变化的文字内容的set方法，并且在set方法中将计算的高度结果赋值给cell高度的属性，ZXBaseTableView会为每个cell的对应model中动态添加一个名为cellH的属性，若用户手动创建了这个同名属性，则使用用户创建的cellH的值作为cell的高度，以下举例说明：
//假设cell对应的model中有一个comment属性，用于存储用户评论cell的评论内容，需要根据评论内容长度自动调整cell高度，则您只需要在model的.m文件中，写下如下代码即可，getRectHeightWithLimitH为自定义的计算文字高度的函数，需替换为自己的高度计算函数：
-(void)setComment:(NSString *)comment{
    _comment = comment;
    self.cellH = [comment getRectHeightWithLimitH:kScreenWidth - 10 * 2 fontSize:13];
}
//您需要model的在.h或.m中声明一下以下属性：
@property (nonatomic,assign) CGFloat cellH;
//大功告成！！
```
* 在cell高度原本基础上修改cell高度，例如统一修改cell高度比例等，当然您也可以自定义model来处理这些，无需每个model都写一遍。
```objective-c
//您需要model的在.h或.m中声明一下以下属性：
@property (nonatomic,assign) CGFloat cellH;
//重写set方法即可，cellH即为原先计算好的cell高度或cell本身真实高度，您可以在这个基础上进行计算，赋值给_cellH即可
-(void)setCellH:(CGFloat)cellH{
    _cellH = cellH - 100;
    //_cellH = cellH * 0.8;
}
```
* 在cell中获取当前indexPath
```objective-c
//您需要model的在.h或.m中声明一下以下属性：
@property (nonatomic,strong) NSIndexPath *index;
//则ZXBaseTableView会自动将当前模型的indexPath赋值给它，您可以在cell中通过对应模型获取对应的indexPath。
```
* 创建headerView或footerView对象并设置为对应的headerView或footerView（不常用，一般直接返回对应对象名即可，ZXBaseTableView会自动创建并设置高度）
```objective-c
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
```objective-c
//声明footerView高度
tableView.heightForFooterInSection = ^CGFloat(NSInteger section) {
    if(section == 3){
        return 40;
    }else{
        return 0.01;
    }
};
```

* tableView滑动删除
```objective-c
tableView.editActionsForRowAtIndexPath = ^NSArray<UITableViewRowAction *> *(NSIndexPath *indexPath) {
    if(indexPath.row == self.dataSource.count)return nil;
    __weak typeof(self) weakSelf = self;
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive   title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //对应删除操作
       
    }];
    return @[deleteAction];
 };
```
* 有时候我们界面可能需要展示一些假数据，下面这个方法可以无需设置数据源数组即生成指定数量的cell

```objective-c
[tableView initDatasWithRowCount:20];
```
* 禁止系统Cell自动高度 可以有效解决tableView跳动问题

```objective-c
tableView.disableAutomaticDimension = YES;
```
* 同时支持系统原生的代理和数据源方法设置代理和数据源，遵循相应代理和数据源即可，若您重写了对应的代理方法，则对应的block方法将失效  

```objective-c
tableView.zxDataSource = self;
tableView.zxDelegate = self;
```
* 支持scrollView滚动事件，缩放事件，滚动到顶部事件，开始拖拽事件，正在拖拽事件等  
```objective-c
tableView.scrollViewDidScroll = ^(UIScrollView *scrollView) {
    //NSLog(@"滚动到--%lf",scrollView.contentOffset.y);
};
//其他见ZXBaseTableView.h声明
```

## ZXBaseTableView分页相关
大量减少重复的判断代码，控制中无需定义pageNo和pageCount，仅需将请求的结果传给ZXBaseTableView即可。  
[MJRefresh](https://github.com/CoderMJLee/MJRefresh) 是当前使用最为广泛的下拉刷新框架，ZXBaseTableView的分页模块基于此进行了一些处理，对暂无更多数据等footerView显示状态内部自动判断。再次表达对MJ老师的崇敬之情。


* 告知ZXBaseTableView控制器中获取分页数据请求的方法即可

```objective-c
[self.tableView addPagingWithReqSel:@selector(reqDataList) target:self];
[self.tableView.mj_header beginRefreshing];
```
* 请求分页数据（网络请求相关）

```objective-c
-(void)reqDataList{
    @ZXWeakSelf(self);
    [self reqLocalDtatWithParam:@{@"pageNo" : [NSNumber numberWithInteger:self.tableView.pageNo],@"pageCount" : [NSNumber numberWithInteger:self.tableView.pageCount]} resultBlock:^(BOOL result,id backData) {
        @ZXStrongSelf(self)
        if(result){
            //请求成功
            for (id data in (NSMutableArray *)backData) {
                [self.tableView.zxDatas addObject:data];
            }
        }
        
        //result = YES即为请求成功，需要告知ZXBaseTableView请求成功还是失败，若请求失败传入errDic，ZXBaseTableView会根据状态码显示对应的失败     页面,同时需要传入当前分页方法，点击ZXBaseTableView中的“重新加载”按钮时，会再次调用这个方法，请求失败pageNo不会增加。
        [self.tableView updateTabViewStatus:result errDic:backData backSel:@selector(reqDataList)];
    }];
    
}
```
_至此，一个分页已经写完了，暂无数据占位图，网络错误占位图，点击重新加载，mjRefersh有数据显示下拉加载更多，无更多数据显示暂无更多数据等逻辑，内部已自动处理完毕了_

## ZXBaseTableView一些属性偏好设置
_若您需要修改ZXBaseTableView的默认配置或默认状态，在方法-initialize中设置即可
```objective-c
//无数据是否显示header 默认为NO
@property(nonatomic, assign)BOOL showHeaderWhenNoMsg;

//是否隐藏重新加载按钮 默认显示
@property(nonatomic, assign)BOOL hideReloadBtn;

//是否隐藏错误提示Toast 默认显示
@property(nonatomic, assign)BOOL hideMsgToast;

//是否固定错误提示占位图 默认为可以上下拖动
@property(nonatomic, assign)BOOL fixWhenNetErr;

```
_其他详见ZXBaseTableView.h_

## ZXBaseTableView默认配置文件
```objective-c
///model默认去匹配的cell高度属性名 若不存在则动态生成cellHRunTime的属性名
static NSString *const CELLH = @"cellH";
///cell会自动赋值包含“model”的属性
static NSString *const DATAMODEL = @"model";
///model的index属性，存储当前model所属的indexPath
static NSString *const INDEX = @"index";
///若ZXBaseTableView无法自动获取cell高度（zxdata有值即可），且用户未自定义高度，则使用默认高度
static CGFloat const CELLDEFAULTH = 44;
///分页数量
static NSUInteger const PAGECOUNT = 10;

///暂无更多View宽度
static CGFloat const NOMOREDATAVIEWW = 150.0;
///暂无更多View高度
static CGFloat const NOMOREDATAVIEWH = 150.0;
///重新加载按钮宽度
static CGFloat const RELOADBTNW = 80.0;
///重新加载按钮高度
static CGFloat const RELOADBTNH = 25.0;
///重新加载按钮文字
static NSString *const RELOADBTNTEXT = @"重新加载";
///重新加载按钮主题色
static int const RELOADBTNMAINCOLOR = 0xe8412e;
///重新加载按钮上下间距
static int const RELOADBTNMARGIN = 10.0;
///重新加载按钮字体大小
static CGFloat const RELOADBTNFONTSIZE = 13.0;

///暂无更多数据图片
static NSString *const NOMOREDATAIMGNAME = @"nomoreDataImg";
///网络错误普遍处理图片
static NSString *const NETERRIMGNAME = @"netErrImg";

///网络错误特定处理图片与提示内容
///无网络连接
static NSString *const NETERRIMGNAME_NO_NET = @"noNetErrImg";
static NSString *const NETERRTOAST_NO_NET = @"无网络连接";
///请求失败
static NSString *const NETERRIMGNAME_REQ_ERROR = @"noNetErrImg";
static NSString *const NETERRTOAST_REQ_ERROR = @"请求失败";
///请求超时
static NSString *const NETERRIMGNAME_TIME_OUT = @"noNetErrImg";
static NSString *const NETERRTOAST_TIME_OUT = @"请求超时";
///请求地址出错
static NSString *const NETERRIMGNAME_ADDRESS_ERR = @"noNetErrImg";
static NSString *const NETERRTOAST_ADDRESS_ERR = @"请求地址出错";
///其他错误
static NSString *const NETERRIMGNAME_OTHER_ERR = @"";
static NSString *const NETERRTOAST_OTHER_ERR = @"未知错误";

///获取错误code的key
static NSString *const NETERR_CODE = @"code";
///获取错误message的key
static NSString *const NETERR_MESSAGE = @"message";
```
### 任何问题欢迎随时issue我，感谢！！
 
