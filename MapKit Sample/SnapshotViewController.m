//
//  SnapshotViewController.m
//  MapKit Sample
//
//  Created by Juan Pedro Catalán on 11/10/13.
//  Copyright (c) 2013 Juanpe Catalán. All rights reserved.
//

#import "SnapshotViewController.h"

@interface SnapshotViewController ()

@end

@implementation SnapshotViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.captureImgView setImage:self.mapCapture.image];
}

#pragma mar -
- (void) dealloc{

    self.mapCapture = nil;
}

- (IBAction)btnShareTouchUpInside:(id)sender {
    
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.captureImgView.image]
                                                                                         applicationActivities:nil];
    
    [self presentViewController:activityViewController
                       animated:YES
                     completion:nil];
}

@end
