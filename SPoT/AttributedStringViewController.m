//
//  AttributedStringViewController.m
//  SPoT
//
//  Created by Michel Mansour on 11/23/13.
//  Copyright (c) 2013 Michel Mansour. All rights reserved.
//

#import "AttributedStringViewController.h"

@interface AttributedStringViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) UIPopoverController *sharePopover;
@end

@implementation AttributedStringViewController

- (void)setText:(NSAttributedString *)text {
    _text = text;
    self.textView.attributedText = text;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.attributedText = self.text;
}

- (IBAction)shareURL:(UIBarButtonItem *)sender {
    
    if (!self.sharePopover || !self.sharePopover.popoverVisible) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                                initWithActivityItems:@[ self.text ] applicationActivities:nil];
        activityVC.excludedActivityTypes = @[ UIActivityTypePostToWeibo ];
        self.sharePopover = [[UIPopoverController alloc]initWithContentViewController:activityVC];
        [self.sharePopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

@end
