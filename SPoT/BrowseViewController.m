//
//  BrowseViewController.m
//  SPoT
//
//  Created by Michel Mansour on 11/18/13.
//  Copyright (c) 2013 Michel Mansour. All rights reserved.
//

#import "BrowseViewController.h"
#import "FlickrFetcher.h"

@interface BrowseViewController ()
@property (strong, nonatomic) NSMutableDictionary *tags;
@property (strong, nonatomic) NSMutableArray *tagNames;
@end

@implementation BrowseViewController

- (NSMutableDictionary *)tags {
    if (!_tags) self.tags = [[NSMutableDictionary alloc] init];
    return _tags;
}

- (NSMutableArray *)tagNames {
    if (!_tagNames) self.tagNames = [[NSMutableArray alloc] init];
    return _tagNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *photos = [FlickrFetcher stanfordPhotos];
    
    NSArray *badTags = @[@"cs193pspot", @"portrait", @"landscape"];
    for (NSDictionary *photo in photos) {
        for (NSString *tag in [photo[FLICKR_TAGS] componentsSeparatedByString:@" "]) {
            if (![badTags containsObject:tag]) {
                NSString *capTag = [tag capitalizedString];
                if (!self.tags[capTag]) {
                    self.tags[capTag] = [[NSMutableArray alloc] init];
                }
                [self.tags[capTag] addObject:photo];
            }
        }
    }
    
    [self.tagNames removeAllObjects];
    [self.tagNames addObjectsFromArray:[self.tags allKeys]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FlickrTag" forIndexPath:indexPath];
    
    NSString *tagTitle = self.tagNames[indexPath.row];
    cell.textLabel.text = tagTitle;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [self.tags[tagTitle] count]];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"List Photos"]) {
                [segue.destinationViewController setTitle:self.tagNames[indexPath.row]];
            }
        }
    }
}

@end
