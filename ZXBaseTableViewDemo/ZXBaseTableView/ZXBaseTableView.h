//
//  ZXBaseTableView.h
//  ZXBaseTableView
//
//  Created by 李兆祥 on 2018/8/20.
//  Copyright © 2018年 李兆祥. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseTableViewConfig.h"
typedef NS_OPTIONS(NSUInteger, MJFooterStyle) {
    ///加载结束可以看到MJFooter和对应的提示文字
    MJFooterStyleGroup = 0,
    ///加载结束看不到MJFooter
    MJFooterStylePlain,
};
typedef NS_OPTIONS(NSUInteger, PlaceImgState) {
    ///暂无数据占位图
    PlaceImgStateNoMoreData = 0,
    ///网络错误占位图
    PlaceImgStateNetErr,
};
typedef void(^headerBlock) (void);
typedef void(^footerBlock) (void);
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
///禁止系统Cell自动高度 可以有效解决tableView跳动问题
@property(nonatomic, assign)BOOL disableAutomaticDimension;

#pragma mark - 数据获取
///获取选中某一行
@property (nonatomic, copy) void (^didSelectedAtIndexPath)(NSIndexPath *indexPath,id model,UITableViewCell *cell);
///获取取消选中某一行
@property (nonatomic, copy) void (^didDeselectedAtIndexPath)(NSIndexPath *indexPath,id model,UITableViewCell *cell);
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

#pragma mark - MJRefresh相关
///分页NO
@property(nonatomic,assign)NSUInteger pageNo;
///分页Count
@property(nonatomic,assign)NSUInteger pageCount;
///设置MJFooter样式（非必需），请在addFooter或addPagingWithReqSel之前设置。MJFooterStylePlain加载结束看不到MJFooter，MJFooterStyleGroup加载结束可以看到MJFooter和对应的提示文字，noMoreStr即为对应提示文字，默认为“已经全部加载完毕”，MJFooterStyle默认属性为MJFooterStyleGroup。
-(void)setMJFooterStyle:(MJFooterStyle)style noMoreStr:(NSString *_Nullable)noMoreStr;
///添加MJHeader
-(void)addMJHeader:(headerBlock _Nullable )block;
///添加MJFooter
-(void)addMJFooter:(footerBlock _Nullable )block;
///添加MJFooter 同时设置样式
-(void)addMJFooterStyle:(MJFooterStyle)style noMoreStr:(NSString *_Nullable)noMoreStr block:(footerBlock _Nullable )block;
///添加分页操作 传入请求分页数据的方法和方法所属的控制器
-(void)addPagingWithReqSel:(SEL _Nullable )sel owner:(id _Nullable )owner;
///停止MJHeader和MJFooter刷新状态
-(void)endMjRef;
///分页接口调取完毕更新tableView状态，status为分页接口调取结果，YES为请求成功，NO为失败
-(void)updateTabViewStatus:(BOOL)status;
@end
