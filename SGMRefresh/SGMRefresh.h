//
//  SMGRefresh.h
//  SGMRefresh
//
//  Created by 苏贵明 on 15/9/20.
//  Copyright (c) 2015年 苏贵明. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SGMRefreshProtocol <NSObject>
@optional
-(void)SGMHeaderRefresh;
-(void)SGMFooterRefresh;
@end

@interface SGMRefresh : UIView

//动画数组
@property(nonatomic,retain)NSMutableArray* percentImgArray;//手在拉时的动画帧
@property(nonatomic,retain)NSMutableArray* runningImgArray;//手放开时的动画帧


-(instancetype)initWithScrollView:(UIScrollView*)sView withHeaderRefresh:(BOOL)hRefresh andFooterRefresh:(BOOL)fRefresh refreshDeletate:(id<SGMRefreshProtocol>)rDelegate;

-(void)beginHeaderRefresh;

-(void)endHeaderRefresh;
-(void)endFooterRefresh;

@end
