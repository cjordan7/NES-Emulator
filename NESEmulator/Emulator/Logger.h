//
//  Logger.h
//  NESEmulator
//
//  Created by Cosme Jordan on 24.08.21.
//

#import <Foundation/Foundation.h>
#import "FileManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, Level) {
    info,
    debug,
    error,
    warning,
    opcode
};
static int i;
@interface Logger : NSObject

+ (void)logMessage:(NSString*)message
             level:(Level)level
              file:(const char *)file
          function:(const char *)function
              line:(NSUInteger)line;

+ (void)dump;

@end

NS_ASSUME_NONNULL_END
