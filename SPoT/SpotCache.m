//
//  SpotCache.m
//  SPoT
//
//  Created by Michel Mansour on 11/30/13.
//  Copyright (c) 2013 Michel Mansour. All rights reserved.
//

#import "SpotCache.h"

@interface SpotCache ()
@property (strong, nonatomic) NSFileManager *fileManager;
@property (nonatomic) NSUInteger maxCacheSize;
@end

@implementation SpotCache

#define CACHE_DIR @"flickrPhotos"

// default initializer
- (id)initWithSize:(NSUInteger)cacheSize {
    self = [super init];
    if (self) {
        self.fileManager = [[NSFileManager alloc] init];
        self.maxCacheSize = cacheSize;
        if (![self.fileManager fileExistsAtPath:[[self cacheDir] path]]) {
            [self.fileManager createDirectoryAtPath:[[self cacheDir] path]
                        withIntermediateDirectories:NO
                                         attributes:nil
                                              error:nil];
        }
    }
    return self;
}

- (NSURL *)cacheDir {
    NSURL *retval = [[self.fileManager URLsForDirectory:NSCachesDirectory
                                     inDomains:NSUserDomainMask][0]
            URLByAppendingPathComponent:CACHE_DIR isDirectory:NO];
    return retval;
}

- (void)cleanCacheForNewData:(NSData *)newData {
    NSLog(@"Want to cache data: %d", [newData length]);
    __block unsigned long long totalSize = 0;
    NSMutableArray *files = [NSMutableArray array];
    for (NSURL *url in [self.fileManager contentsOfDirectoryAtURL:[self cacheDir]
                                       includingPropertiesForKeys:@[NSURLAttributeModificationDateKey]
                                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                                            error:nil]) {
        NSDictionary *fileAttrs = [self.fileManager attributesOfItemAtPath:[url path] error:nil];
        totalSize += [fileAttrs fileSize];
        [files addObject:@{ @"url":url, @"size":[NSNumber numberWithLongLong:[fileAttrs fileSize]], @"date":[fileAttrs fileModificationDate]}];
    }
    NSLog(@"Cache status: %lld/%d", totalSize, self.maxCacheSize);
    
    if ([newData length] + totalSize > self.maxCacheSize) {
        NSLog(@"Max cache size will be exceeded. Cleaning cache first.");
        NSArray *sortedFiles = [files sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj1 valueForKey:@"date"] compare:[obj2 valueForKey:@"date"]];
        }];
        [sortedFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            unsigned long long fileSize = [[obj valueForKey:@"size"] longValue];
            totalSize -= fileSize;
            NSError *error;
            [self.fileManager removeItemAtPath:[[obj valueForKey:@"url"] path] error:&error];
            if (error) {
                NSLog(@"%@", error);
            }
            *stop = error || ([newData length] + totalSize <= self.maxCacheSize);
        }];
    }
    NSLog(@"New cache status: %lld/%d", totalSize, self.maxCacheSize);
    NSLog(@"\tWith new data: %lld/%d", [newData length] + totalSize, self.maxCacheSize);
}

- (void)cacheData:(NSData *)photoData forURL:(NSURL *)photoURL {
    if (photoData) {
        NSURL *cacheDir = [self cacheDir];
        if (cacheDir) {
            NSURL *cachePhotoURL = [cacheDir URLByAppendingPathComponent:[photoURL lastPathComponent]];
            if ([self.fileManager fileExistsAtPath:[cachePhotoURL path]]) {
                [self.fileManager setAttributes:@{ NSFileModificationDate:[NSDate date] }
                                   ofItemAtPath:[cachePhotoURL path]
                                          error:nil];
            } else {
                if ([photoData length] <= self.maxCacheSize) { // make sure the new data will actually fit in the cache
                    [self cleanCacheForNewData:photoData];
                    [self.fileManager createFileAtPath:[cachePhotoURL path]
                                              contents:photoData
                                            attributes:nil];
                }
            }
        }
    }
}

- (NSNumber *)cacheSize {
    unsigned long long totalSize = 0;
    for (NSString *path in [self.fileManager contentsOfDirectoryAtPath:[[self cacheDir] path] error:nil]) {
        totalSize += [[self.fileManager attributesOfItemAtPath:path error:nil] fileSize];
    }
    return [NSNumber numberWithLongLong:totalSize];
}

- (NSURL *)URLForCachedURL:(NSURL *)photoURL {
    NSURL *cachedURL = [[self cacheDir] URLByAppendingPathComponent:[photoURL lastPathComponent]];
    if ([self.fileManager fileExistsAtPath:[cachedURL path]]) {
        return cachedURL;
    }
    return nil;
}

@end
