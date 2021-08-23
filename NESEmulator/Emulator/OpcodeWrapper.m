//
//  OpcodeWrapper.m
//  NESEmulator
//
//  Created by Cosme Jordan on 23.08.21.
//

#import "OpcodeWrapper.h"

@interface OpcodeWrapper()

@end

@implementation OpcodeWrapper

-(instancetype)init:(Utility)utility {
    if(self = [super init]) {
        _name = utility.name;
        _functionName = utility.functionName;
        _hex = utility.hex;
        _intValue = utility.intValue;
        _addressingModeName = utility.addressingModeName;
        _addressingModeNameOfFunction = utility.addressingModeNameOfFunction;
        _syntax = utility.syntax;
        _lengthInBytes = utility.lengthInBytes;
        _numberOfCycles = utility.numberOfCycles;
        _additionalCycles = utility.additionalCycles;
    }
    
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat:
            @"%@, %d, %@,"
            "%@, %@, %@, %@, %d, %d, %d",
            self.hex,
            self.intValue,
            self.name,
            self.functionName,
            self.addressingModeName,
            self.addressingModeNameOfFunction,
            self.syntax,
            self.lengthInBytes,
            self.numberOfCycles,
            self.additionalCycles
            ];
}

@end
