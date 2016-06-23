//
//  KyoLoadMoreControl.m
//  MTRefreshControl
//
//  Created by long on 6/22/16.
//  Copyright © 2016 long. All rights reserved.
//

#import "KyoLoadMoreControl.h"

typedef NS_ENUM(NSInteger, KyoLoadMoreControlState) {
    KyoLoadMoreControlStateNone = 0,
    KyoLoadMoreControlStateLoading = 1,
};

@interface KyoLoadMoreControl ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIButton  *btnLoadMore;
@property (nonatomic, strong) UILabel   *lblNoMore;

@property (nonatomic, assign) BOOL    isCanShowNoMore;  // 是否显示没有更多数据
@property (nonatomic, assign) KyoLoadMoreControlState  state;

- (void)btnLoadMoreTouchIn:(UIButton *)btn;

- (void)showOrHideLoadMoreView;
- (void)addObservers;
- (void)removeObservers;
- (void)reChangeFrame;  //重置frame(一般是scrollview变化才调用)
@end

@implementation KyoLoadMoreControl

#pragma mark -------------------
#pragma mark - CycLife
- (id)initWithScrollView:(UIScrollView *)scrollView{
    return [self initWithScrollView:scrollView withIsCanShowNoMore:NO];
}

- (id)initWithScrollView:(UIScrollView *)scrollView withIsCanShowNoMore:(BOOL)isCanShowNoMore{
    NSParameterAssert(scrollView);
   
    self = [[self class] new];
    if (self) {
        _isCanShowNoMore = isCanShowNoMore;
        _scrollView = scrollView;
        _canLoadMore = YES;
        _loadMoreButtonTitle = @"查看更多";
        [_scrollView addSubview:self];
        [self configuration];
    }
    return self;
}

- (void)configuration{
    if (_isCanShowNoMore) {
        self.defaultInsets = UIEdgeInsetsMake(self.scrollView.contentInset.top, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom + 30, self.scrollView.contentInset.right);
    }else{
        self.defaultInsets = self.scrollView.contentInset;
    }
    
    self.newInsets = self.scrollView.contentInset;
    [self addObservers];
    
    self.backgroundColor = [UIColor clearColor];
    self.frame = CGRectMake(0, self.scrollView.contentSize.height, self.scrollView.bounds.size.width, 30);
    self.alpha = 0;
    
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.activityView.hidesWhenStopped = YES;
    [self addSubview:self.activityView];
    
    self.btnLoadMore = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnLoadMore addTarget:self action:@selector(btnLoadMoreTouchIn:) forControlEvents:UIControlEventTouchUpInside];
    self.btnLoadMore.frame = self.bounds;
    [self.btnLoadMore setBackgroundImage:[UIImage imageNamed:@"btn_blue_moren"] forState:UIControlStateNormal];
    [self.btnLoadMore setBackgroundImage:[UIImage imageNamed:@"btn_blue_gaoliang"] forState:UIControlStateHighlighted];
    [self.btnLoadMore setTitle:self.loadMoreButtonTitle forState:UIControlStateNormal];
    self.btnLoadMore.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.btnLoadMore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnLoadMore setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self addSubview:self.btnLoadMore];
    
    self.lblNoMore = [[UILabel alloc] initWithFrame:self.bounds];
    self.lblNoMore.backgroundColor = [UIColor clearColor];
    self.lblNoMore.textColor = [UIColor colorWithRed:153/225.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    self.lblNoMore.font = [UIFont systemFontOfSize:12];
    self.lblNoMore.text = @"没有更多了";
    self.lblNoMore.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.lblNoMore];
    
    self.kyoLoadMoreControlType = KyoLoadMoreControlTypeDefault;
    [self reChangeFrame];
 
}

- (void)dealloc{
    [self removeObservers];
}
#pragma mark -------------------
#pragma mark - Methods


- (void)addObservers{
    [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.scrollView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.scrollView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

- (void)removeObservers{
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.scrollView removeObserver:self forKeyPath:@"bounds"];
    [self.scrollView removeObserver:self forKeyPath:@"contentInset"];
}

// 显示或隐藏加载更多
- (void)showOrHideLoadMoreView{
    if (self.canLoadMore) {
        if (self.numberOfPage > self.currentPage+1) {
            self.alpha = 1;
            if (!UIEdgeInsetsEqualToEdgeInsets(self.scrollView.contentInset, self.newInsets)) {
                self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top, self.scrollView.contentInset.left, self.newInsets.bottom, self.scrollView.contentInset.right);
            }
            
            if (self.kyoLoadMoreControlType == KyoLoadMoreControlTypeDefault) {
                self.activityView.hidden = NO;
                [self.activityView startAnimating];
                self.btnLoadMore.hidden = YES;
                self.lblNoMore.hidden = YES;
            } else if (self.kyoLoadMoreControlType == KyoLoadMoreControlTypeManualLoad) {
                self.activityView.hidden = YES;
                [self.activityView stopAnimating];
                self.btnLoadMore.hidden = NO;
                self.lblNoMore.hidden = YES;
            }
            
        } else {
            if (self.numberOfPage > 0 &&
                self.isCanShowNoMore) {
                self.alpha = 1;
                self.activityView.hidden = YES;
                [self.activityView stopAnimating];
                self.btnLoadMore.hidden = YES;
                self.lblNoMore.hidden = NO;
            } else {
                self.alpha = 0;
                if (!UIEdgeInsetsEqualToEdgeInsets(self.scrollView.contentInset, self.defaultInsets)) {
                    self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top, self.scrollView.contentInset.left, self.defaultInsets.bottom, self.scrollView.contentInset.right);
                }
            }
        }
    } else {
        self.alpha = 0;
        if (!UIEdgeInsetsEqualToEdgeInsets(self.scrollView.contentInset, self.defaultInsets)) {
            self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top, self.scrollView.contentInset.left, self.defaultInsets.bottom, self.scrollView.contentInset.right);
        }
    }
}

