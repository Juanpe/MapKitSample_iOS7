//
//  SnapshotViewController.h
//  MapKit Sample
//
//  Created by Juan Pedro Catalán on 11/10/13.
//  Copyright (c) 2013 Juanpe Catalán. All rights reserved.
//

@import MapKit;

@interface SnapshotViewController : UIViewController

#pragma mark - Properties
@property (nonatomic, weak)     IBOutlet UIImageView* captureImgView;
@property (nonatomic, strong)   IBOutlet MKMapSnapshot* mapCapture;

#pragma mark - IBActions
- (IBAction)btnShareTouchUpInside:(id)sender;

@end
