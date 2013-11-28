//
//  NetworkActivityIndictorControl.m
//  SPoT
//
//  Created by Michel Mansour on 11/28/13.
//  Copyright (c) 2013 Michel Mansour. All rights reserved.
//

#import "NetworkActivityIndictorControl.h"

@interface NetworkActivityIndictorControl ()
@property NSUInteger numActivities;
@end

@implementation NetworkActivityIndictorControl

+ (id)sharedControl {
    static NetworkActivityIndictorControl *sharedControl = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedControl = [[self alloc] init];
        sharedControl.numActivities = 0;
    });
    return sharedControl;
}

- (void)startActivity {
    @synchronized(self) {
        self.numActivities++;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

- (void)stopActivity {
    @synchronized(self) {
        self.numActivities--;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = (self.numActivities > 0);
    }
}

@end


