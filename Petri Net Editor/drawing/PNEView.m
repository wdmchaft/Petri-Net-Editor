//
//  PNEView.m
//  Petri Net Editor
//
//  Created by Mathijs Saey on 14/02/12.
//  Copyright (c) 2012 Vrije Universiteit Brussel. All rights reserved.
//

#import "PNEView.h"

@implementation PNEView

@synthesize showLabels;
@synthesize manager;
@synthesize arcs, places, transitions;

#pragma mark - Lifecycle

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        manager = [[PNManager alloc] init];
        [manager retain];
        showLabels = true;
        arcs = [[NSMutableArray alloc] init];
        places = [[NSMutableArray alloc] init];
        transitions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self = [super initWithFrame:frame]) {
        manager = [[PNManager alloc] init];
        [manager retain];
        showLabels = true;
        arcs = [[NSMutableArray alloc] init];
        places = [[NSMutableArray alloc] init];
        transitions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) dealloc{
    [arcs release];
    [places release];
    [transitions release];
    
    [manager release];
    [super dealloc];    
}

#pragma mark - External input

- (void) addArc {
    
}

- (void) addPlace {
    
}

- (void) addTransition {
    
}

- (void) drawFromKernel: (PNManager*) kernel {
    manager = kernel;
    [self loadKernel];
}

#pragma mark - Drawing logic

- (void) loadKernel {
    [arcs removeAllObjects];
    [places removeAllObjects];
    [transitions removeAllObjects];
     
    //Load all Places
    for (PNPlace* place in manager.places) {
        [[PNEPlaceView alloc] initWithValues:place superView:self];
    }
    //Load all transitions    
    for (PNTransition* trans in manager.transitions) {
        [[PNETransitionView alloc] initWithValues:trans superView:self];
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{   CGFloat PXVal = 200;
    CGFloat TXVal = 200;
    
    for (PNEPlaceView* place in places) {
        [place drawNode:CGPointMake(PXVal, 100)];
        PXVal += PLACE_DIMENSION + 50;
        [place createTouchView:CGRectMake(place.xOrig, place.yOrig, place.dimensions, place.dimensions)];
        
        UITapGestureRecognizer *tmp = [[UITapGestureRecognizer alloc] initWithTarget:place action:@selector(toggleHighlight)];
        [place addTouchResponder:tmp];
        
    }
    
    for (PNETransitionView* trans in transitions) {
        [trans drawNode:CGPointMake(TXVal, 100 + PLACE_DIMENSION + 100)];
        TXVal += TRANSITION_DIMENSION + 50;
        
        [trans createTouchView:CGRectMake(trans.xOrig, trans.yOrig, trans.dimensions, trans.dimensions)];
        
        UITapGestureRecognizer *tmp = [[UITapGestureRecognizer alloc] initWithTarget:trans action:@selector(toggleHighlight)];
        [trans addTouchResponder:tmp];
    }
    
    for (PNEArcView* arc in arcs) {
        [arc drawArc];
    }
    
}

#pragma mark - TestCode

- (void) insertData {
    static bool isFirst = true;
    
    if (isFirst) {
        
        PNPlace* place_1 = [[PNPlace alloc] initWithName:@"Place 1"];
        PNPlace* place_2 = [[PNPlace alloc] initWithName:@"Place 2"];
        PNPlace* place_3 = [[PNPlace alloc] initWithName:@"Place 3"];
        PNPlace* place_4 = [[PNPlace alloc] initWithName:@"Place 4"];
        PNPlace* place_5 = [[PNPlace alloc] initWithName:@"Place 5"];
        
        
        PNTransition* trans_1 = [[PNTransition alloc] initWithName:@"Trans 1"];
        PNTransition* trans_2 = [[PNTransition alloc] initWithName:@"Trans 2"];
        PNTransition* trans_3 = [[PNTransition alloc] initWithName:@"Trans 3"];
        
        PNToken* token_1 = [[PNToken alloc] init];
        PNToken* token_2 = [[PNToken alloc] init];
        PNToken* token_3 = [[PNToken alloc] init];
        
        
        [place_1 addToken:token_1];
        [place_2 addToken:token_2];
        [place_2 addToken:token_3];
        
        PNArcInscription* arc_1 = [[PNArcInscription alloc] initWithType:NORMAL];
        PNArcInscription* arc_2 = [[PNArcInscription alloc] initWithType:NORMAL];
        PNArcInscription* arc_3 = [[PNArcInscription alloc] initWithType:NORMAL];
        PNArcInscription* arc_4 = [[PNArcInscription alloc] initWithType:NORMAL];
        PNArcInscription* arc_5 = [[PNArcInscription alloc] initWithType:NORMAL];
        PNArcInscription* arc_6 = [[PNArcInscription alloc] initWithType:NORMAL];
        PNArcInscription* arc_7 = [[PNArcInscription alloc] initWithType:NORMAL];
        
        
        [trans_1 addInput:arc_3 fromPlace:place_2];
        [trans_2 addOutput:arc_1 toPlace:place_1];
        [trans_3 addInput:arc_2 fromPlace:place_1];
        
        [trans_1 addOutput:arc_4 toPlace:place_3];
        
        [manager addPlace:place_1];
        [manager addPlace:place_2];
        [manager addPlace:place_3];
        [manager addPlace:place_4];
        [manager addPlace:place_5];
        
        [manager addTransition:trans_1];
        [manager addTransition:trans_2];
        [manager addTransition:trans_3]; 
        
        isFirst = false;
    }
}

@end
