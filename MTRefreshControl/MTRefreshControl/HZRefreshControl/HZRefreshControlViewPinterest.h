//
//  HZRefreshControlViewPinterest.h
//  MTRefreshControl
//
//  Created by long on 6/20/16.
//  Copyright © 2016 long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HZRefreshControlViewProtocol.h"

@interface HZRefreshControlViewPinterest : UIView<HZRefreshControlViewProtocol>

@property  (nonatomic, strong) UIColor *fillColor;    /**< 填充颜色 */
@property  (nonatomic, strong) UIColor *strokeColor;  /**< 边框颜色 */
@property  (nonatomic, strong) UIImage *imgContent;   /**< 填充图片 */


@end
