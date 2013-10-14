//
//  StepViewController.h
//  MapKit Sample
//
//  Created by Juan Pedro Catalán on 14/10/13.
//  Copyright (c) 2013 Juanpe Catalán. All rights reserved.
//

@import MapKit;

UIKIT_EXTERN NSString * const JCChangeStepNotiticationKey;

@interface StepViewController : UIViewController

#pragma mark - Properties
@property (nonatomic, strong) NSArray* steps;
@property (nonatomic, weak) IBOutlet UIButton *btnPrevStep;
@property (nonatomic, weak) IBOutlet UIButton *btnNextStep;
@property (nonatomic, weak) IBOutlet UILabel *stepIntructions;
@property (nonatomic) NSInteger currentStepIndex;

#pragma mark - IBActions
- (IBAction)btnChangeStepTouchUpInside:(id)sender;

#pragma mark - Show/Hide
- (void) showStepView:(BOOL) show;

@end
