//
//  PNEView.m
//  Petri Net Editor
//
//  Created by Mathijs Saey on 14/02/12.
//  Copyright (c) 2012 Vrije Universiteit Brussel. All rights reserved.
//

#import "PNEView.h"

@implementation PNEView

@synthesize arcs, places, transitions, collections;
@synthesize log, contextInformation;
@synthesize showLabels;
@synthesize manager;

#pragma mark - Lifecycle

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        manager = [PNManager sharedManager];
        showLabels = true;
        arcs = [[NSMutableArray alloc] init];
        places = [[NSMutableArray alloc] init];
        transitions = [[NSMutableArray alloc] init];
        collections = [[NSMutableArray alloc] init];
        currentLocation = CGPointMake(START_OFFSET_X, START_OFFSET_Y);
    }
    return self;
}

- (void) dealloc{
    [arcs release];
    [places release];
    [transitions release];
    [collections release];
    
    [super dealloc];    
}

#pragma mark - External input

/**
 Prepares the view for adding an arc
 */
- (void) addArc {
    if (!isAddingArc) {
        [self dimNodes];
        [self setNeedsDisplay];
        isAddingArc = true;}
    else {
        isAddingArc = false;
        arcPlace = NULL;
        arcTrans = NULL;
        [self dimNodes];
        [self setNeedsDisplay];
    }
}

/**
 Adds the arc to the kernel after a place and transition have been selected
 @param isPlaceFirst
    if true the arc goes from the place to the transition
    if false the arc goes from the transition to the place
 */
- (void) finishAddingArc: (BOOL) isPlaceFirst {
    PNArcInscription *arc = [[PNArcInscription alloc] initWithType:NORMAL];
    
    if (isPlaceFirst)
        [arcTrans.element addInput: arc fromPlace: arcPlace.element];
    else [arcTrans.element addOutput: arc toPlace: arcPlace.element];
    
    isAddingArc = false;
    arcPlace = NULL;
    arcTrans = NULL;
    
    [self dimNodes];
    [self loadKernel];
    
}

/**
 Creates a new place and adds it to the manager
 @param label
    The label of the new place 
 */
- (void) addContext: (NSString*) label {
    [manager addPlaceWithName:label];
    [self loadKernel];
}

/**
 Creates a new transition and adds it to the manager
 @param label
    The label of the new transition
 */
- (void) addTransition: (NSString*) label {
    PNTransition *newTrans = [[PNTransition alloc] initWithName:label];
    [manager addTransition:newTrans];
    [self loadKernel];
}

/**
 Occurs when a PNEPlaceView receives a tap touch event.
 This method is located at this level since
 a tap might influence the entire petri net (when adding arcs)
 */
- (void) placeTapped: (PNEPlaceView*) place {
    if (isAddingArc) {
        
        //Deselect a place
        if (arcPlace == place) {
            arcPlace = NULL;
            return [place dim];
        }
        
        [arcPlace dim];
        [place highlight];
        arcPlace = place;
        
        if (arcTrans != NULL)
            [self finishAddingArc:FALSE];
    }
    else [place toggleHighlightStatus];
}

/**
 Occurs when a PNETRansitionView receives a tap touch event.
 This method is located at this level since
 a tap might influence the entire petri net (when adding arcs)
 */
- (void) transitionTapped: (PNETransitionView*) trans {
    if (isAddingArc) {
        
        if (arcTrans == trans) {
            arcTrans = NULL;
            return [trans dim];
        }
        
        [arcTrans dim];
        [trans highlight];
        arcTrans = trans;
        
        if (arcPlace != NULL)
            [self finishAddingArc:TRUE];
    }
}

/** 
 Returns a UIImage of the PNEView
 @return The UIImage representation of the PNEView
 */
- (UIImage *) getPetriNetImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, [[UIScreen mainScreen] scale]);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *pnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return pnImage;
}

#pragma mark - Help functions

/**
 Dims all the nodes of the PNEView
 */
- (void) dimNodes {
    for (PNENodeView *node in places) {
        [node dim];
    }
    for (PNENodeView *node in transitions) {
        [node dim];
    }
}

#pragma mark - Kernel converting

