//
//  PNParser.h
//  Petri Net Editor
//
//  Created by Mathijs Saey on 9/05/12.
//  Copyright (c) 2012 Vrije Universiteit Brussel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "kernel/PNManager.h"

/**
 This class reads a subjective C context declaration
 and adds it to the kernel.
 */
@interface PNParser : NSObject {
    PNManager* manager;
    enum PNParserState state;
    
    /**
     This enumeration represents the parser state
     */ 
    enum PNParserState {
        END_STATE = -1, /**< The parser doesn't accept anymore input in this state */
        NO_STATE = 0, /**< The parser waits for the parsing contexts state to begin in this state */
        PARSING_CONTEXTS = 1, /**< Contexts can be added in this state */
        PARSING_LINKS = 2 /**< Links between contexts can be added in this state */
    };
}

- (void) parse: (NSString*) contextDeclaration;

@end