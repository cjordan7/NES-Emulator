//
//  OpcodeWrapper.h
//  NESEmulator
//
//  Created by Cosme Jordan on 23.08.21.
//

#import <Foundation/Foundation.h>
#import "../Utils.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    NSString* name;
    NSString* functionName;
    NSString* hex;
    NES_u8 intValue;
    NSString* addressingModeName;
    NSString* addressingModeNameOfFunction;
    NSString* syntax;
    NES_u8 lengthInBytes;
    NES_u8 numberOfCycles;
    NES_u8 additionalCycles;
} Utility;

@interface OpcodeWrapper : NSObject

@property(nonatomic, strong, readonly) NSString* name;
@property(nonatomic, strong, readonly) NSString* functionName;
@property(nonatomic, strong, readonly) NSString* hex;
@property(nonatomic, assign, readonly) NES_u8 intValue;
@property(nonatomic, strong, readonly) NSString* addressingModeName;
@property(nonatomic, strong, readonly) NSString*addressingModeNameOfFunction;
@property(nonatomic, strong, readonly) NSString* syntax;
@property(nonatomic, assign, readonly) NES_u8 lengthInBytes;
@property(nonatomic, assign, readonly) NES_u8 numberOfCycles;
@property(nonatomic, assign, readonly) NES_u8 additionalCycles;


- (instancetype)init:(Utility)utility;
@end

NS_ASSUME_NONNULL_END
