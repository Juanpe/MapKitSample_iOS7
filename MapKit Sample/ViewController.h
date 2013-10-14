//
//  ViewController.h
//  MapKit Sample
//
//  Created by Juan Pedro Catalán on 11/10/13.
//  Copyright (c) 2013 Juanpe Catalán. All rights reserved.
//

@import MapKit;
#import "StepViewController.h"


@interface ViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate>

#pragma mark - Properties
@property (nonatomic, strong) IBOutlet MKMapView*   mapView;
@property (nonatomic, strong) StepViewController*   stepVC;
@property (nonatomic, weak) IBOutlet UIButton*      btnExitStepRoute;
@property (nonatomic, weak) IBOutlet UISegmentedControl *mapTypeSelector;

#pragma mark - IBActions
- (IBAction) selectorMapTypeValueChanged:(id)sender;
- (IBAction) drawRegionWithPointsTouchUpInside;
- (IBAction) drawPolylineTouchUpInside;
- (IBAction) drawRouteTouchUpInside;
- (IBAction) takeSnapShotTouchUpInside;
- (IBAction) exitStepByStepTouchUpInside:(id)sender;

@end
