//
//  HZRefreshControl.h
//  MTRefreshControl
//
//  Created by long on 6/21/16.
//  Copyright © 2016 long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HZRefreshControlConfiguration.h"

typedef NS_ENUM(NSInteger,HZRefreshDiplayType) {
    HZRefreshDisplayTypeDefault = 0,   /**< 默认方式刷新时上面出现菊花，显示在contentoffset <= 69 */
    HzRefreshDisplayTypeTop = 1, /**< 刷新时上面出现菊花，显示在 contentoffset设置的值地方 */
};


@protocol HZRefreshControlDelegate;

@interface HZRefreshControl : NSObject
@property (nonatomic, weak)   id<HZRefreshControlDelegate> delegate;
@property (nonatomic, assign) UIEdgeInsets tableViewDefaultInsets; /**< tableView默认的insets */
@property (nonatomic, assign) HZRefreshDiplayType refreshDisplayType;  /**< 刷新样式，默认HZRefreshDisplayTypeDefault */
@property (nonatomic, assign) CGFloat  refreshViewOffsetY;   /**< refreshView的y轴偏移量 */
@property (nonatomic, assign) CGFloat  minimumForStart;
@property (nonatomic, assign) CGFloat  maximumForPull;
@property (nonatomic, assign) BOOL     isLoading;   /**< 是否在刷新 */
@property (nonatomic, assign) BOOL     canRefresh;  /**< 是否能刷新 */
@property (nonatomic, assign) NSInteger tag;

- (id)initWithConfiguration:(HZRefreshControlConfiguration *)configuration;
- (void)attchToScollView:(UIScrollView *)scrollView;

- (void)refreshOperation;  /**< 手动刷新 */

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)refreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)refreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView animated:(BOOL)animated;

@end


@protocol HZRefreshControlDelegate <NSObject>

- (void)refreshDidTrigerRefresh:(HZRefreshControl*)refreshControl;
@optional
- (BOOL)refreshDataSourceIsLoading:(HZRefreshControl *)refreshControl;

@end



