//
//  RecentPhotosListViewController.m
//  SPoT
//
//  Created by Michel Mansour on 11/20/13.
//  Copyright (c) 2013 Michel Mansour. All rights reserved.
//

#import "RecentPhotosListViewController.h"
#import "RecentPhoto.h"

@interface RecentPhotosListViewController ()

@end

@implementation RecentPhotosListViewController

- (NSString *)reusableCellIdentifier {
    return @"Recent Photo";
}

- (void)setup {
    NSArray *recentPhotos = [RecentPhoto allRecentPhotosByLastViewed];
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    for (id item in recentPhotos) {
        if ([item isKindOfClass:[RecentPhoto class]]) {
            RecentPhoto *recentPhoto = (RecentPhoto *)item;
            [photos addObject:recentPhoto.photo];
        }
    }
    [self setPhotos:photos];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setup];
}

- (void)awakeFromNib {
    [self setup];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [self setup];
    return self;
}

@end
