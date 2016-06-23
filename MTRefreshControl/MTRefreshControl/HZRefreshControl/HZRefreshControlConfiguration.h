//
//  HZRefreshControlConfiguration.h
//  MTRefreshControl
//
//  Created by long on 6/20/16.
//  Copyright © 2016 long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HZRefreshControlViewProtocol.h"


typedef NS_ENUM(NSInteger, HZRefreshViewStyle) {
    HZRefreshViewStylePinterest
};

@interface HZRefreshControlConfiguration : NSObject
/**
 *  实现HZRefreshControlViewProtocol协议的refreshView
 */
@property (nonatomic, strong) UIView<HZRefreshControlViewProtocol> *refreshView;

@property (nonatomic, strong) NSNumber *minimumForStart;
@property (nonatomic, strong) NSNumber *maximunForPull;

@end
