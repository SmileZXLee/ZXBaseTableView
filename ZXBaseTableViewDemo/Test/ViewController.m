//
//  ViewController.m
//  ZXBaseTableViewDemo
//
//  Created by 李兆祥 on 2018/8/20.
//  Copyright © 2018年 李兆祥. All rights reserved.
//

#import "ViewController.h"

#import "XibTestCell.h"
#import "CustomTestCell.h"
#import "TestModel.h"

#import "MJRefresh.h"
typedef void(^reqResultBlock) (BOOL result,id backData);
@interface ViewController ()
@property(nonatomic, weak)ZXBaseTableView *tableView;
@property(nonatomic, strong)NSMutableArray *dataSource;
@end

@implementation ViewController
#pragma mark 设置数据来源
-(void)segControlChange:(UISegmentedControl *)seg{
    if(seg.selectedSegmentIndex == 0){
        //普通模式
        //设置tableView数据 此set方法会刷新tableView
        self.tableView.mj_header = nil;
        self.tableView.mj_footer = nil;
        self.tableView.zxDatas = [self.dataSource mutableCopy];
    }else{
        //分页模式
        //MJRefresh相关封装
        /*
         [tableView addMJHeader:^{
         [self reqDataList];
         }];
         [tableView addMJFooter:^{
         [self reqDataList];
         }];
         */
        //设置MJFooterStyle样式（非必需）
        //[self.tableView setMJFooterStyle:MJFooterStyleGroup noMoreStr:@"啦啦啦没有更多了"];
        
        //等同于上方写法
        [self.tableView addPagingWithReqSel:@selector(reqDataList)];
        [self.tableView.mj_header beginRefreshing];
//        self.tableView.hideReloadBtn = YES;
//        self.tableView.hideMsgToast = YES;
        self.tableView.fixWhenNetErr = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //初始化数据
    [self setData];
    //初始化tableView
    ZXBaseTableView *tableView = [self creatTableView];
    //设置对应indexPath的cell类
    tableView.cellClassAtIndexPath = ^Class(NSIndexPath *indexPath) {
        //是否为xib并且如何加载内部会自动处理
        if(indexPath.row == 0){
            return [XibTestCell class];
        }else{
            return [CustomTestCell class];
        }
    };
    
    //获取对应indexPath的cell 可以在这里对cell赋值或者修改cell的一些属性或者绑定cell中button的点击事件 注意：若您的自定义cell中.h文件中model属性名称叫作“model”（或包含model，大小写不影响），则无需手动给cell赋值，ZXBaseTableView会自动查找cell中的model（或包含model，大小写不影响）字段并且赋值，您直接在setModel中进行cell的赋值即可。您可以在ZXBaseTableViewConfig.h中更改model的匹配属性名
    /*
    tableView.cellAtIndexPath = ^(NSIndexPath *indexPath, UITableViewCell *cell, id model) {
        if([cell isKindOfClass:[CustomTestCell class]]){
            ((CustomTestCell *)cell).model = model;
        }
    };
     */
    
    //设置cell的高度，因tableview的heightforrow方法在cellforrow之前调用，因此需要model寄存cell高度，若您的cell对应model中含有cellH属性(也可不包含)，则无需手动给cell设置高度，ZXBaseTableView会根据当前cell的高度来设置cell高度，无需调用此方法，您也可以在model的cellH中设置自己计算好的高度，则ZXBaseTableView不会去根据获取到的cell高度去给cell赋值高度，而是使用您赋值的cellH，若您实现下方方法，则ZXBaseTableView自动计算高度无效，若您使用了cell自适应高度，则ZXBaseTableView自动计算高度也无效。您可以在ZXBaseTableViewConfig.h中更改cellH的匹配属性名。
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
    tableView.viewForHeaderInSection = ^UIView *(NSInteger section) {
        UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, KSCREENWIDTH, 40)];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.text = @"headerLabel";
        headerLabel.backgroundColor = [UIColor blackColor];
        headerLabel.textColor = [UIColor whiteColor];
        return headerLabel;
    };
    //设置HeaderView高度
    tableView.heightForHeaderInSection = ^CGFloat(NSInteger section) {
        if(section == 1){
            return 40;
        }else{
            return 0.01;
        }
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
    //设置FooterView高度
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
    
    //设置数据来源
    UISegmentedControl *segControl = [[UISegmentedControl alloc]initWithItems:@[@"普通模式",@"分页模式"]];
    self.navigationItem.titleView = segControl;
    [segControl addTarget:self action:@selector(segControlChange:) forControlEvents:UIControlEventValueChanged];
    segControl.selectedSegmentIndex = 0;
    [self segControlChange:segControl];
    
    //设置清空按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(cleanAll)];
    
}
#pragma mark 请求分页数据
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
        //更新当前TableView状态
        //[self.tableView updateTabViewStatus:result];
        
        [self.tableView updateTabViewStatus:result errDic:backData backSel:@selector(reqDataList)];
    }];
    
}

#pragma mark 模拟从服务器获取数据(分页请求测试)
-(void)reqLocalDtatWithParam:(NSDictionary *)param resultBlock:(reqResultBlock)resultBlock{
    NSUInteger dataCounts = 34;
    NSUInteger pageNo = [param[@"pageNo"] integerValue];
    NSUInteger pageCount = [param[@"pageCount"] integerValue];
    id backDatas = [NSMutableArray array];
    NSMutableArray *localDatasArr = [NSMutableArray array];
    for(NSUInteger i = 0;i < dataCounts;i++){
        TestModel *model = [[TestModel alloc]init];
        model.title = @"Test";
        model.msg = [NSString stringWithFormat:@"测试数据-%lu",i];
        [localDatasArr addObject:model];
    }
    NSUInteger from = (pageNo - 1) * pageCount;
    from = from >= localDatasArr.count ? localDatasArr.count - 1 : from;
    NSUInteger to = from + pageCount;
    to = to >= localDatasArr.count ? localDatasArr.count - 1 : to;
    for(NSUInteger i = from;i < to;i++){
        [backDatas addObject:localDatasArr[i]];
    }
    //加一些随机的假的错误情况
    BOOL success = arc4random_uniform(2);
    NSArray *errCodeArr = @[@-1009,@-1000,@-1001,@-1002];
    if(!success){
        backDatas = [NSDictionary dictionaryWithObjects:@[errCodeArr[(int32_t)arc4random_uniform((int32_t)errCodeArr.count)],@"错误测试"] forKeys:@[@"code",@"message"]];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        resultBlock(success,backDatas);
    });
    
}

#pragma mark 普通模式 初始化数据
-(void)setData{
    for(NSUInteger i = 0; i < 6;i++){
        NSMutableArray *sectionArr = [NSMutableArray array];
        for(NSUInteger j = 0; j < 5;j++){
            TestModel *model = [[TestModel alloc]init];
            model.title = @"Test";
            model.msg = [NSString stringWithFormat:@"第%luSection,第%lu行",i,j];
            [sectionArr addObject:model];
        }
        [self.dataSource addObject:sectionArr];
    }
}
#pragma mark 清空所有数据
-(void)cleanAll{
    [self.tableView.zxDatas removeAllObjects];
    [self.tableView reloadData];
}
#pragma mark 懒加载
-(NSMutableArray *)dataSource{
    if(!_dataSource){
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
