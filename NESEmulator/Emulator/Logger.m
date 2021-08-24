//
//  Logger.m
//  NESEmulator
//
//  Created by Cosme Jordan on 24.08.21.
//

#import "Logger.h"

@interface Logger()

@end

@implementation Logger
static NSMutableArray* fullLog;

static NSMutableArray* infoLog;
static NSMutableArray* debugLog;
static NSMutableArray* errorLog;
static NSMutableArray* warningLog;
static NSMutableArray* opcodeLog;


+ (void)logMessage:(NSString*)message
             level:(Level)level
              file:(const char *)file
          function:(const char *)function
              line:(NSUInteger)line {
    NSString* temp = [NSString stringWithFormat:
                        @"File: %s, Function: %s,"
                        "Line: %lu, Message: %@",
                        file,
                        function,
                        line,
                        message];

    [fullLog addObject:temp];
    switch(level) {
        case info:
            [infoLog addObject:temp];
            break;
        case debug:
            [debugLog addObject:temp];
            break;
        case error:
            [errorLog addObject:temp];
            break;
        case warning:
            [warningLog addObject:temp];
            break;
        case opcode:
            [opcodeLog addObject:temp];
            break;
    }
}

+ (void)dump {

}

@end
