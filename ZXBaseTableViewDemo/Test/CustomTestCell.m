//
//  customTestCell.m
//  ZXBaseTableViewDemo
//
//  Created by 李兆祥 on 2018/8/20.
//  Copyright © 2018年 李兆祥. All rights reserved.
//

#import "CustomTestCell.h"
#import "TestModel.h"
@interface CustomTestCell()
@property(nonatomic, weak)UILabel *msgLabel;
@end
@implementation CustomTestCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 70);
        self.backgroundColor = [UIColor yellowColor];
        UILabel *msgLabel = [[UILabel alloc]init];
        msgLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        msgLabel.textAlignment = NSTextAlignmentCenter;
        msgLabel.font = [UIFont systemFontOfSize:22];
        msgLabel.text = @"自定义cell测试";
        [self.contentView addSubview:msgLabel];
        self.msgLabel = msgLabel;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
   
    
}

-(void)setModel:(TestModel *)model{
    _model = model;
    self.msgLabel.text = model.msg;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
