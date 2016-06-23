//
//  HZRefreshControlViewPinterest.m
//  MTRefreshControl
//
//  Created by long on 6/20/16.
//  Copyright © 2016 long. All rights reserved.
//

#import "HZRefreshControlViewPinterest.h"
#import "RHAnimator.h"

#define MHZRefreshControlViewDistance   180

@interface HZRefreshControlViewPinterest ()
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) CALayer *iconLayer;
@property (nonatomic, strong) CAShapeLayer *circleLayer;
@end

@implementation HZRefreshControlViewPinterest

@synthesize fillColor = _fillColor,strokeColor = _strokeColor,imgContent = _imgContent;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonSetupOnInit];
    }
    return self;
}



 /**< 重置子视图的坐标 */
- (void)reChangeSubViewsFrame{
    [CATransaction begin];
    [CATransaction setDisableActions:YES]; // 关闭隐式动画
    
    if (self.circleLayer) {
        self.circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)-10);    //设置动画圆圈坐标
    }
    
    if (self.iconLayer) {
        self.iconLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)-10); //设置刷新图片坐标
    }
    
    if (self.activityView) {
        self.activityView.center =  CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)-10);
    }
    
    [CATransaction commit];
}


#pragma mark --------------------
#pragma mark - Settings, Gettings
- (void)setFillColor:(UIColor *)newfillColor{
    
    if (newfillColor) {
        _fillColor = newfillColor;
        self.circleLayer.fillColor = newfillColor.CGColor;
        [self setNeedsDisplay];
    }
}

- (void)setImgContent:(UIImage *)imgContent{
    if (imgContent) {
        _imgContent = imgContent;
        self.iconLayer.contents = (__bridge id)imgContent.CGImage;
        [self setNeedsDisplay];
    }
}

- (void)setStrokeColor:(UIColor *)strokeColor{
    if (strokeColor) {
        _strokeColor = strokeColor;
        self.circleLayer.strokeColor = strokeColor.CGColor;
        [self setNeedsDisplay];
    }
}

- (UIImage *)imgContent{
    if (!_imgContent) {
        _imgContent = [UIImage imageNamed:@"com_refresh_icon"];
    }
    return _imgContent;
}

- (UIColor *)fillColor{
    if (_fillColor) {
        _fillColor = [UIColor clearColor];
    }
    return _fillColor;
}
- (UIColor *)strokeColor{
    if (!_strokeColor) {
        _strokeColor = [UIColor redColor];
    }
    return _strokeColor;
}
- (CALayer *)iconLayer{
    if (!_iconLayer) {
        _iconLayer = [CALayer layer];
    }
    return _iconLayer;
}

- (CAShapeLayer *)circleLayer{
    if (!_circleLayer) {
        _circleLayer = [CAShapeLayer layer];
    }
    return _circleLayer;
}
#pragma mark -------------------
#pragma mark -  HZRefreshControlViewProtocol
- (void)commonSetupOnInit{

    self.backgroundColor = [UIColor clearColor];   // 设置背景颜色
    self.circleLayer.frame = CGRectMake(0, 0, 25.0f, 25.0f);
    self.circleLayer.contentsGravity = kCAGravityCenter;
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:self.circleLayer.position radius:CGRectGetMinX(self.circleLayer.bounds) startAngle:0 endAngle:M_PI*2 clockwise:NO];
    self.circleLayer.path = circlePath.CGPath;
    self.circleLayer.fillColor = self.fillColor.CGColor;
    self.circleLayer.strokeColor = self.strokeColor.CGColor;
    self.circleLayer.lineWidth = 2.0f;
    self.circleLayer.strokeEnd = 0.0f;
    self.circleLayer.opacity = 0.0f;
    [self.layer addSublayer:self.circleLayer];

    self.iconLayer.frame = CGRectMake(0, 0, 24.0f, 24.0f);
    self.iconLayer.contentsGravity = kCAGravityCenter;
    self.iconLayer.contents = (__bridge id)self.imgContent.CGImage;
    self.iconLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - 10);
    self.iconLayer.opacity = 0.0f;
    self.iconLayer.contentsScale = [UIScreen mainScreen].scale;
    self.iconLayer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1.0);
    [self.layer addSublayer:self.iconLayer];
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityView.frame = CGRectMake(0, 0, 20.f, 20.0f);
    self.activityView.hidesWhenStopped = YES;
    self.activityView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - 10);
    [self addSubview:self.activityView];
   
}

- (void)updateViewWithPercentage:(CGFloat)percentage state:(HZRefreshState)state{
    CGFloat deltaRate = percentage * MHZRefreshControlViewDistance;
    CGFloat angelDegree = (MHZRefreshControlViewDistance - deltaRate);
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; //关闭隐式动画
    self.iconLayer.transform = CATransform3DMakeRotation((angelDegree)/MHZRefreshControlViewDistance *M_PI, 0, 0, 1.0f);
    self.circleLayer.strokeEnd = percentage;
    if (state != HZRefreshStateLoading) {
        self.iconLayer.opacity = percentage;
        self.circleLayer.opacity = percentage;
    }
    [CATransaction commit];
}


- (void)updateViewOnNormalStatePreviousState:(HZRefreshState)state{
    if (state == HZRefreshStatePulling) {
        self.iconLayer.opacity = 0;
        self.circleLayer.opacity = 0;
    }
    
    [self.activityView stopAnimating];
}
- (void)updateViewOnPullingStatePreviousState:(HZRefreshState)state{
    
}
- (void)updateViewOnLoadingStatePreviousState:(HZRefreshState)state{
    [self.activityView startAnimating];
    self.iconLayer.opacity = 0;
    self.circleLayer.opacity = 0;
    CATransform3D formMatrix = CATransform3DMakeScale(0.0, 0.0, 0.0);
    CATransform3D toMatrix = CATransform3DMakeScale(1.0f, 1.0f, 1.0f);
    CAKeyframeAnimation *animation = [RHAnimator animationWithCATransform3DForKeyPath:@"transform" easingFunction:RHElasticEaseOut fromMatrix:formMatrix toMatrix:toMatrix];
    animation.duration = 1.0f;
    animation.removedOnCompletion = NO;
    [self.activityView.layer addAnimation:animation forKey:@"transform"];
}
- (void)updateViewOnComplete{
    
}



@end
