//
//  HZRefreshControlConfiguration.m
//  MTRefreshControl
//
//  Created by long on 6/20/16.
//  Copyright © 2016 long. All rights reserved.
//

#import "HZRefreshControlConfiguration.h"

static const CGFloat MIN_PULL  = 24;
static const CGFloat MAX_PULL  = 60;

@implementation HZRefreshControlConfiguration


- (void)setRefreshView:(UIView<HZRefreshControlViewProtocol> *)refreshView{
    _refreshView = refreshView;
}

- (NSNumber *)maximunForPull{
    if (!_maximunForPull) {
        return [NSNumber numberWithFloat:MAX_PULL];
    }
    return _maximunForPull;
}

- (NSNumber *)minimumForStart{
    if (!_minimumForStart) {
        return [NSNumber numberWithFloat:MIN_PULL];
    }
    return _minimumForStart;
}


@end
