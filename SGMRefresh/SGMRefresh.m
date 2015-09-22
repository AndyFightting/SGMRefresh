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

//动画时间
#define ANIMATION_TIME 0.25

typedef enum {
    NotRefreshing = 0,
    IsRefreshing = 1,
} SGMRefreshStatus;

@implementation SGMRefresh{
    
    float scrollViewWidth;
    float scrollViewHeight;

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
    float footerOrightY;//随scroll内容高度变化
    
    float headerFlag;//下拉到哪才可以刷新的伐值
    float footerFlag;//上拉到哪才可以刷新的伐值
    
    BOOL headerPassFlag;//下拉超过伐值
    BOOL footerPassFlag;//上拉超过伐值
    
    SGMRefreshStatus headerStatus;
    SGMRefreshStatus footerStatus;
    
    UIImageView* gifImgView;
}
@synthesize percentImgArray,runningImgArray;

-(instancetype)initWithScrollView:(UIScrollView*)sView withHeaderRefresh:(BOOL)hRefresh andFooterRefresh:(BOOL)fRefresh refreshDeletate:(id<SGMRefreshProtocol>)rDelegate{
    self = [super init];
    if (self) {
        scrollView = sView;
        headerRefresh = hRefresh;
        footerRefresh = fRefresh;
        refreshDelegate = rDelegate;
    
        scrollViewWidth = scrollView.frame.size.width;
        scrollViewHeight = scrollView.frame.size.height;
        
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
    
    headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(scrollViewWidth/2-15, headerHeight-40, 100, 20)];
    headerLabel.text = @"下拉刷新";
    headerLabel.textColor = [UIColor grayColor];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont systemFontOfSize:14];
    [headerContainerView addSubview:headerLabel];
    
    headerImg = [[UIImageView alloc]initWithFrame:CGRectMake(scrollViewWidth/2-35, headerHeight-45, 12, 30)];
    [headerImg setImage:[UIImage imageNamed:@"headerArrow.png"]];
    [headerContainerView addSubview:headerImg];
    
    headerIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    headerIndicator.frame =CGRectMake(scrollViewWidth/2-45, headerHeight-45, 30, 30);
    [headerContainerView addSubview:headerIndicator];
    
    //----添加gif动画-----
    gifImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10,headerHeight-55, 50, 50)];
    gifImgView.animationImages = runningImgArray;
    gifImgView.animationDuration = runningImgArray.count*0.1;
    [headerContainerView addSubview:gifImgView];
    
    percentImgArray = [[NSMutableArray alloc]init];
    runningImgArray = [[NSMutableArray alloc]init];

}
-(void)initFooterView{

    footerContainerView = [[UIView alloc]initWithFrame:CGRectMake(0, scrollView.frame.size.height, scrollViewWidth, footerHeight)];
    footerContainerView.backgroundColor = UIColorFromRGB(0xf2f2f2);
    [scrollView addSubview:footerContainerView];
    [self resetFooterView];
    
    footerLabel = [[UILabel alloc]initWithFrame:CGRectMake(scrollViewWidth/2-30, 20, 100, 20)];
    footerLabel.text = @"上拉加载更多";
    footerLabel.textColor = [UIColor grayColor];
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.font = [UIFont systemFontOfSize:14];
    [footerContainerView addSubview:footerLabel];
    
    footerImg = [[UIImageView alloc]initWithFrame:CGRectMake(scrollViewWidth/2-50, 15, 12, 30)];
    [footerImg setImage:[UIImage imageNamed:@"footerArrow.png"]];
    [footerContainerView addSubview:footerImg];
    
    footerIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    footerIndicator.frame =CGRectMake(scrollViewWidth/2-60, 15, 30, 30);
    [footerContainerView addSubview:footerIndicator];
    
}

-(void)resetFooterView{
    footerOrightY = MAX(scrollView.frame.size.height, scrollView.contentSize.height);
    
    CGRect footerRect = footerContainerView.frame;
    footerRect.origin.y = footerOrightY;
    footerContainerView.frame =footerRect;
}