//重置frame(一般是scrollview变化才调用)
- (void)reChangeFrame {
    if (self.numberOfPage  > self.currentPage + 1 && self.canLoadMore && self.kyoLoadMoreControlType == KyoLoadMoreControlTypeManualLoad) {
        self.frame = CGRectMake(0, self.scrollView.contentSize.height-30, self.scrollView.bounds.size.width, 30);
    }else{
        self.frame = CGRectMake(0, self.scrollView.contentSize.height, self.scrollView.bounds.size.width, 30);
    }
    
    if (self.activityView) {
        self.activityView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
    if (self.btnLoadMore) {
        self.btnLoadMore.frame = self.bounds;
    }
}

// 加载完成第Index页
- (void)loadCompleteCurrent{
    if (self.state != KyoLoadMoreControlStateLoading) {
        return;
    }
    self.currentPage += 1;
    self.state = KyoLoadMoreControlStateNone;
}

- (void)loadFaultCurrent{
    if (self.state != KyoLoadMoreControlStateLoading) {
        return;
    }
    
    self.state = KyoLoadMoreControlStateNone;
}

- (void)cancelLoadMore{
    if (self.state != KyoLoadMoreControlStateLoading) {
        return;
    }
    
    self.state = KyoLoadMoreControlStateNone;
}
#pragma mark --------------------
#pragma mark - Settings, Gettings
- (void)setKyoLoadMoreControlType:(KyoLoadMoreControlType)kyoLoadMoreControlType{
    _kyoLoadMoreControlType = kyoLoadMoreControlType;
    if (kyoLoadMoreControlType == KyoLoadMoreControlTypeDefault) {
        [self.activityView startAnimating];
        self.btnLoadMore.hidden = YES;
    }else if (kyoLoadMoreControlType == KyoLoadMoreControlTypeManualLoad){
        [self.activityView stopAnimating];
        self.btnLoadMore.hidden = NO;
    }
}

- (void)setCanLoadMore:(BOOL)canLoadMore{
    _canLoadMore = canLoadMore;
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(showOrHideLoadMoreView) object:nil];
    [self performSelector:@selector(showOrHideLoadMoreView) withObject:nil afterDelay:0.5f];
}

- (void)setNumberOfPage:(NSInteger)numberOfPage{
    if (_numberOfPage == numberOfPage) {
        return;
    }
    
    _numberOfPage = numberOfPage;
    [self showOrHideLoadMoreView];
}

- (void)setCurrentPage:(NSInteger)currentPage{
    _currentPage = currentPage;
    [self showOrHideLoadMoreView];
}

- (void)setState:(KyoLoadMoreControlState)state{
    _state = state;
    if (self.kyoLoadMoreControlType == KyoLoadMoreControlTypeManualLoad) { // 手动模式
        if (state == KyoLoadMoreControlStateNone) {
            [self.activityView stopAnimating];
            self.btnLoadMore.hidden = NO;
        }else if (state == KyoLoadMoreControlStateLoading){
            [self.activityView startAnimating];
            self.btnLoadMore.hidden = YES;
        }
    }
}
#pragma mark --------------------
#pragma mark - Events

- (void)btnLoadMoreTouchIn:(UIButton *)btn{
    
    // 加载下一页
    self.state = KyoLoadMoreControlStateLoading;
    if (self.delegate && [self.delegate respondsToSelector:@selector(KyoLoadMoreControl:loadPage:)]) {
        [self.delegate KyoLoadMoreControl:self loadPage:self.currentPage+1];
    }
}



#pragma mark --------------------
#pragma mark - KVO/KVC
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (!self.delegate) {
        self.scrollView.delegate = nil;
        return;
    }
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGRect frame = self.frame;
        frame.origin.y = self.scrollView.contentSize.height;
        self.frame = frame;
//        self.frame = CGRectMake(0, self.scrollView.contentSize.height, self.scrollView.bounds.size.width, 30);
    }else if ([keyPath isEqualToString:@"contentOffset"]){
        //如果不能加载或者正在加载，跳出
        if (!self.canLoadMore || self.state == KyoLoadMoreControlStateLoading) return;
        // 如果总页数小于0或者已经是最后一页, 跳出
        if (self.numberOfPage <= 0 || self.currentPage + 1 >= self.numberOfPage) return;
        // 若果没有达到加载状态，跳出
        if(self.scrollView.contentOffset.y + self.scrollView.bounds.size.height < self.scrollView.contentSize.height + 20) return;
        if (self.scrollView.contentSize.height <= 0)return;
        // 若果是手动点击按钮加载更多跳出
        if (self.kyoLoadMoreControlType == KyoLoadMoreControlTypeManualLoad) return;
        
        // 加载下一页
        self.state = KyoLoadMoreControlStateLoading;
        if (self.delegate && [self.delegate respondsToSelector:@selector(KyoLoadMoreControl:loadPage:)]) {
            [self.delegate KyoLoadMoreControl:self loadPage:self.currentPage+1];
        }
    }else if ([keyPath isEqualToString:@"bounds"]){
        [self reChangeFrame];
    }else if ([keyPath isEqualToString:@"contentInset"]){
        if (self.scrollView.contentInset.bottom == self.defaultInsets.bottom * 2 && self.scrollView.contentInset.bottom > 0) {
            self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top, self.scrollView.contentInset.left, self.self.defaultInsets.bottom, self.scrollView.contentInset.right);
        }
    }
}
@end
