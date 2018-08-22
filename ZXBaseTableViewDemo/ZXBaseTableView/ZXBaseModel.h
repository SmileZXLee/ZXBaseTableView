//
//  ZXBaseModel.h
//  ZXBaseTableViewDemo
//
//  Created by 李兆祥 on 2018/8/22.
//  Copyright © 2018年 李兆祥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#warning 可以在自己的model中声明cellH属性 或直接继承此类，无需声明cellH属性，cellH属性会帮助您自动计算cell高度
@interface ZXBaseModel : NSObject
@property(nonatomic, assign)CGFloat cellH;
@end