//监听scrollView实时滚动
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{

    if (![keyPath isEqualToString:@"contentOffset"]) return;
    if (headerStatus == IsRefreshing) return; //正在刷新
    if (footerStatus == IsRefreshing) return; //正在加载更多
        
    CGFloat offSetY = scrollView.contentOffset.y;
    if (scrollView.isDragging) {//手一直接触着在拉
        if (offSetY <=0&&headerRefresh) {//处理下拉
            
            //手在拉时的动画处理----
            int intOffSetY = -(int)offSetY;
            if (intOffSetY<percentImgArray.count) {
               gifImgView.image = percentImgArray[intOffSetY];
            }
    
            if (offSetY < headerFlag && !headerPassFlag) {//超过伐值
                headerPassFlag = YES;
                headerLabel.text = @"释放刷新";
                
                //开始动画
                [gifImgView startAnimating];
                
                [UIView animateWithDuration:ANIMATION_TIME animations:^{
                    headerImg.transform = CGAffineTransformMakeRotation(3.1416);
                }];
                
            }else if(offSetY > headerFlag && headerPassFlag){//退回伐值
                headerPassFlag = NO;
                headerLabel.text = @"下拉刷新";
                
                //结束动画
                [gifImgView stopAnimating];
                
                [UIView animateWithDuration:ANIMATION_TIME animations:^{
                    headerImg.transform = CGAffineTransformIdentity;
                }];
            }
            
        }else{//处理上拉
            if(footerRefresh){
                float tmpHeight =offSetY+scrollViewHeight-footerOrightY;// 》=0 越往上拉越大
                if (tmpHeight > footerFlag && !footerPassFlag) {//超过伐值
                    footerPassFlag = YES;
                    footerLabel.text = @"释放立即加载";
                    [UIView animateWithDuration:ANIMATION_TIME animations:^{
                        footerImg.transform = CGAffineTransformMakeRotation(3.1415);
                    }];
                }else if (tmpHeight < footerFlag && footerPassFlag){//退回伐值
                    footerPassFlag = NO;
                    footerLabel.text = @"上拉加载更多";
                    [UIView animateWithDuration:ANIMATION_TIME animations:^{
                        footerImg.transform = CGAffineTransformIdentity;
                    }];
                }
            }
        }
        
    }else {//手放开了
        if (offSetY <= 0 && headerRefresh) {//下拉手放开的时候
            if (headerPassFlag && headerStatus == NotRefreshing) {
                [self beginHeaderRefresh_InnerUse];
            }
        }else{//上拉手放开的时候
            if (footerRefresh&&footerPassFlag&&footerStatus == NotRefreshing) {
                [self beginFooterRefresh];
            }
        }
    }
}
-(void)beginHeaderRefresh_InnerUse{
    if (!headerRefresh) {
        return;
    }
    
    headerStatus = IsRefreshing;
    headerLabel.text = @"正在刷新...";
    headerImg.hidden = YES;
    [headerIndicator startAnimating];
    if ([refreshDelegate respondsToSelector:@selector(SGMHeaderRefresh)]) {
        [refreshDelegate SGMHeaderRefresh];
    }
    
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        [scrollView setContentInset:UIEdgeInsetsMake(-headerFlag, 0, 0, 0)];
   }];
}

-(void)beginHeaderRefresh{
    if (!headerRefresh) {
        return;
    }
    
    //开始动画
    gifImgView.animationImages = runningImgArray;
    gifImgView.animationDuration = runningImgArray.count*0.1;
    [gifImgView startAnimating];
    
    headerStatus = IsRefreshing;
    headerLabel.text = @"正在刷新...";
    headerImg.hidden = YES;
    [headerIndicator startAnimating];
    if ([refreshDelegate respondsToSelector:@selector(SGMHeaderRefresh)]) {
        [refreshDelegate SGMHeaderRefresh];
    }

    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        scrollView.contentInset = UIEdgeInsetsMake(headerFlag, 0, 0, 0);
        scrollView.contentOffset = CGPointMake(0,headerFlag);
    }];
}

-(void)endHeaderRefresh{
    
    headerStatus = NotRefreshing;
    headerPassFlag = NO;
    
    headerImg.hidden = NO;
    [headerIndicator stopAnimating];
    headerImg.transform = CGAffineTransformIdentity;
    headerLabel.text = @"下拉刷新";
    
    [gifImgView performSelector:@selector(stopAnimating) withObject:nil afterDelay:ANIMATION_TIME];
    
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        [scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }];
    
    if (footerRefresh) {
        [self resetFooterView];//必须刷新footerView
    }
}

-(void)beginFooterRefresh{
    if (!footerRefresh) {
        return;
    }
    
    footerStatus = IsRefreshing;
    footerLabel.text = @"正在加载更多...";
    footerImg.hidden = YES;
    [footerIndicator startAnimating];
    if ([refreshDelegate respondsToSelector:@selector(SGMFooterRefresh)]) {
        [refreshDelegate SGMFooterRefresh];
    }
    
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        CGFloat bottom = footerFlag ;
        
        CGFloat deltaH = scrollView.contentSize.height - scrollViewHeight;
        if (deltaH < 0) {
            bottom =bottom + (-deltaH);
        }
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, bottom, 0);
    }];
}

-(void)endFooterRefresh{
    footerStatus = NotRefreshing;
    footerPassFlag = NO;
    footerImg.hidden = NO;
    [footerIndicator stopAnimating];
    footerImg.transform = CGAffineTransformIdentity;
    footerLabel.text = @"上拉加载更多";
    
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        scrollView.contentInset = UIEdgeInsetsZero;
    }];
    
    [self resetFooterView];//必须刷新footerView
}

-(void)dealloc{
    [percentImgArray removeAllObjects];
    [runningImgArray removeAllObjects];
    
    percentImgArray = nil;
    runningImgArray = nil;
    
    [scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

@end
