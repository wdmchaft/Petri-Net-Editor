//
//  PNEViewController.h
//  Petri Net Editor
//
//  Created by Mathijs Saey on 21/03/12.
//  Copyright (c) 2012 Vrije Universiteit Brussel. All rights reserved.
//

//This class contains all methods and members that both the iPad and the iPhone viewcontrollers use

#import <UIKit/UIKit.h>
#import "drawing/PNEView.h"

@interface PNEViewController : UIViewController {

    UITextView *log;
    PNEView *petriNetView;
}

@property (nonatomic, readonly) IBOutlet UITextView *log;
@property (nonatomic, readonly) IBOutlet PNEView *petriNetView;

- (IBAction)addButtonPress:(id)sender;

- (IBAction)addArcButtonPres:(id)sender;
- (IBAction)addPlaceButtonPres:(id)sender;
- (IBAction)addTransitionButtonPres:(id)sender;

@end
