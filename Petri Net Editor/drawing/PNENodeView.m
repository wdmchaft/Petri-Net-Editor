//
//  PNENodeView.m
//  Petri Net Editor
//
//  Created by Mathijs Saey on 20/02/12.
//  Copyright (c) 2012 Vrije Universiteit Brussel. All rights reserved.
//

#import "PNENodeView.h"
#import "PNEView.h"

@implementation PNENodeView

@synthesize xOrig, yOrig, label, dimensions, isMarked, hasLocation, collection;

#pragma mark - Lifecycle

/**
 This initialises the node and adds the standard touch responders.
 @see PNEViewElement#initWithValue:superView:
 */
- (id) initWithElement: (PNNode*) pnElement andSuperView: (PNEView*) view {
    if (self = [super initWithElement:pnElement andSuperView:view]) {
        
        //Check if the node already had a view
        if (pnElement.view != NULL) {
            hasLocation = true;
            dimensions = pnElement.view.dimensions;
            [self moveNode:CGPointMake(pnElement.view.xOrig, pnElement.view.yOrig)];
        }
        else hasLocation = false;

        //Add touch responders
        [self createTouchZone];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        UILongPressGestureRecognizer *hold = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongGesture:)];
        pan.maximumNumberOfTouches = 1; //Ensure it only responds to one finger panning.
        [self addTouchResponder:tap];
        [self addTouchResponder:pan];
        [self addTouchResponder:hold];
        
        [tap release];
        [pan release];
        [hold release];
        
        //Initialise the action sheet, 
        //we initialise the cancel button later so it appears at the bottom
        nodeOptions = [[UIActionSheet alloc] 
                       initWithTitle:NSLocalizedString(@"NODE_AS_TITLE", nil)  delegate:self 
                       cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedString(@"DELETE_BUTTON", nil)  
                       otherButtonTitles: NSLocalizedString(@"NODE_CHANGE_LABEL", nil) , nil];
        isMarked = false;
        label = [pnElement.label retain];
        pnElement.view = self;
    }
    return self;
}

- (void) dealloc {
    [nodeOptions release];
    [label release];
    [super dealloc];
}

/**
 Removes the touch zone,
 the actual removing is done 
 in PNETransitionView::removeElement and in
 PNEPlaceView::removeElement
 */
- (void) removeElement {
    [collection removeElement:self];
    [self removeTouchZone];
    [superView loadKernel];
}

#pragma mark - Touch logic

/**
 This method creates a touch rect
 @return
    A rectangle, the size depends on the
    node size and the TOUCH_EXTRA constant
 */
- (CGRect) createTouchRect {
    return CGRectMake(xOrig - TOUCH_EXTRA , yOrig - TOUCH_EXTRA, dimensions + TOUCH_EXTRA * 2, dimensions + TOUCH_EXTRA * 2);
}

/**
 Creates an area where the
 node can receive touch input
 */
- (void) createTouchZone {
    touchView = [[UIView alloc] initWithFrame:[self createTouchRect]];
    [superView addSubview:touchView];
    [touchView release];
}

/**
 Moves the touchZone to the
 current location of the PNENodeView
 */
- (void) updateTouchZone {
    touchView.frame = [self createTouchRect];
}

/**
 Deletes the touchzone from the superView
 */
- (void) removeTouchZone {
    [touchView removeFromSuperview];
}

/**
 Adds a gesture recognizer to the touchzone
 @param recognizer
    The new UIGestureRecognizer the touchzone should support
 */
- (void) addTouchResponder:(UIGestureRecognizer *)recognizer {
    [touchView addGestureRecognizer:recognizer];
}

#pragma mark Action handlers

/**
 Handles a tap gesture
 */
- (void) handleTapGesture:(UITapGestureRecognizer *)gesture {
    NSLog(@"Abstract version of handleTapGesture (PNENodeView) called");
}

/**
 Handles a long press on the node
 */
- (void) handleLongGesture: (UILongPressGestureRecognizer *) gesture {
    [nodeOptions showFromRect:touchView.bounds inView:touchView animated:true];
}

/**
 Handles a dragging motion, this moves around the node.
 */
