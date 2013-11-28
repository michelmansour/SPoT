//
//  NetworkActivityIndictorControl.h
//  SPoT
//
//  Created by Michel Mansour on 11/28/13.
//  Copyright (c) 2013 Michel Mansour. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkActivityIndictorControl : NSObject

+ (id)sharedControl;

- (void)startActivity;
- (void)stopActivity;

@end
