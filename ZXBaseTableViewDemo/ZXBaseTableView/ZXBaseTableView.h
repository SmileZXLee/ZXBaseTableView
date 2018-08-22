//
//  ZXBaseTableView.h
//  ZXBaseTableView
//
//  Created by 李兆祥 on 2018/8/20.
//  Copyright © 2018年 李兆祥. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseTableViewConfig.h"
@interface ZXBaseTableView : UITableView
#pragma mark - 数据设置
///设置所有数据数组
@property(nonatomic, strong)NSMutableArray *zxDatas;
///设置对应cell的类
@property (nonatomic, copy) Class (^cellClassAtIndexPath)(NSIndexPath *indexPath);
///设置对应cell的高度(非必须，若设置了，则内部的自动计算高度无效)
@property (nonatomic, copy) CGFloat (^cellHAtIndexPath)(NSIndexPath *indexPath);
///设置section数量(非必须，若设置了，则内部自动设置section个数无效)
@property (nonatomic, copy) CGFloat (^numberOfSectionsInTableView)(UITableView *tableView);
///设置对应section中row的数量(非必须，若设置了，则内部自动设置对应section中row的数量无效)
@property (nonatomic, copy) CGFloat (^numberOfRowsInSection)(NSUInteger section);
///设置HeaderView(非必须)
@property (nonatomic, copy) UIView *(^viewForHeaderInSection)(NSInteger section);
///设置FooterView(非必须)
@property (nonatomic, copy) UIView *(^viewForFooterInSection)(NSInteger section);
///设置HeaderView高度(非必须)
@property (nonatomic, copy) CGFloat (^heightForHeaderInSection)(NSInteger section);
///设置FooterView高度(非必须)
@property (nonatomic, copy) CGFloat (^heightForFooterInSection)(NSInteger section);


#pragma mark - 数据获取
///获取选中某一行
@property (nonatomic, copy) void (^didSelectedAtIndexPath)(NSIndexPath *indexPath,id model,UITableViewCell *cell);
///获取对应行的cell和model
@property (nonatomic, copy) void (^cellAtIndexPath)(NSIndexPath *indexPath,UITableViewCell *cell,id model);


#pragma mark - 代理事件相关
///scrollView滚动事件
@property (nonatomic, copy) void (^scrollViewDidScroll)(UIScrollView *scrollView);
///scrollView缩放事件
@property (nonatomic, copy) void (^scrollViewDidZoom)(UIScrollView *scrollView);
///scrollView滚动到顶部事件
@property (nonatomic, copy) void (^scrollViewDidScrollToTop)(UIScrollView *scrollView);
///scrollView开始拖拽事件
@property (nonatomic, copy) void (^scrollViewWillBeginDragging)(UIScrollView *scrollView);
///scrollView开始拖拽事件
@property (nonatomic, copy) void (^scrollViewDidEndDragging)(UIScrollView *scrollView, BOOL willDecelerate);


#pragma mark - UITableViewDataSource & UITableViewDelegate
///tableView的DataSource 设置为当前控制器即可重写对应数据源方法
@property (nonatomic, weak, nullable) id <UITableViewDataSource> zxDataSource;
///tableView的Delegate 设置为当前控制器即可重写对应代理方法
@property (nonatomic, weak, nullable) id <UITableViewDelegate> zxDelegate;

@end
