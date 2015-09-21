# SGMRefresh
自己写个下拉上拉刷新的模块
```
//使用
SGMRefresh* refreshView = [[SGMRefresh alloc]initWithScrollView:mTable withHeaderRefresh:YES andFooterRefresh:YES refreshDeletate:self];
[refreshView beginHeaderRefresh]; //初始化就刷新，可选

//代理方法
-(void)SGMHeaderRefresh{
//数据处理完后调用 [refreshView endHeaderRefresh]; 结束头部动画

}
-(void)SGMFooterRefresh{
//数据处理完后调用 [refreshView endFooterRefresh]; 结束尾部动画
}
```
![图片](https://github.com/AndyFightting/SGMRefresh/blob/master/simple.gif)
