//
//  PhotoListViewController.h
//  SPoT
//
//  Created by Michel Mansour on 11/19/13.
//  Copyright (c) 2013 Michel Mansour. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoListViewController : UITableViewController

- (NSString *)reusableCellIdentifier;

@property (strong, nonatomic) NSArray *photos;

@end
