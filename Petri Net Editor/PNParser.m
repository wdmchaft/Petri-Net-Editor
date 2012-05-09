//
//  PNParser.m
//  Petri Net Editor
//
//  Created by Mathijs Saey on 9/05/12.
//  Copyright (c) 2012 Vrije Universiteit Brussel. All rights reserved.
//

#import "PNParser.h"

@implementation PNParser

- (id) init {
    if (self = [super init]) {
        manager = [PNManager sharedManager];
        state = NO_STATE;
    }
    return self;
}

#pragma mark - Help methods

/**
 This method prints an error
 when something goes wrong during 
 the parsing of the .sc file.
 @param errorMessage
    The message to present to the user
 */
- (void) printError: (NSString*) errorMessage {
    state = END_STATE;
    UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"A parsing error occured:" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [error show];
}

/**
 This method removes all the spaces 
 at the start and end of a string.
 @param string
    The string that needs to be edited
 @return
    The string without spaces in front or behind it
 */
- (NSString*) removeSpaces: (NSString*) string {
    while ([string hasPrefix:@" "]) {
        string = [string substringFromIndex:1];
    }
    while ([string hasSuffix:@" "]) {
        string = [string substringToIndex:[string length] - 1];
    }
    return string;
}

/**
 This method looks for spaces in a string
 @param string
    The string that could contain spaces
 @return 
 */
- (BOOL) containsSpaces: (NSString*) string {
    NSRange spaceLoc = [string rangeOfString:@" "];
    return spaceLoc.location != NSNotFound;
}

#pragma mark - Parse functionality

/**
 This method starts the parsing,
 it simply calls parseline for each line
 
 @param contextDeclaration
    The full contextDeclaration string to parse
 */
- (void) parse: (NSString*) contextDeclaration {    
    for (NSString *line in [contextDeclaration componentsSeparatedByString:@"\n"]) {
        if (state == END_STATE) return;
        [self parseLine:line];
    } 
}

/**
 This method parses a single line of the 
 contextdeclaration, it checks for comments,
 empty lines and new state identifiers.
 Afterwards it passes on the line to the 
 responsible method.
 
 @param line the line to parse
 */
- (void) parseLine: (NSString*) line {
    //Filter out the comments
    NSRange commentRange = [line rangeOfString:@"#"];
    if (commentRange.location != NSNotFound) {
        commentRange.length = commentRange.length - 1;
        line = [line substringToIndex:commentRange.location];
    }
    
    //Filter out the empty lines
    if([line isEqualToString:@""]) return;
    
    //See if the state should be changed
    if ([self checkStateChange:line]) return;

    switch (state) {
        case NO_STATE:
            [self parseNoState:line];
            break;
        case PARSING_CONTEXTS:
            [self parseContext:line];
            break;
        case PARSING_LINKS:
            [self parseLink:line];
            break;
        case END_STATE:
            return;
            break;
        default:
            [self printError:@"An internal error occured in parseLine, no matching state found!"];
            break;
    }
    
}

/**
 This method checks for lines that change the 
 state of the parser.
 
 @param line
    The line to check
 @return
    True if the state changed, false if it didn't
 */
- (BOOL) checkStateChange: (NSString*) line {
    if ([line isEqualToString:@"Contexts:"]) state = PARSING_CONTEXTS;
    else if ([line isEqualToString:@"Links:"]) state = PARSING_LINKS;
    else if ([line isEqualToString:@"END"]) state = END_STATE;
    else return false;
    return true;
}

/**
 Parses a line when the parser is in the 
 NO_STATE.
 @param line
    The line to be parsed.
 */
- (void) parseNoState: (NSString*) line {
    [self printError:[NSString stringWithFormat:@"File must begin with 'Contexts:' instead of '%@'", line]];
}

/**
 Parses a line when the parser is in the 
 PARSING_CONTEXTS state.
 @param line
    The line to be parsed.
 */
- (void) parseContext: (NSString*) line {
    NSArray *components = [line componentsSeparatedByString:@","];
    
    //Standard context creation
    if ([components count] == 1) {
        line = [self removeSpaces:line];
        if ([self containsSpaces:line]) {
            [self printError:[NSString stringWithFormat:@"A context name cannot contain spaces! %@", line]];
            return;
        }
        [manager addPlaceWithName:line];
    }
    //Context with capacity
    else if ([components count] == 2) {
        NSString *contextName = [components objectAtIndex:0];
        NSString *contextCapacity = [components objectAtIndex:1];

        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        NSNumber *capacity = [formatter numberFromString:contextCapacity];
        [formatter release];
        
        if (capacity == nil) {
            [self printError:[NSString stringWithFormat:@"Syntax error in context capacity! '%@' should be a number", contextCapacity]];
            return;  
        }
        if ([self containsSpaces:contextName]) {
            [self printError:[NSString stringWithFormat:@"A context name cannot contain spaces! '%@'", contextName]];
            return;
        }
        
        [manager addPlaceWithName:contextName AndCapacity:[capacity intValue]];
        
    }
    
    else [self printError:[NSString stringWithFormat:@"Too many ',' in context declaration! '%@'", line]];

    
}

/**
 Parses a line when the parser is in the 
 PARSING_LINKS state.
 @param line
 The line to be parsed.
 */
- (void) parseLink: (NSString*) line {
    NSLog([NSString stringWithFormat:@"Parsing link: %@", line]);
}

@end