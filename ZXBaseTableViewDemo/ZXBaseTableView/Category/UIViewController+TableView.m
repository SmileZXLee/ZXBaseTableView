//
//  UIViewController+TableView.m
//  ZXBaseTableView
//
//  Created by 李兆祥 on 2018/8/20.
//  Copyright © 2018年 李兆祥. All rights reserved.
//

#import "UIViewController+TableView.h"
@implementation UIViewController (TableView)
-(ZXBaseTableView *)creatTableViewWithStyle:(UITableViewStyle)style{
    CGFloat tabViewH = IS_IPHONE_X ? kSCREENHEIGHT - kNavi_Height + 44 : kSCREENHEIGHT - kNavi_Height;
    CGRect frame = CGRectMake(0, 0, KSCREENWIDTH, tabViewH);
    ZXBaseTableView *tableView = [[ZXBaseTableView alloc]initWithFrame:frame style:style];
    tableView.frame = self.view.frame;
    [self.view addSubview:tableView];
    return tableView;
}
-(ZXBaseTableView *)creatTableView{
    return [self creatTableViewWithStyle:UITableViewStylePlain];
}
@end
