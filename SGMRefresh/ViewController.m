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

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor lightGrayColor];

    mTable = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    mTable.dataSource = self;
    mTable.delegate = self;
    mTable.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:mTable];
    
    refreshView = [[SGMRefresh alloc]initWithScrollView:mTable withHeaderRefresh:YES andFooterRefresh:YES refreshDeletate:self];
    [refreshView beginHeaderRefresh];
}
#pragma mark - 刷新代理
-(void)SGMHeaderRefresh{
    [refreshView performSelector:@selector(endHeaderRefresh) withObject:nil afterDelay:2];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 25;
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