/**
 This function creates the view counterpart of the PNManager.
 Every PNPlace and PNTransition get a View counterpart, most of the 
 work of loading the kernel is done while initialising the PNEPlaceView and PNETransitionView.
 
 @see PNEPlaceView#initWithValues:superView:
 @see PNETransitionView#initWithValues:superView:

 */
- (void) loadKernel {
    [arcs removeAllObjects];
    [places removeAllObjects];
    [transitions removeAllObjects];
    [collections removeAllObjects];
    
    for (PNPlace* place in manager.places) {
        [[PNEPlaceView alloc] initWithElement:place andSuperView:self];
    }
    for (PNPlace* place in manager.temporaryPlaces) {
        [[PNEPlaceView alloc] initWithElement:place andSuperView:self];
    }
    for (PNTransition* trans in manager.transitions) {
        [[PNETransitionView alloc] initWithElement:trans andSuperView:self];
    }
    
    for (PNEPlaceView* place in places) {
        if ([place.element class] == [PNContextPlace class])
            [[PNEContextCollection alloc] initWithContextPlace:place andView:self];
    }
    
    [self refreshPositions];
}

/**
 Updates the token arrays of every PNEPlaceView.
 This is generally used after firing a transition.
 */
- (void) updatePlaces {
    for (PNEPlaceView* place in places) {
        [place updatePlace];
    }
    [self setNeedsDisplay];
}

#pragma mark - Drawing Code

/**
 Ensures that no PNENodeView is out of bounds
 This is mainly used after rotating the device
 */
- (void) checkPositions {
    for (PNEPlaceView *place in places) {
        [place moveNode:CGPointMake(place.xOrig, place.yOrig)];
    }
    for (PNETransitionView *trans in transitions) {
        [trans moveNode:CGPointMake(trans.xOrig, trans.yOrig)];
    }
    [self setNeedsDisplay];
}

/**
 Positions a PNENodeView in the PNEView.
 @param position
    The location where we place the node
 @param node
    The PNENodeView we will place.
 */
- (void) placeNode: (PNENodeView*) node  withPosition: (CGPoint*) position {    
    if (position->x + node.dimensions > self.bounds.size.width) {
        position->x = START_OFFSET_X;
        position->y += 100;
    }
    [node moveNode:*position];
}

/**
 Redraws the entire Petri Net, this resets positions of non-new elements
 */
- (void) resetPositions {
    [self updatePositions:true];
}

/**
 Redraws the entire Petri Net without moving non-new elements
 */
- (void) refreshPositions {
    [self updatePositions:false];
}

/**
 This is the method that actually moves around the elements.
 Places are all put on one or more rows.
 Afterwards the same thing is done for the transitions.
 
 @param shouldReset
    If true every element is repositioned.
    If not all elements keep their positions and
    only new elements are moved to a location.
 */
- (void) updatePositions: (BOOL) shouldReset {
    //Remove all locations
    if (shouldReset) {
        currentLocation = CGPointMake(START_OFFSET_X, START_OFFSET_Y);
        for (PNENodeView* node in [places arrayByAddingObjectsFromArray:transitions]) {
            node.hasLocation = false;
        }
    }
    
    //Place all the contexts
    for (PNEContextCollection *collection in collections) {
        if (!collection.contextPlace.hasLocation) {
            [collection placeContext: currentLocation];
            currentLocation.y += Y_NODE_DISTANCE + [collection getHeight];
        }
    }
    
    //Place all the elements not part of a context
    for (PNENodeView* node in [places arrayByAddingObjectsFromArray:transitions]) {
        if (!node.hasLocation) {
            [self placeNode:node withPosition:&currentLocation];
            currentLocation.x += X_NODE_DISTANCE;
        }
    }
    [self setNeedsDisplay];
}

/**
 This method is called by the system when the drawing phase starts.
 The drawing phase can be started programatically by calling setNeedsDisplay.
 */
- (void)drawRect:(CGRect)rect {
    [contextInformation clearText];
    
    for (PNEPlaceView* place in places) {
        [place drawNode];
    }
    for (PNETransitionView* transition in transitions) {
        [transition drawNode];
    }
    for (PNEArcView* arc in arcs) {
        [arc drawArc];
    }
}

@end
