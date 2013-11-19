//
//  PhotoListViewController.m
//  SPoT
//
//  Created by Michel Mansour on 11/19/13.
//  Copyright (c) 2013 Michel Mansour. All rights reserved.
//

#import "PhotoListViewController.h"
#import "FlickrFetcher.h"

@interface PhotoListViewController ()

@end

@implementation PhotoListViewController

- (void)setPhotos:(NSArray *)photos {
    NSLog(@"%@", photos);
    _photos = photos;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FlickrPhoto" forIndexPath:indexPath];
    
    NSDictionary *photo = self.photos[indexPath.row];
    cell.textLabel.text = [photo[FLICKR_PHOTO_TITLE] description];
    cell.detailTextLabel.text = [[photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
    
    return cell;
}

@end