- (void)handlePanGesture:(UIPanGestureRecognizer *) gesture {
    CGPoint tmp = [gesture locationInView:superView];
    [self moveNode:tmp];
    [superView setNeedsDisplay];
}

#pragma mark Option sheet methods

/**
 The system calls this function when the user presses an option
 on the actionsheet.
 This is responsible for the delete and changelabel buttons.
 
 @see PNETransitionView#actionSheet:clickedButtonAtIndex:
 @see PNEPlaceView#actionSheet:clickedButtonAtIndex:
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet buttonTitleAtIndex:buttonIndex] == NSLocalizedString(@"NODE_CHANGE_LABEL", nil)) {
        UIAlertView *popup = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NODE_NAME_TITLE", nil)
                                                        message:nil delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL_BUTTON", nil) 
                                              otherButtonTitles:NSLocalizedString(@"OK_BUTTON", nil) , nil];
        popup.alertViewStyle = UIAlertViewStylePlainTextInput;
        [popup textFieldAtIndex:0].placeholder = label;
        [popup show];
        [popup release];
    }
    
    else if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self removeElement];
    }
}

/**
 The system calls this when a button of the UIAlertView has been pressed
 This UIAlertView is used to change the label of the node if the "ok" button is pressed.
 */
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSString *newLabel = [alertView textFieldAtIndex:0].text;
        
        [superView.log addText:[NSString stringWithFormat:NSLocalizedString(@"LOG_CHANGE_LABEL", nil), label, newLabel]];
        
        [label release];
        [newLabel retain];
        label = newLabel;
        [element setLabel:newLabel];
        [superView setNeedsDisplay];
    }
}

#pragma mark - Highlight implementation

/**
 [abstract]Draws the highlight around a node.
 @see PNETransitionView#drawHighlight
 @see PNEPlaceView#drawHighlight
 */
- (void) drawHighlight {
    NSLog(@"Abstract version of drawHighlight (PNENodeView) called");
}

/**
 Changes the highlight status to on if it was off and vice versa
 */
- (void) toggleHighlightStatus {
    if (isMarked)
        [self dim];
    else [self highlight];
}

/**
 Highlights the node
 */
- (void) highlight {
    isMarked = true;
    [superView setNeedsDisplay];
}

/**
 Turns off the highlight.
 */
- (void) dim {
    isMarked = false;
    [superView setNeedsDisplay];
}

#pragma mark - Arc attachement point functions

/**
 Gets the middle top point of the node.
 */
- (CGPoint) getTopEdge {
    return CGPointMake(xOrig + (dimensions / 2) , yOrig);
}

/**
 Gets the middle of the left side of the node
 */
- (CGPoint) getLeftEdge {
    return CGPointMake(xOrig, yOrig + (dimensions / 2));
}

/**
 Gets the middle of the right side of the node
 */
- (CGPoint) getRightEdge {
    return CGPointMake(xOrig + dimensions, yOrig + (dimensions / 2));
}

/**
 Gets the middle of the bottom of the node
 */
- (CGPoint) getBottomEdge {
    return CGPointMake(xOrig + (dimensions / 2), yOrig + dimensions);
}

/**
 Gets the upper left point of the node
 */
- (CGPoint) getLeftTopPoint {
    return CGPointMake(xOrig, yOrig);
}

/**
 Gets the upper right point of the node
 */
- (CGPoint) getRightTopPoint {
    return CGPointMake(xOrig + dimensions, yOrig);
}

/**
 Gets the bottom left point of the node
 */
- (CGPoint) getLeftBottomPoint {
    return CGPointMake(xOrig, yOrig + dimensions);
}

/**
 Gets the bottom right point of the node.
*/
- (CGPoint) getRightBottomPoint {
    return CGPointMake(xOrig + dimensions, yOrig + dimensions);
}

/**
 Checks if a certain node lies below this node
 @return 
    true if the node lies lower then the self node
 */
- (BOOL) isLower: (PNENodeView*) node {
    return node.yOrig > yOrig + dimensions;
}

/**
 Checks if a certain node lies above this node
 @return 
    true if the node is higher then the self node
 */
