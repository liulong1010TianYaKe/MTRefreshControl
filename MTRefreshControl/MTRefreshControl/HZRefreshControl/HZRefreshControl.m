//
//  HZRefreshControl.m
//  MTRefreshControl
//
//  Created by long on 6/21/16.
//  Copyright © 2016 long. All rights reserved.
//

#import "HZRefreshControl.h"


@interface HZRefreshControl ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView<HZRefreshControlViewProtocol> *refreshView;
@property (nonatomic, assign) HZRefreshState  state;
@end

@implementation HZRefreshControl

#pragma mark -------------------
#pragma mark -  CycleLife

- (id)initWithConfiguration:(HZRefreshControlConfiguration *)configuration{
    if (self = [super init]) {
        self.minimumForStart = [configuration.minimumForStart floatValue];
        self.maximumForPull = [configuration.maximunForPull floatValue];
        self.refreshView = configuration.refreshView;
        self.refreshDisplayType = HZRefreshDisplayTypeDefault;
    }
    return self;
}

- (void)dealloc{
    
}

#pragma mark -------------------
#pragma mark - Setings, Getings
- (void)setState:(HZRefreshState)newstate{
    switch (newstate) {
        case HZRefreshStateNormal:
            [self.refreshView updateViewOnNormalStatePreviousState:newstate];
            break;
        case HZRefreshStatePulling:
            [self.refreshView updateViewOnPullingStatePreviousState:newstate];
            break;
        case HZRefreshStateLoading:
            [self.refreshView updateViewOnLoadingStatePreviousState:newstate];
            break;
            
        default:
            break;
    }
    
    _state = newstate;
}


#pragma mark -------------------
#pragma mark - Method
- (void)updateRefreshWithScrollView:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y  + self.minimumForStart > 0) return;
    
    CGFloat deltaOffsetY = MIN(fabs(scrollView.contentOffset.y + self.minimumForStart), self.maximumForPull);
    CGFloat percentage = deltaOffsetY / self.maximumForPull;
    
    CGRect refreshViewFrame = self.refreshView.frame;
    refreshViewFrame.size.height = deltaOffsetY;
    self.refreshView.frame = refreshViewFrame;
    if (self.refreshDisplayType == HZRefreshDisplayTypeDefault) {
        self.refreshView.center = CGPointMake(CGRectGetMidX(scrollView.bounds), scrollView.contentOffset.y / 2 + self.tableViewDefaultInsets.top / 2 + self.refreshViewOffsetY);
    }else if (self.refreshDisplayType == HzRefreshDisplayTypeTop){
        CGFloat centerY = scrollView.contentOffset.y / 2 + self.tableViewDefaultInsets.top / 2 - self.tableViewDefaultInsets.top + self.refreshViewOffsetY;
        self.refreshView.center = CGPointMake(CGRectGetMidX(scrollView.bounds), centerY);
    }
    [self.refreshView updateViewWithPercentage:percentage state:self.state];
}
#pragma mark -------------------
#pragma mark - Public Method
- (void)attchToScollView:(UIScrollView *)scrollView{
    self.scrollView = scrollView;
    self.tableViewDefaultInsets = scrollView.contentInset;
    if (self.refreshDisplayType == HZRefreshDisplayTypeDefault) {
        self.refreshView.center = CGPointMake(CGRectGetMidX(self.scrollView.bounds), - (self.maximumForPull - self.minimumForStart)/2 + self.tableViewDefaultInsets.top / 2 + self.refreshViewOffsetY);
    }else if (self.refreshDisplayType == HzRefreshDisplayTypeTop){
        CGFloat centerY = -1*(self.maximumForPull - self.minimumForStart) / 2 + self.tableViewDefaultInsets.top / 2 -self.tableViewDefaultInsets.top  + self.refreshViewOffsetY;
        self.refreshView.center = CGPointMake(CGRectGetMidX(scrollView.bounds), centerY);
    }
    
    [self.scrollView insertSubview:self.refreshView atIndex:0];
    self.canRefresh = YES;
    [self addObservers];
}

