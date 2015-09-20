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
-(instancetype)initWithScrollView:(UIScrollView*)sView withHeaderRefresh:(BOOL)hRefresh andFooterRefresh:(BOOL)fRefresh refreshDeletate:(id<SGMRefreshProtocol>)rDelegate;

-(void)beginHeaderRefresh;
-(void)endHeaderRefresh;

@end