- (BOOL) isHigher: (PNENodeView*) node {
    return node.yOrig + node.dimensions < yOrig;
}

/**
 Checks if a certain node lies to the left of this node
 @return 
    true if the node lies left of the self node
 */
- (BOOL) isLeft: (PNENodeView*) node {
    return node.xOrig + node.dimensions < xOrig;
}

/**
 Checks if a certain node lies to the right of this node
 @return 
    true if the node lies right of the self node
 */
- (BOOL) isRight: (PNENodeView*) node {
    return node.xOrig > xOrig + dimensions;
}

/**
 Checks if a node lies to the bottom left of this node
 @return 
    true if the node lies to the bottom left of the self node
 */
- (BOOL) isLeftAndLower: (PNENodeView*) node {
    return [self isLeft:node] && [self isLower:node];
}

/**
 Checks if a node lies to the bottom right of this node
 @return 
    true if the node lies to the bottom right of the self node
 */
- (BOOL) isRightAndLower: (PNENodeView*) node {
    return [self isRight:node] && [self isLower:node];
}

/**
 Checks if a node lies to the top left of this node
 @return 
    true if the node lies to the top left of the self node
 */
- (BOOL) isLeftAndHigher: (PNENodeView*) node {
    return [self isLeft:node] && [self isHigher:node];
}

/**
 Checks if a node lies to the top right of this node
 @return 
    true if the node lies to the top right of the self node
 */
- (BOOL) isRightAndHigher: (PNENodeView*) node {
    return [self isRight:node] && [self isHigher:node];
}

#pragma mark - Help functions

/**
 Checks if a node overlaps
 @param node
    The node that may overlap
 @return 
    true if the node overlaps with the self node
 */
- (BOOL) doesOverlap: (PNENodeView*) node {
    return 
    //Check if the origin of the node lies within the current node's rectangle
    (xOrig <= node.xOrig && node.xOrig <= xOrig + dimensions &&
    yOrig <= node.yOrig && node.yOrig <= yOrig + dimensions)
    || //Check if the origin of the current node lies within the node's rectangle
    (node.xOrig <= xOrig && xOrig <= node.xOrig + node.dimensions &&
    node.yOrig <= yOrig && yOrig <= node.yOrig + node.dimensions);
}

/**
 Changes the dimension of the node
 @param multiplier
 A multiplier that decides how the node scales
 */
- (void) multiplyDimension:(CGFloat)multiplier {
    dimensions = dimensions * multiplier;
}

#pragma mark - Drawing code

/**
 Draws the node
 */
- (void) drawNode {
    [self drawLabel];
    if (isMarked)
        [self drawHighlight];
}

/**
 Moves the node to a new position.
 @param origin
 the position to move the node to.
 */
- (void) moveNode: (CGPoint) origin {
    //checks if the node does not go out of bounds
    if (origin.x + dimensions > superView.bounds.size.width)
        origin.x = superView.bounds.size.width - dimensions;
    if (origin.y + dimensions > superView.bounds.size.height)
        origin.y = superView.bounds.size.height - dimensions;
    if (origin.y < 0)
        origin.y = 0;
    if (origin.x < 0)
        origin.x = 0;
    
    xOrig = origin.x;
    yOrig = origin.y;
    
    hasLocation = true;
    [self updateTouchZone];
}

/**
 draws the label of the node.
 */
- (void) drawLabel {
    if (!superView.showLabels)
        return;
    
    //Prepare the text
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSelectFont(context, MAIN_FONT_NAME, MAIN_FONT_SIZE, kCGEncodingMacRoman);
    
    //Prepare the string
    NSUInteger textLength = [label length];
    const char *labelText = [label cStringUsingEncoding: [NSString defaultCStringEncoding]];
    
    //Inverse the text to makeup for the difference between the uikit and core graphics coordinate systems
    CGAffineTransform flip = CGAffineTransformMakeScale(1, -1);
    CGContextSetTextMatrix(context, flip);
    
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextShowTextAtPoint(context, [self getRightEdge].x + LABEL_DISTANCE , [self getRightEdge].y - LABEL_DISTANCE  , labelText, textLength);
}

@end
