//
//  ZXBaseTableView.m
//  ZXBaseTableView
//
//  Created by 李兆祥 on 2018/8/20.
//  Copyright © 2018年 李兆祥. All rights reserved.
//  Github地址：https://github.com/SmileZXLee/ZXBaseTableView

#import "ZXBaseTableView.h"
#import "NSObject+SafeSetValue.h"
#import "UIView+GetCurrentVC.h"

#import "MJRefresh.h"
@interface ZXBaseTableView()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)NSMutableArray *zxLastDatas;

@property(nonatomic, copy)NSString *noMoreStr;
@property(nonatomic, weak)UIView *noMoreDataView;

@property(nonatomic, assign)MJFooterStyle footerStyle;
@property(nonatomic, assign)BOOL isMJHeaderRef;

@property(nonatomic, strong)MJRefreshHeader *lastMjHeader;
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
-(void)awakeFromNib{
    [super awakeFromNib];
    [self initialize];
}
-(void)dealloc{
    self.delegate = nil;
    self.dataSource = nil;
}
#pragma mark - Setter
-(void)setZxDatas:(NSMutableArray *)zxDatas{
    _zxDatas = zxDatas;
    [self reloadData];
    /*
    @ZXWeakSelf(self);
    [self.zxDatas obsKey:@"count" handler:^(id newData, id oldData, id owner) {
        @ZXStrongSelf(self);
        if(![newData integerValue]){
            //没有数据
            [self showNoMoreData];
            [self reloadData];
        }else{
            [self removeNoMoreData];
        }
    }];
     */
     
}
-(void)setDisableAutomaticDimension:(BOOL)disableAutomaticDimension{
    _disableAutomaticDimension = disableAutomaticDimension;
    if(disableAutomaticDimension){
        self.estimatedRowHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        self.estimatedSectionFooterHeight = 0;
    }
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
        id model = [self getModelAtIndexPath:indexPath];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        !self.didDeselectedAtIndexPath ? : self.didDeselectedAtIndexPath(indexPath,model,cell);
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
    self.pageCount = 1;
    self.pageCount = PAGECOUNT;
    
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
#pragma mark 暂无数据 & 网络错误相关
-(void)showNoMoreDataWithStates:(PlaceImgState)state errorDic:(NSDictionary *)errorDic backSel:(SEL)backSel{
    int errorCode = 0;
    if([errorDic.allKeys containsObject:NETERR_CODE]){
        errorCode = [errorDic[NETERR_CODE] intValue];
    }
    self.scrollEnabled = !self.fixWhenNetErr;
    [self removeNoMoreData];
    UIView *noMoreDataView = [[UIView alloc]init];
    CGFloat noMoreDataViewW = NOMOREDATAVIEWW;
    CGFloat noMoreDataViewH = NOMOREDATAVIEWH;
    CGFloat noMoreDataViewX = (KSCREENWIDTH - noMoreDataViewW) / 2.0;
    CGFloat noMoreDataViewY = (self.frame.size.height - self.tableHeaderView.frame.size.height - noMoreDataViewH) / 2.0;
    noMoreDataView.frame = CGRectMake(noMoreDataViewX, noMoreDataViewY, noMoreDataViewW, noMoreDataViewH);
    UIImageView *subImgV = [[UIImageView alloc]init];
    subImgV.frame = CGRectMake(0, 0, noMoreDataViewW, noMoreDataViewH);
    if(state == PlaceImgStateNoMoreData){
        //显示暂无数据
        subImgV.image = [UIImage imageNamed:NOMOREDATAIMGNAME];
    }else if(state == PlaceImgStateNetErr){
        //显示网络错误普遍处理
        subImgV.image = [UIImage imageNamed:NETERRIMGNAME];
    }else{
        //显示网络根据特定情况处理
        if(!self.hideReloadBtn){
            subImgV.frame = CGRectMake(0, 0, noMoreDataViewW, noMoreDataViewH - RELOADBTNH - 2 * RELOADBTNMARGIN);
            self.mj_header = nil;
        }else{
            if(self.lastMjHeader){
                self.mj_header = self.lastMjHeader;
            }
        }
        UIButton *reloadBtn = [[UIButton alloc]init];
        reloadBtn.clipsToBounds = YES;
        CGFloat reloadBtnW = RELOADBTNW;
        CGFloat reloadBtnH = self.hideReloadBtn ? 0 : RELOADBTNH;
        CGFloat reloadBtnX = (noMoreDataViewW - RELOADBTNW) / 2.0;
        CGFloat reloadBtnY = CGRectGetMaxY(subImgV.frame) + RELOADBTNMARGIN;
        reloadBtn.frame = CGRectMake(reloadBtnX, reloadBtnY, reloadBtnW, reloadBtnH);
        [reloadBtn setTitle:RELOADBTNTEXT forState:UIControlStateNormal];
        [reloadBtn setTitleColor:UIColorFromRGB(RELOADBTNMAINCOLOR) forState:UIControlStateNormal];
        reloadBtn.titleLabel.font = [UIFont systemFontOfSize:RELOADBTNFONTSIZE];
        reloadBtn.clipsToBounds = YES;
        reloadBtn.layer.borderWidth = 1;
        reloadBtn.layer.borderColor = UIColorFromRGB(RELOADBTNMAINCOLOR).CGColor;
        reloadBtn.layer.cornerRadius = 2;
        [reloadBtn addTarget:[self getCurrentVC] action:backSel forControlEvents:UIControlEventTouchUpInside];
        //分开写 比较清晰
        switch (errorCode)
        {   //无网络连接
            case -1009:
            {
                //无网络连接
                subImgV.image = [UIImage imageNamed:NETERRIMGNAME_NO_NET];
                if(!self.hideMsgToast){
                    ZXToast(NETERRTOAST_NO_NET);
                }
                break;
            }
            case -1000:
            {   
                //请求失败
                subImgV.image = [UIImage imageNamed:NETERRIMGNAME_REQ_ERROR];
                if(!self.hideMsgToast){
                    ZXToast(NETERRTOAST_REQ_ERROR);
                }
                break;
            }
            case -1001:
            {
                //请求超时
                subImgV.image = [UIImage imageNamed:NETERRIMGNAME_TIME_OUT];
                if(!self.hideMsgToast){
                    ZXToast(NETERRTOAST_TIME_OUT);
                }
                break;
            }
            case -1002:
            {
                //请求地址出错
                subImgV.image = [UIImage imageNamed:NETERRIMGNAME_ADDRESS_ERR];
                if(!self.hideMsgToast){
                    ZXToast(NETERRTOAST_ADDRESS_ERR);
                }
                break;
            }
                
            default:
            {
                //其他错误
                subImgV.image = [UIImage imageNamed:NETERRIMGNAME_OTHER_ERR];
                if(!self.hideMsgToast){
                    if([errorDic.allKeys containsObject:@"message"]){
                        ZXToast([errorDic valueForKey:@"message"]);
                    }else{
                        ZXToast(NETERRTOAST_OTHER_ERR);
                    }
                }
                break;
            }
        }
        if(state == PlaceImgStateNetErrpecific){
            [noMoreDataView addSubview:reloadBtn];
        }
    }
    if(state != PlaceImgStateOnlyToast){
        subImgV.contentMode = UIViewContentModeScaleAspectFit;
        [noMoreDataView addSubview:subImgV];
    }
    [self addSubview:noMoreDataView];
    self.noMoreDataView = noMoreDataView;
}
-(void)removeNoMoreData{
    if(self.noMoreDataView){
        [self.noMoreDataView removeFromSuperview];
        self.noMoreDataView = nil;
    }
}
#pragma mark 重写reloadData
-(void)reloadData{
    [super reloadData];
    if(!self.zxDatas.count){
        //没有数据
        NSDictionary *errDic = [NSDictionary dictionaryWithObjects:@[@0,@""] forKeys:@[NETERR_CODE,NETERR_MESSAGE]];
        [self showNoMoreDataWithStates:PlaceImgStateNoMoreData errorDic:errDic backSel:nil];
        self.mj_footer.hidden = YES;
    }else{
        [self removeNoMoreData];
        self.mj_footer.hidden = NO;
    }
}

#pragma mark - MJRefresh相关 若未使用MJRefresh 下方代码可以注释掉
-(void)setMJFooterStyle:(MJFooterStyle)style noMoreStr:(NSString *)noMoreStr{
    self.footerStyle = style;
    self.noMoreStr = noMoreStr;
}
-(void)addMJHeader:(headerBlock)block{
    @ZXWeakSelf(self);
    self.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @ZXStrongSelf(self);
        self.isMJHeaderRef = YES;
        if(self.zxDatas.count % self.pageCount){
            self.mj_footer.state = MJRefreshStateNoMoreData;
        }
        [self.zxDatas removeAllObjects];
        self.pageNo = 1;
        block();
    }];
    self.lastMjHeader = self.mj_header;
}
-(void)addMJFooter:(footerBlock)block{
    [self addMJFooterStyle:self.footerStyle noMoreStr:self.noMoreStr block:block];
}
-(void)addMJFooterStyle:(MJFooterStyle)style noMoreStr:(NSString *)noMoreStr block:(footerBlock)block{
    if(style == MJFooterStylePlain){
        self.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            self.isMJHeaderRef = NO;
            self.pageNo++;
            block();
        }];
        MJRefreshBackNormalFooter *foot = (MJRefreshBackNormalFooter *)self.mj_footer;
        [foot setTitle:noMoreStr forState:MJRefreshStateNoMoreData];
    }else{
        self.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            self.isMJHeaderRef = NO;
            self.pageNo++;
            block();
        }];
        if(self.noMoreStr.length){
            MJRefreshAutoNormalFooter *foot = (MJRefreshAutoNormalFooter *)self.mj_footer;
            [foot setTitle:noMoreStr forState:MJRefreshStateNoMoreData];
        }
    }
}
-(void)addPagingWithReqSel:(SEL _Nullable )sel{
    @ZXWeakSelf(self);
    [self addMJHeader:^{
        @ZXStrongSelf(self);
        id target = [self getCurrentVC];
        if([target respondsToSelector:sel]){
            ((void (*)(id, SEL))[target methodForSelector:sel])(target, sel);
        }
    }];
    [self addMJFooter:^{
        @ZXStrongSelf(self);
        id target = [self getCurrentVC];
        if([target respondsToSelector:sel]){
            ((void (*)(id, SEL))[target methodForSelector:sel])(target, sel);
        }
    }];
}
-(void)updateTabViewStatus:(BOOL)status{
    [self updateTabViewStatus:status errDic:nil backSel:nil];
}
-(void)updateTabViewStatus:(BOOL)status errDic:(NSDictionary *)errDic backSel:(SEL)backSel{
    [self endMjRef];
    self.scrollEnabled = YES;
    if(status){
        if(self.lastMjHeader){
            self.mj_header = self.lastMjHeader;
        }
        if(!self.zxDatas.count){
            self.mj_footer.hidden = YES;
        }else{
            self.mj_footer.hidden = NO;
            if(self.zxDatas.count % self.pageCount || self.zxLastDatas.count == self.zxDatas.count){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.mj_footer.state = MJRefreshStateNoMoreData;
                });
                
            }
        }
        if(!self.isMJHeaderRef){
            self.zxLastDatas = [self.zxDatas mutableCopy];
        }
    }else{
        if(!self.zxDatas.count){
            self.mj_footer.hidden = YES;
            if(!errDic){
                [self showNoMoreDataWithStates:PlaceImgStateNetErr errorDic:errDic backSel:backSel];
            }else{
                [self showNoMoreDataWithStates:PlaceImgStateNetErrpecific errorDic:errDic backSel:backSel];
            }
        }else{
            [self showNoMoreDataWithStates:PlaceImgStateOnlyToast errorDic:errDic backSel:backSel];
        }
        if(self.pageNo > 1){
            self.pageNo--;
            [self.zxLastDatas removeAllObjects];
        }
    }
}
-(void)endMjRef{
    [self reloadData];
    [self.mj_header endRefreshing];
    [self.mj_footer endRefreshing];
}

@end
