//
//  ZXBaseTableView.m
//  ZXBaseTableView
//
//  Created by 李兆祥 on 2018/8/20.
//  Copyright © 2018年 李兆祥. All rights reserved.
//  Github地址：https://github.com/SmileZXLee/ZXBaseTableView

#import "ZXBaseTableView.h"
#import "NSObject+SafeSetValue.h"
@interface ZXBaseTableView()<UITableViewDelegate,UITableViewDataSource>

@end
@implementation ZXBaseTableView

-(instancetype)init{
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if(self = [super initWithFrame:frame style:style]){
        [self initialize];
    }
    return self;
}
-(void)dealloc{
    self.delegate = nil;
    self.dataSource = nil;
}
#pragma mark - Setter
-(void)setZxDatas:(NSMutableArray *)zxDatas{
    _zxDatas = zxDatas;
    [self reloadData];
}

#pragma mark - UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if([self.zxDataSource respondsToSelector:@selector(cellForRowAtIndexPath:)]){
        return [self.zxDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    }else{
        id model = [self getModelAtIndexPath:indexPath];
        NSString *className  = nil;
        Class cellClass = nil;
        if(self.cellClassAtIndexPath){
            cellClass = self.cellClassAtIndexPath(indexPath);
            className = NSStringFromClass(cellClass);
        }
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.nib",[[NSBundle mainBundle]resourcePath],className]];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:className];
        if(!cell){
            if(isExist){
                cell = [[[NSBundle mainBundle]loadNibNamed:className owner:nil options:nil]lastObject];
                [cell safeSetValue:className forKeyPath:@"reuseIdentifier"];
            }else{
                if(cellClass){
                    cell = [[cellClass alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:className];
                }else{
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:className];
                    cell.textLabel.text = @"Undefined Cell";
                }
            }
        }
        CGFloat cellH = ((UITableViewCell *)cell).frame.size.height;
        if(cellH && ![[model safeValueForKeyPath:CELLH] floatValue]){
            [model safeSetValue:[NSNumber numberWithFloat:cellH] forKeyPath:CELLH];
        }
        NSArray *proNames = [cell getAllPropertyNames];
        for (NSString *proStr in proNames) {
            if([proStr.uppercaseString containsString:DATAMODEL.uppercaseString]){
                [cell safeSetValue:model forKeyPath:proStr];
                break;
            }
        }
        !self.cellAtIndexPath ? : self.cellAtIndexPath(indexPath,cell,model);
        //可以在这里设置整个项目cell的属性，也可以在cellAtIndexPath的block中设置当前控制器tableview的cell属性
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.zxDataSource respondsToSelector:@selector(numberOfRowsInSection:)]){
        return [self.zxDataSource tableView:tableView numberOfRowsInSection:section];
    }else{
        if(self.numberOfRowsInSection){
            return self.numberOfRowsInSection(section);
        }else{
            if([self isMultiDatas]){
                NSArray *sectionArr = [self.zxDatas objectAtIndex:section];
                return sectionArr.count;
            }else{
                return self.zxDatas.count;
            }
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if([self.zxDataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]){
        return [self.zxDataSource numberOfSectionsInTableView:tableView];
    }else{
        if(self.numberOfSectionsInTableView){
            return self.numberOfSectionsInTableView(tableView);
        }else{
            return [self isMultiDatas] ? self.zxDatas.count : 1;
        }
    }
}

#pragma mark - UITableViewDelegate
#pragma mark tableView 选中某一indexPath
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.zxDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]){
        [self.zxDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }else{
        [self deselectRowAtIndexPath:indexPath animated:YES];
        id model = [self getModelAtIndexPath:indexPath];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        !self.didSelectedAtIndexPath ? : self.didSelectedAtIndexPath(indexPath,model,cell);
    }
}
#pragma mark tableView 取消选中某一indexPath
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.zxDelegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]){
        [self.zxDelegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
}
#pragma mark tableView cell高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.zxDelegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)]
        || self.estimatedRowHeight > 0) {
        return UITableViewAutomaticDimension;
    }
    if([self.zxDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]){
        return [self.zxDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }else{
        if(self.cellHAtIndexPath){
            return self.cellHAtIndexPath(indexPath);
        }else{
            id model = [self getModelAtIndexPath:indexPath];
            CGFloat cellH = [[model safeValueForKeyPath:CELLH] floatValue];
            if(cellH){
               return cellH;
            }else{
                return 0;
            }
        }
        
    }
}
#pragma mark tableView HeaderView & FooterView
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if([self.zxDelegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]){
        return [self.zxDelegate tableView:tableView viewForHeaderInSection:section];
        
    }else{
        if(self.viewForHeaderInSection){
            return self.viewForHeaderInSection(section);
        }else{
            return nil;
        }
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if([self.zxDelegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]){
        return [self.zxDelegate tableView:tableView viewForFooterInSection:section];
        
    }else{
        if(self.viewForFooterInSection){
            return self.viewForFooterInSection(section);
        }else{
            return nil;
        }
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if([self.zxDelegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]){
        return [self.zxDelegate tableView:tableView heightForHeaderInSection:section];
        
    }else{
        if(self.heightForHeaderInSection){
            return self.heightForHeaderInSection(section);
        }else{
            return 0.01;
        }
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if([self.zxDelegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]){
        return [self.zxDelegate tableView:tableView heightForFooterInSection:section];
        
    }else{
        if(self.heightForFooterInSection){
            return self.heightForFooterInSection(section);
        }else{
            return 0.01;
        }
    }
}
#pragma mark scrollView相关代理
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if([self.zxDelegate respondsToSelector:@selector(scrollViewDidScroll:)]){
        return [self.zxDelegate scrollViewDidScroll:scrollView];
        
    }else{
        if(self.scrollViewDidScroll){
            self.scrollViewDidScroll(scrollView);
        }
    }
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    if([self.zxDelegate respondsToSelector:@selector(scrollViewDidZoom:)]){
        return [self.zxDelegate scrollViewDidZoom:scrollView];
        
    }else{
        if(self.scrollViewDidZoom){
            self.scrollViewDidZoom(scrollView);
        }
    }
}
-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    if([self.zxDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]){
        return [self.zxDelegate scrollViewDidScrollToTop:scrollView];
        
    }else{
        if(self.scrollViewDidScrollToTop){
            self.scrollViewDidScrollToTop(scrollView);
        }
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if([self.zxDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]){
        return [self.zxDelegate scrollViewWillBeginDragging:scrollView];
        
    }else{
        if(self.scrollViewWillBeginDragging){
            self.scrollViewWillBeginDragging(scrollView);
        }
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if([self.zxDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]){
        return [self.zxDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
        
    }else{
        if(self.scrollViewDidEndDragging){
            self.scrollViewDidEndDragging(scrollView,decelerate);
        }
    }
}
#pragma mark - Private
#pragma mark 初始化
-(void)initialize{
    self.delegate = self;
    self.dataSource = self;
}
#pragma mark 判断是否是多个section的情况
-(BOOL)isMultiDatas{
    return self.zxDatas.count && [[self.zxDatas objectAtIndex:0] isKindOfClass:[NSArray class]];
}
#pragma mark 获取对应indexPath的model
-(instancetype)getModelAtIndexPath:(NSIndexPath *)indexPath{
    id model;
    if([self isMultiDatas]){
        NSArray *sectionArr = self.zxDatas[indexPath.section];
        model = sectionArr[indexPath.row];
    }else{
        model = self.zxDatas[indexPath.row];
    }
    return model;
}

@end
