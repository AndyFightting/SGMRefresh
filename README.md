# SGMRefresh
自己写个下拉上拉刷新的模块，主要就是在SGMRefresh里监听scrollView的contentOffset属性，然后处理offSet或inSet即可。
添加了gif下拉刷新的动画。代码简单易懂，好自定义，想在刷新头部或尾部加啥都可以，比如刷新时间啥的，这里就不加了，需要的话自己加O(∩_∩)O哈！

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
![图片](https://github.com/AndyFightting/SGMRefresh/blob/master/example.gif)
