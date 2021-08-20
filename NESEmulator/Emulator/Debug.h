//
//  Debug.h
//  NESEmulator
//
//  Created by Cosme Jordan on 20.08.21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum DebuggingModes {
    DRun,
    DPause,
    DStep
} DModes;

static DModes dMode;
@interface Debug : NSObject



@end

NS_ASSUME_NONNULL_END
