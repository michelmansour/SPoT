//
//  SpotCache.h
//  SPoT
//
//  Created by Michel Mansour on 11/30/13.
//  Copyright (c) 2013 Michel Mansour. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpotCache : NSObject

- (id)initWithSize:(NSUInteger)cacheSize;
- (void)cacheData:(NSData *)photoData forURL:(NSURL *)photoURL;
- (NSURL *)URLForCachedURL:(NSURL *)photoURL;

@end