- (void)refreshOperation{
    if (!self.canRefresh) {
        return;
    }
    self.scrollView.contentOffset = CGPointMake(0, -self.minimumForStart - self.maximumForPull);
    [self setState:HZRefreshStatePulling];
    [self refreshScrollViewDidScroll:self.scrollView];
    [self refreshScrollViewDidEndDragging:self.scrollView];
//    if ([[[UIDevice currentDevice] systemVersion] doubleValue] < 7.0) {  //兼容ios6，让刷新视图在最下，避免在cell上面
//        [self.scrollView sendSubviewToBack:self.refreshView];
//    }
}

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
    if(!self.canRefresh) return;
    [self updateRefreshWithScrollView:scrollView];
    if (self.state == HZRefreshStateLoading) {
        CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
        offset = MIN(offset - self.tableViewDefaultInsets.top, 60);
        scrollView.contentInset = UIEdgeInsetsMake(offset+self.tableViewDefaultInsets.top, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right);
    }else if (scrollView.isDragging){
        BOOL _loading = NO;
        if ([self.delegate respondsToSelector:@selector(refreshDataSourceIsLoading:)]) {
            _loading = [self.delegate refreshDataSourceIsLoading:self];
        }
        _loading = self.isLoading;
        
        if (self.state == HZRefreshStatePulling && scrollView.contentOffset.y > - (self.maximumForPull+self.minimumForStart) && scrollView.contentOffset.y < 0.0f && !_loading) {
            [self setState:HZRefreshStateNormal];
        }else if (self.state == HZRefreshStateNormal && scrollView.contentOffset.y < -(self.maximumForPull + self.minimumForStart) && !_loading){
            [self setState:HZRefreshStatePulling];
        }
        
        if (scrollView.contentInset.top != self.tableViewDefaultInsets.top) {
            scrollView.contentInset = self.tableViewDefaultInsets;
        }
    }
    
}

- (void)refreshScrollViewDidEndDragging:(UIScrollView *)scrollView{
    if (!self.canRefresh) return;
    BOOL _loading = NO;
    if ([self.delegate respondsToSelector:@selector(refreshDataSourceIsLoading:)]) {
        _loading = [self.delegate refreshDataSourceIsLoading:self];
    }
    
    _loading = self.isLoading;
    
    if (self.state == HZRefreshStatePulling && !_loading) {
        if ([self.delegate respondsToSelector:@selector(refreshDidTrigerRefresh:)]) {
            [self.delegate refreshDidTrigerRefresh:self];
            self.isLoading = YES;
        }
        
        [self setState:HZRefreshStateLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.2];
        scrollView.contentInset = UIEdgeInsetsMake((self.maximumForPull + self.minimumForStart) + self.tableViewDefaultInsets.top, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right);
        [UIView commitAnimations];
    }
}


- (void)refreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView animated:(BOOL)animated{
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        [self.scrollView setContentInset:UIEdgeInsetsMake(0.0f+self.tableViewDefaultInsets.top, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right)];
        [UIView commitAnimations];
    }else{
           [self.scrollView setContentInset:UIEdgeInsetsMake(0.0f+self.tableViewDefaultInsets.top, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right)];
    }
    
    [self setState:HZRefreshStateNormal];
    if ([self.refreshView respondsToSelector:@selector(updateViewOnComplete)]) {
        [self.refreshView updateViewOnComplete];
    }
    
    self.isLoading = NO;
}
#pragma mark -------------------
#pragma mark - KVO
- (void)addObservers{
    [self.scrollView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    [self.scrollView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
}

- (void)removeObservers{
    [self.scrollView removeObserver:self forKeyPath:@"bounds"];
    [self.scrollView removeObserver:self forKeyPath:@"contentInset"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"bounds"]) {
        if (self.refreshView.frame.size.width != self.scrollView.bounds.size.width) {
            self.refreshView.frame = CGRectMake(0, -60, self.scrollView.bounds.size.width, 60);
            if (self.refreshDisplayType == HZRefreshDisplayTypeDefault) {
                self.refreshView.center = CGPointMake(CGRectGetMidX(self.scrollView.bounds), -1 * (self.maximumForPull - self.minimumForStart) / 2 + self.tableViewDefaultInsets.top / 2 + self.refreshViewOffsetY);
            }else if (self.refreshDisplayType == HzRefreshDisplayTypeTop){
                CGFloat centerY = -1 * (self.maximumForPull - self.minimumForStart) / 2 + self.tableViewDefaultInsets.top/2 - self.tableViewDefaultInsets.top + self.refreshViewOffsetY;
                self.refreshView.center = CGPointMake(CGRectGetMidX(self.scrollView.bounds), centerY);
            }

            if ([self.refreshView respondsToSelector:@selector(reChangeSubViewsFrame)]) {
                [self.refreshView performSelectorOnMainThread:@selector(reChangeSubViewsFrame) withObject:nil waitUntilDone:YES];
            }
        }
    }else if ([keyPath isEqualToString:@"contentInset"]){
        if (self.scrollView.contentInset.top == self.tableViewDefaultInsets.top * 2 && self.scrollView.contentInset.top > 0) { //top是64时触发
            self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right);
            self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y / 2);
        } else if ( self.scrollView.contentInset.top == self.tableViewDefaultInsets.top + 64 && self.scrollView.contentInset.top > 0) { //top是64+。。时触发
            self.scrollView.contentInset = UIEdgeInsetsMake(_tableViewDefaultInsets.top, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right);
            self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y + 64);
        }
    }
}
@end
























