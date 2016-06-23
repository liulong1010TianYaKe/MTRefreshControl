//
//  ViewController.m
//  MTRefreshControl
//
//  Created by long on 6/17/16.
//  Copyright © 2016 long. All rights reserved.
//

#import "ViewController.h"
#import "HZRefreshControl.h"
#import "HZRefreshControlViewPinterest.h"
#import "KyoLoadMoreControl.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,HZRefreshControlDelegate,KyoLoadMoreControlDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HZRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, strong) KyoLoadMoreControl *kyoLoadMoreControl;

@property (nonatomic, assign) NSInteger arrCount;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) UIPinchGestureRecognizer  *pinchGeture;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    
    HZRefreshControlViewPinterest *refreshView = [[HZRefreshControlViewPinterest alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    refreshView.strokeColor = [UIColor greenColor];
    HZRefreshControlConfiguration *configuraion = [[HZRefreshControlConfiguration alloc] init];
    configuraion.refreshView = refreshView;
    configuraion.minimumForStart = @(0+self.tableView.contentInset.top);
    configuraion.maximunForPull = @(60);
    
    self.refreshControl = [[HZRefreshControl alloc] initWithConfiguration:configuraion];
    self.refreshControl.delegate = self;
    [self.refreshControl attchToScollView:self.tableView];
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    self.pan = self.tableView.panGestureRecognizer;
    self.pinchGeture = self.tableView.pinchGestureRecognizer;
    [self.pan addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    self.kyoLoadMoreControl = [[KyoLoadMoreControl alloc] initWithScrollView:self.tableView withIsCanShowNoMore:YES];
    self.kyoLoadMoreControl.delegate = self;
    self.kyoLoadMoreControl.kyoLoadMoreControlType = KyoLoadMoreControlTypeManualLoad;
    
//    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadData:0];
    });
}

- (void)dealloc{
    [self.pan removeObserver:self forKeyPath:@"state"];
}
- (void)loadData:(NSInteger )index{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.loading = NO;
//        [self.refreshControl refreshScrollViewDidEndDragging:self.tableView];
        if (index == 0) {
            self.arrCount = 15;
        }else{
            self.arrCount = index * 15 + 15;
        }
        [self.refreshControl refreshScrollViewDataSourceDidFinishedLoading:self.tableView animated:YES];
        self.kyoLoadMoreControl.numberOfPage  = 10;
        self.kyoLoadMoreControl.currentPage = index;
        [self.tableView reloadData];
        
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"viceceel"];
    if (!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"---%ld---",(long)indexPath.row];
    return cell;
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self.refreshControl refreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [self.refreshControl refreshScrollViewDidEndDragging:scrollView];
    
}

- (void)refreshDidTrigerRefresh:(HZRefreshControl*)refreshControl{
    self.loading = YES;
    [self loadData:0];
}
- (BOOL)refreshDataSourceIsLoading:(HZRefreshControl *)refreshControl{
    return self.loading;
}

- (void)KyoLoadMoreControl:(KyoLoadMoreControl *)kyoLoadMoreControl loadPage:(NSInteger)index{
    [self loadData:index];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"state"]) {
        NSLog(@"pan  state %@",change);
    }
}
@end
