//
//  TestModel.h
//  ZXBaseTableViewDemo
//
//  Created by 李兆祥 on 2018/8/20.
//  Copyright © 2018年 李兆祥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface TestModel : ZXBaseModel
@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *msg;
//继承了ZXBaseModel 此行可不写
//@property(nonatomic, assign)CGFloat cellH;
@end
