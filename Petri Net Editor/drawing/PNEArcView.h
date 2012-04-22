//
//  PNEArcView.h
//  Petri Net Editor
//
//  Created by Mathijs Saey on 20/02/12.
//  Copyright (c) 2012 Vrije Universiteit Brussel. All rights reserved.
//

#import "../kernel/PNArcInscription.h"
#import "../PNEConstants.h"

#import "PNEViewElement.h"
#import "PNENodeView.h"


@interface PNEArcView : PNEViewElement <UIActionSheetDelegate> {
    BOOL isInhibitor;
    int weight;
    
    PNENodeView *fromNode;
    PNENodeView *toNode;
    
    CGPoint startPoint;
    CGPoint endPoint;
    
    UIActionSheet *options;
    NSMutableArray *touchViews;
}

- (void) drawArc;
- (void) setNodes: (PNENodeView*) newFromNode toNode: (PNENodeView*) newToNode;
- (void) handleLongGesture: (UILongPressGestureRecognizer *) gesture;


@end
