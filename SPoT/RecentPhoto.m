//
//  RecentPhoto.m
//  SPoT
//
//  Created by Michel Mansour on 11/20/13.
//  Copyright (c) 2013 Michel Mansour. All rights reserved.
//

#import "RecentPhoto.h"
#import "FlickrFetcher.h"

@implementation RecentPhoto

#define ALL_PHOTOS_KEY @"RecentPhoto_All"
#define FLICKR_META_KEY @"FlickrMetadata"
#define LAST_VIEWED_KEY @"LastViewed"

#define MAX_RECENTS 10

+ (NSArray *)allRecentPhotosByLastViewed {
    NSMutableArray *allPhotos = [[NSMutableArray alloc] init];
    
    for (id plist in [[[NSUserDefaults standardUserDefaults] dictionaryForKey:ALL_PHOTOS_KEY] allValues]) {
        RecentPhoto *recentPhoto = [[RecentPhoto alloc] initFromPropertyList:plist];
        [allPhotos addObject:recentPhoto];
    }
     
    return [allPhotos sortedArrayUsingSelector:@selector(lastViewedComparator:)];
}

- (NSComparisonResult)lastViewedComparator:(RecentPhoto *)anotherPhoto {
    return [anotherPhoto.lastViewed compare:self.lastViewed];
}
            
- (id)initFromPropertyList:(id)plist {
    self = [self init];
    if (self) {
        if ([plist isKindOfClass:[NSDictionary class]]) {
            NSDictionary *photoDictionary = (NSDictionary *)plist;
            _photo = photoDictionary[FLICKR_META_KEY];
            _lastViewed = photoDictionary[LAST_VIEWED_KEY];
        }
    }
    return self;
}

+ (void)viewedPhoto:(NSDictionary *)photo {
    RecentPhoto *recentPhoto = [[RecentPhoto alloc] initWithPhoto:photo];
    [recentPhoto synchronize];
}

// designated initializer
- (id)initWithPhoto:(NSDictionary *)photo {
    self = [self init];
    if (self) {
        _photo = photo;
        _lastViewed = [NSDate date];
    }
    return self;
}

- (id)asPropertyList {
    return @{ FLICKR_META_KEY : self.photo, LAST_VIEWED_KEY : self.lastViewed };
}

+ (NSString *)leastRecentPhoto:(NSMutableDictionary *)userDefaults {
    if ([userDefaults count] > MAX_RECENTS) {
        RecentPhoto *oldestPhoto = nil;
        for (id photoId in [userDefaults allKeys]) {
            RecentPhoto *curPhoto = [[RecentPhoto alloc] initFromPropertyList:userDefaults[photoId]];
            if (!oldestPhoto || [curPhoto.lastViewed compare:oldestPhoto.lastViewed] == NSOrderedAscending) {
                oldestPhoto = curPhoto;
            }
        }
        return oldestPhoto.photo[FLICKR_PHOTO_ID];
    }
    
    return nil;
}

- (void)synchronize {
    NSMutableDictionary *mutableRecentPhotosFromUserDefaults = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:ALL_PHOTOS_KEY] mutableCopy];
    if (!mutableRecentPhotosFromUserDefaults) mutableRecentPhotosFromUserDefaults = [[NSMutableDictionary alloc] init];
    mutableRecentPhotosFromUserDefaults[self.photo[FLICKR_PHOTO_ID]] = [self asPropertyList];
    NSString *leastRecentId = [RecentPhoto leastRecentPhoto:mutableRecentPhotosFromUserDefaults];
    if (leastRecentId) {
        [mutableRecentPhotosFromUserDefaults removeObjectForKey:leastRecentId];
    }
    [[NSUserDefaults standardUserDefaults] setObject:mutableRecentPhotosFromUserDefaults forKey:ALL_PHOTOS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
