//
//  SMGRefresh.m
//  SGMRefresh
//
//  Created by 苏贵明 on 15/9/20.
//  Copyright (c) 2015年 苏贵明. All rights reserved.
//

#import "SGMRefresh.h"

//16进制颜色
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

typedef enum {
    NotRefreshing = 0,
    IsRefreshing = 1,
} SGMRefreshStatus;

@implementation SGMRefresh{
    
    float scrollViewWidth;

    UIScrollView* scrollView;
    BOOL headerRefresh;
    BOOL footerRefresh;
    id<SGMRefreshProtocol> refreshDelegate;
    
    UIView* headerContainerView;
    UIView* footerContainerView;
    
    float headerHeight;
    float footerHeight;
    
    UILabel* headerLabel;
    UIImageView* headerImg;
    UIActivityIndicatorView* headerIndicator;
    
    UILabel* footerLabel;
    UIImageView* footerImg;
    UIActivityIndicatorView* footerIndicator;
    
    float headerFlag;//下拉到哪才可以刷新的伐值
    float footerFlag;//上拉到哪才可以刷新的伐值
    
    BOOL headerPassFlag;//下拉超过伐值
    BOOL footerPassFlag;//上拉超过伐值
    
    SGMRefreshStatus headerStatus;
    SGMRefreshStatus footerStatus;
    

}

-(instancetype)initWithScrollView:(UIScrollView*)sView withHeaderRefresh:(BOOL)hRefresh andFooterRefresh:(BOOL)fRefresh refreshDeletate:(id<SGMRefreshProtocol>)rDelegate{
    self = [super init];
    if (self) {
        scrollView = sView;
        headerRefresh = hRefresh;
        footerRefresh = fRefresh;
        refreshDelegate = rDelegate;
    
        scrollViewWidth = scrollView.frame.size.width;
        headerHeight = 500;
        footerHeight = 500;
        
        headerFlag = -60;
        footerFlag = 60;
        
        //监听scrollView的滚动
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [scrollView addSubview:self];
        
        if (headerRefresh) {
            [self initHeaderView];
        }if (footerRefresh) {
            [self initFooterView];
        }
    }
    return self;
}


-(void)initHeaderView{
    
    headerContainerView = [[UIView alloc]initWithFrame:CGRectMake(0, -headerHeight, scrollViewWidth, headerHeight)];
    headerContainerView.backgroundColor = UIColorFromRGB(0xf2f2f2);
    [scrollView addSubview:headerContainerView];
    
    headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(scrollViewWidth/2-10, headerHeight-40, 100, 20)];
    headerLabel.text = @"下拉刷新";
    headerLabel.textColor = [UIColor grayColor];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont systemFontOfSize:14];
    [headerContainerView addSubview:headerLabel];
    
    headerImg = [[UIImageView alloc]initWithFrame:CGRectMake(scrollViewWidth/2-30, headerHeight-45, 12, 30)];
    [headerImg setImage:[UIImage imageNamed:@"headerArrow.png"]];
    [headerContainerView addSubview:headerImg];
    
    headerIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    headerIndicator.frame =CGRectMake(scrollViewWidth/2-40, headerHeight-45, 30, 30);
    [headerContainerView addSubview:headerIndicator];


}
-(void)initFooterView{


}
//监听scrollView实时滚动
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{

    if (![keyPath isEqualToString:@"contentOffset"]) return;
    if (headerStatus == IsRefreshing) return; //正在刷新
    
    CGFloat offSetY = scrollView.contentOffset.y;
    if (scrollView.isDragging) {//手一直接触着在拉
        if (offSetY <=0) {//处理下拉
            if (offSetY < headerFlag && !headerPassFlag) {
                headerPassFlag = YES;
                headerLabel.text = @"释放更新";
                [UIView animateWithDuration:0.25 animations:^{
                    headerImg.transform = CGAffineTransformMakeRotation(3.1416);
                }];
                
            }else if(offSetY > headerFlag && headerPassFlag){
                headerPassFlag = NO;
                headerLabel.text = @"下拉刷新";
                [UIView animateWithDuration:0.25 animations:^{
                    headerImg.transform = CGAffineTransformIdentity;
                }];
            }
            
        }else{//处理上拉

        
        }
        
    }else {//手放开了
        if (offSetY <= 0) {//下拉手放开的时候
            if (headerPassFlag && headerStatus == NotRefreshing) {
                [self beginHeaderRefresh_InnerUse];
            }
        }else{//上拉手放开的时候
        
        }
    }
}
-(void)beginHeaderRefresh_InnerUse{
    headerStatus = IsRefreshing;
    headerLabel.text = @"加载中...";
    headerImg.hidden = YES;
    [headerIndicator startAnimating];
    if ([refreshDelegate respondsToSelector:@selector(SGMHeaderRefresh)]) {
        [refreshDelegate SGMHeaderRefresh];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [scrollView setContentInset:UIEdgeInsetsMake(-headerFlag, 0, 0, 0)];
   }];
}

-(void)beginHeaderRefresh{
    headerStatus = IsRefreshing;
    headerLabel.text = @"加载中...";
    headerImg.hidden = YES;
    [headerIndicator startAnimating];
    if ([refreshDelegate respondsToSelector:@selector(SGMHeaderRefresh)]) {
        [refreshDelegate SGMHeaderRefresh];
    }
    
    [scrollView setContentOffset:CGPointMake(0, headerFlag) animated:YES];
    [scrollView setContentInset:UIEdgeInsetsMake(-headerFlag, 0, 0, 0)];
}

-(void)endHeaderRefresh{
    headerStatus = NotRefreshing;
    headerPassFlag = NO;
    
    headerImg.hidden = NO;
    [headerIndicator stopAnimating];
    headerImg.transform = CGAffineTransformIdentity;
    headerLabel.text = @"下拉刷新";
    
    [UIView animateWithDuration:0.3 animations:^{
        [scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }];
}

-(void)dealloc{
    [scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

@end
