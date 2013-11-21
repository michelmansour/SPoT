//
//  RecentPhoto.h
//  SPoT
//
//  Created by Michel Mansour on 11/20/13.
//  Copyright (c) 2013 Michel Mansour. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentPhoto : NSObject

+ (void)viewedPhoto:(NSDictionary *)photo; // Flickr photo dictionary
+ (NSArray *)allRecentPhotosByLastViewed; // of Flickr photo dictionary

@property (readonly, nonatomic) NSDate *lastViewed;
@property (readonly, nonatomic) NSDictionary *photo;

@end
