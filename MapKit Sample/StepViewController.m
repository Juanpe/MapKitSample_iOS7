//
//  StepViewController.m
//  MapKit Sample
//
//  Created by Juan Pedro Catalán on 14/10/13.
//  Copyright (c) 2013 Juanpe Catalán. All rights reserved.
//

#import "StepViewController.h"

#pragma mark - Public constants
NSString * const JCChangeStepNotiticationKey = @"JCChangeStepNotiticationKey";

// Button tags
NSInteger const JCPrevButtonTag = 0;
NSInteger const JCNextButtonTag = 1;

@interface StepViewController ()

- (BOOL) _existPrevStep;
- (BOOL) _existNextStep;

@end

@implementation StepViewController

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) setSteps:(NSArray *)steps{

    _steps = nil;
    _steps = [[NSArray alloc] initWithArray:steps];

    _currentStepIndex = 0;
    
    MKRouteStep* newStep    = [_steps objectAtIndex:0];
    _stepIntructions.text   = newStep.instructions;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:JCChangeStepNotiticationKey
                                                        object:newStep];
}

#pragma mark - Show/Hide
- (void) showStepView:(BOOL) show{

    [self.btnPrevStep   setHidden:![self _existPrevStep]];
    [self.btnNextStep   setHidden:![self _existNextStep]];
    
    CGFloat originY = -39.0f;
    
    if (show) {
        originY = 62.0f;
    }
    
    [UIView animateWithDuration:0.5f
                     animations:^(void){
                         
                         CGRect currentFrame    = self.view.frame;
                         currentFrame.origin.y  = originY;
                         
                         self.view.frame        = currentFrame;
                         
                     }completion:^(BOOL finished){
                         
                     }];
}

#pragma mark - IBActions
- (IBAction) btnChangeStepTouchUpInside:(id)sender {

    if ([sender tag] == JCNextButtonTag) {
        _currentStepIndex++;
    }else{
        _currentStepIndex--;
    }
    
    [self.btnPrevStep   setHidden:![self _existPrevStep]];
    [self.btnNextStep   setHidden:![self _existNextStep]];
    
    MKRouteStep* newStep        = [self.steps objectAtIndex:_currentStepIndex];
    self.stepIntructions.text   = newStep.instructions;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:JCChangeStepNotiticationKey
                                                        object:newStep];
}

#pragma mark - Private Methods 

- (BOOL) _existPrevStep{

    return _currentStepIndex > 0;
}

- (BOOL) _existNextStep{

    return _currentStepIndex < ([_steps count] - 1);
}

#pragma mark - 

- (void) dealloc{

    [self setSteps:nil];
}

@end
