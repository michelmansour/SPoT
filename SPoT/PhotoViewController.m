//
//  PhotoViewController.m
//  SPoT
//
//  Created by Michel Mansour on 11/19/13.
//  Copyright (c) 2013 Michel Mansour. All rights reserved.
//

#import "PhotoViewController.h"
#import "AttributedStringViewController.h"
#import "NetworkActivityIndictorControl.h"
#import "FlickrFetcher.h"
#import "SpotCache.h"

@interface PhotoViewController () <UIScrollViewDelegate, UIToolbarDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleButtonItem;
@property (strong, nonatomic) UIPopoverController *urlPopover;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) SpotCache *photoCache;
@end

@implementation PhotoViewController

#define FORMAT_LARGE_CACHE_SIZE 3 * 1024 * 1024
#define FORMAT_ORIGINAL_CACHE_SIZE 12 * 1024 * 1024

- (void)setPhotoURL:(NSURL *)photoURL forFormat:(FlickrPhotoFormat) flickrPhotoFormat {
    _photoURL = photoURL;
    [self resetImage];
}

- (void)setFlickrPhotoFormat:(NSNumber *)flickrPhotoFormat {
    _flickrPhotoFormat = flickrPhotoFormat;
}

- (UIImageView *)imageView {
    if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return _imageView;
}

- (SpotCache *)photoCache {
    if (!_photoCache) {
        if ([self.flickrPhotoFormat integerValue] == FlickrPhotoFormatOriginal) {
            _photoCache = [[SpotCache alloc] initWithSize:FORMAT_ORIGINAL_CACHE_SIZE];
        } else {
            _photoCache = [[SpotCache alloc] initWithSize:FORMAT_LARGE_CACHE_SIZE];
        }
    }
    return _photoCache;
}

- (void)resetImage {
    if (self.scrollView && self.photoURL) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        
        [self.activityIndicator startAnimating];
        NSURL *photoURL = self.photoURL;
        
        dispatch_queue_t imageFetchQ = dispatch_queue_create("image fetcher", NULL);
        dispatch_async(imageFetchQ, ^{
            NSURL *cachedURL = [self.photoCache URLForCachedURL:self.photoURL];
            NSData *imageData;
            if (cachedURL) {
                NSLog(@"Fetching photo from cache: %@", [cachedURL path]);
                imageData = [[NSData alloc] initWithContentsOfURL:cachedURL];
            } else {
                NSLog(@"Fetching photo from network");
                [[NetworkActivityIndictorControl sharedControl] startActivity];
                imageData = [[NSData alloc] initWithContentsOfURL:self.photoURL];
                [[NetworkActivityIndictorControl sharedControl] stopActivity];
            }
            [self.photoCache cacheData:imageData forURL:self.photoURL];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            
            if (photoURL == self.photoURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        self.scrollView.zoomScale = 1.0;
                        self.scrollView.contentSize = image.size;
                        self.imageView.image = image;
                        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                        if (self.titleButtonItem) {
                            self.titleButtonItem.title = self.title;
                        }
                    }
                    [self.activityIndicator stopAnimating];
                });
            }
        });
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"Show URL"]) {
        return (self.photoURL && !self.urlPopover.popoverVisible) ? YES : NO;
    } else {
        return NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Show URL"]) {
        if ([segue.destinationViewController isKindOfClass:[AttributedStringViewController class]]) {
            AttributedStringViewController *asc = (AttributedStringViewController *)segue.destinationViewController;
            asc.text = [[NSAttributedString alloc] initWithString:[self.photoURL description]];
            if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
                self.urlPopover = ((UIStoryboardPopoverSegue *)segue).popoverController;
                asc.usePopoverController = YES;
            } else {
                asc.usePopoverController = NO;
            }
        }
    }
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    self.titleButtonItem.title = self.title;
    self.toolbar.delegate = self;
    [self resetImage];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    double hScale = self.scrollView.bounds.size.width / self.imageView.image.size.width;
    double vScale = self.scrollView.bounds.size.height / self.imageView.image.size.height;
    self.scrollView.zoomScale = hScale > vScale ? hScale : vScale;
}

@end
