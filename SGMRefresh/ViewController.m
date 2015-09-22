//
//  ViewController.m
//  SGMRefresh
//
//  Created by 苏贵明 on 15/9/20.
//  Copyright (c) 2015年 苏贵明. All rights reserved.
//

#import "ViewController.h"
#import "SGMRefresh.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,SGMRefreshProtocol>

@end

@implementation ViewController{

    UITableView* mTable;
    SGMRefresh* refreshView;
    
    int cellNum;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    cellNum = 8;

    mTable = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    mTable.dataSource = self;
    mTable.delegate = self;
    mTable.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:mTable];
    
    //----两个动画设置图片数组
    //3张图片帧
    NSMutableArray *runningImgArray = [NSMutableArray array];
    for (int i = 1; i<=3; ++i) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"runningImg%d",i]];
        [runningImgArray addObject:image];
    }
    //60张图片帧
    NSMutableArray *percentArray = [NSMutableArray array];
    for (NSUInteger i = 1; i<=60; ++i) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_anim__000%zd",i]];
        [percentArray addObject:image];
    }
    
    refreshView = [[SGMRefresh alloc]initWithScrollView:mTable withHeaderRefresh:YES andFooterRefresh:YES refreshDeletate:self];
    [refreshView.percentImgArray addObjectsFromArray:percentArray];
    [refreshView.runningImgArray addObjectsFromArray:runningImgArray];
    [refreshView beginHeaderRefresh];
}
#pragma mark - 刷新代理
-(void)SGMHeaderRefresh{
    [self performSelector:@selector(test1) withObject:nil afterDelay:1];
}
-(void)SGMFooterRefresh{
    [self performSelector:@selector(test2) withObject:nil afterDelay:1];
}
#pragma mark - -------------

-(void)test1{
    cellNum = 8;
    [mTable reloadData];
    [refreshView endHeaderRefresh];
}
-(void)test2{
    cellNum+= 8;
    [mTable reloadData];
    [refreshView endFooterRefresh];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return cellNum;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* identify = @"cell";

    UITableViewCell* cell =[tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"identify"];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@" cell  %d" ,(int)indexPath.row];
    
    return cell;

}

-(BOOL)prefersStatusBarHidden{//隐藏状态栏
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
