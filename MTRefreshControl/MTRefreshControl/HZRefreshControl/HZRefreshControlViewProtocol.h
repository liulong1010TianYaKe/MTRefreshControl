//
//  HZRefreshControlViewProtocol.h
//  MTRefreshControl
//
//  Created by long on 6/17/16.
//  Copyright © 2016 long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HZRefreshState) {
    HZRefreshStateNormal,
    HZRefreshStatePulling,
    HZRefreshStateLoading
};

@protocol HZRefreshControlViewProtocol <NSObject>

- (void)commonSetupOnInit;
- (void)updateViewWithPercentage:(CGFloat)percentage state:(HZRefreshState)state;
- (void)updateViewOnNormalStatePreviousState:(HZRefreshState)state;
- (void)updateViewOnLoadingStatePreviousState:(HZRefreshState)state;
- (void)updateViewOnPullingStatePreviousState:(HZRefreshState)state;
@optional
- (void)updateViewOnComplete;
- (void)reChangeSubViewsFrame;   /**< 重置子视图的坐标 */
@end
