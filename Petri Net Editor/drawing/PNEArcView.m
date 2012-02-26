//
//  PNEArcView.m
//  Petri Net Editor
//
//  Created by Mathijs Saey on 20/02/12.
//  Copyright (c) 2012 Vrije Universiteit Brussel. All rights reserved.
//

#import "PNEArcView.h"

@implementation PNEArcView

- (id) initWithValues: (PNArcInscription*) pnElement superView: (PNEView*) view {
    if (self = [super initWithValues:pnElement superView:view]) 
    {
        if ([pnElement flowFunction] == INHIBITOR)
            isInhibitor = TRUE;
        else isInhibitor = FALSE;}
    return self;
}

- (void) drawLine: (CGContextRef) context startpoint: (CGPoint) startPoint endPoint: (CGPoint) endPoint {
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, LINE_WIDTH);
    CGContextStrokePath(context);
}

- (CGRect) createRect: (CGContextRef) context lineStart: (CGPoint) lineStart lineStop: (CGPoint) lineStop {
    
}


- (void) drawStandardArc: (CGPoint) startPoint endPoint: (CGPoint) endPoint {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat lineEndPointX;
    CGFloat lineEndPointY;
    
    //if (startPoint.x - endPoint.x > 0
    
    [self drawLine:context startpoint:startPoint endPoint:endPoint];
    
    //Draw the arrow
    }

- (void) drawInhibitorArc: (CGPoint) startPoint endPoint: (CGPoint) endPoint {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawLine:context startpoint:startPoint endPoint:endPoint];
    
    
}

//Checks which arc drawing function to call
- (void) checkArcType: (CGPoint) startPoint endPoint: (CGPoint) endPoint {
    if (isInhibitor)
        [self drawInhibitorArc:startPoint endPoint:endPoint];
    else [self drawStandardArc:startPoint endPoint:endPoint];    
}

//Calculates the start and end points of the arc
- (void) calculateAttachmentPoints {
    if ([fromNode isLeftAndHigher:toNode])
        return [self checkArcType:[fromNode getLeftTopPoint] endPoint:[toNode getRightBottomPoint]];
    if ([fromNode isLeftAndLower:toNode])
        return [self checkArcType:[fromNode getLeftBottomPoint] endPoint:[toNode getRightTopPoint]];
    if ([fromNode isRightAndHigher:toNode])
        return [self checkArcType:[fromNode getRightTopPoint] endPoint:[toNode getLeftBottomPoint]];
    if ([fromNode isRightAndLower:toNode])
        return [self checkArcType:[fromNode getRightBottomPoint] endPoint:[toNode getLeftTopPoint]];
    
    
    if ([fromNode isLeft:toNode])
        return [self checkArcType:[fromNode getLeftEdge] endPoint:[toNode getRightEdge]];
    if ([fromNode isRight:toNode])
        return [self checkArcType:[fromNode getRightEdge] endPoint:[toNode getLeftEdge]];
    if ([fromNode isLower:toNode])
        return [self checkArcType:[fromNode getBottomEdge] endPoint:[toNode getTopEdge]];
    if ([fromNode isHigher:toNode])
        return [self checkArcType:[fromNode getTopEdge] endPoint:[toNode getBottomEdge]];
    
    NSLog(@"CalculateAttachmentPoints (PNEArcView )could not find a suitable attachement point");
}

//Draws the arc without updating the from and to members
- (void) reDrawArc {
    [self calculateAttachmentPoints];
}

- (void) drawArc: (PNENodeView*) from transition: (PNENodeView*) to {
    
    fromNode = from;
    toNode = to;
    [self calculateAttachmentPoints];   
}

@end
