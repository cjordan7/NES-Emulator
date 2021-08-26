//
//  FileReader.m
//  NESEmulator
//
//  Created by Cosme Jordan on 23.08.21.
//

#import "FileManager.h"
#import "OpcodeWrapper.h"

@implementation FileManager

- (NSString*)readFileFromBundle:(NSString*)fileName type:(NSString*)type {
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:type];

    NSError* error;
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    @try {
        if(error) {
            @throw error;
        }
    } @catch(id e) {
        // TODO: Error message: pop up
        [error localizedDescription];
        [NSException raise:@"The file doesn't exist"
                    format:@"Inexistent file %@. ", path];
    }

    return content;
}

- (NSString*)readFile:(NSString*)filePath {
    return  [NSString stringWithContentsOfFile:filePath
                                      encoding:NSUTF8StringEncoding error:nil];
}

- (ByteArray)readFileBytes:(NSString*)fileName type:(NSString*)type {
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:type];

    NSData* data = [NSData dataWithContentsOfFile:path];
    uint8_t* bytePtr = (NES_u8*)[data bytes];
    NSInteger size = [data length]/sizeof(NES_u8);
    ByteArray b = {data, bytePtr, size};
    return b;
}

- (NSArray*)getPalette:(NSString*)fileName {
    ByteArray byteArray = [self readFileBytes:fileName type:@".pal"];

    NSMutableArray* palette = [[NSMutableArray alloc] init];

    // TODO: handle !! byteArray == nil
    if(byteArray.size > 192) {
        // TODO: Warning in debug
        NSLog(@"Palette: Size of byte array (%ld)is bigger than 64.", (long)byteArray.size);
    }


    // NSLog
    uint32_t color = -1;
    for (int i = 0 ; i < 64*3; i += 3) {
        color = 0xFF < (3*8);
        uint32_t red = byteArray.bytePtr[i] << (0*8);
        uint32_t green = byteArray.bytePtr[i+1] << 8;
        uint32_t blue = byteArray.bytePtr[i+2] << (2*8);
        color |= red | green | blue;
        NSNumber* i = [NSNumber numberWithUnsignedInt:color];
        [palette addObject:i];
    }

    return [palette copy];
}


- (void)writeFileToBundle:(NSString*)fileName content:(NSString*)content {
    NSError* error;

    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"log"];
    [content writeToFile:filePath atomically:NO encoding:NSUTF8StringEncoding error:&error];
}

- (void)writeToFile:(NSString*)fileName
            content:(NSString*)content
               path:(NSString*)path
               type:(NSString*)type {
    NSString* pathExtended = [path stringByAppendingPathExtension:fileName];
    pathExtended = [pathExtended stringByAppendingPathExtension:type];
    [content writeToFile:pathExtended
              atomically:NO
                encoding:NSStringEncodingConversionAllowLossy
                   error:nil];
}

- (void)writeToFile:(NSString*)filePath content:(NSString*)content {

}

- (NSArray*)separateLines:(NSString*)fileContents {
    return [fileContents componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];

}

- (NSArray*)getOpcodeWrappers {
    NSMutableArray* tempReturn = [[NSMutableArray alloc] init];
    NSString* content = [self readFileFromBundle:@"OpcodeList" type:@""];

    NSArray* lines = [self separateLines:content];

    for(int i = 1; i < 257; ++i) {
        NSArray* temp = [self preprocess:lines[i]];
        Utility utility;
        utility.hex = temp[0];
        utility.intValue = [temp[1] integerValue];
        utility.name = temp[2];
        utility.functionName = [@"opcode" stringByAppendingString:temp[2]];
        utility.addressingModeName = temp[3];
        utility.addressingModeNameOfFunction = [self getAddressModeName: temp[3]];
        utility.syntax = temp[4];
        utility.lengthInBytes = [temp[5] integerValue];
        utility.numberOfCycles = [temp[6] integerValue];
        utility.additionalCycles =[temp[7] integerValue];

        OpcodeWrapper* opcodeWrapper = [[OpcodeWrapper alloc] init:utility];
        [tempReturn addObject: opcodeWrapper];
    }

    return [tempReturn copy];
}

-(NSString*)getAddressModeName:(NSString*)addressingMode {
    if([addressingMode isEqual:@"Accumulator"]) {
        return @"addressAccumulator";
    } else if([addressingMode isEqual:@"Implied"]) {
        return @"addressImplicit";
    } else if([addressingMode isEqual:@"Immediate"]) {
        return @"addressImmediate";
    } else if([addressingMode isEqual:@"Relative"]) {
        return @"addressRelative";
    } else if([addressingMode isEqual:@"Absolute"]) {
        return @"addressAbsolute";
    } else if([addressingMode isEqual:@"Absolute-X"]) {
        return @"addressAbsoluteX";
    } else if([addressingMode isEqual:@"Absolute-Y"]) {
        return @"addressAbsoluteY";
    } else if([addressingMode isEqual:@"Indirect"]) {
        return @"addressIndirect";
    } else if([addressingMode isEqual:@"Indirect-X"]) {
        return @"addressIndexedXIndirect";
    } else if([addressingMode isEqual:@"Indirect-Y"]) {
        return @"addressIndexedYIndirect";
    } else if([addressingMode isEqual:@"Zero Page"]) {
        return @"addressZero";
    } else if([addressingMode isEqual:@"Zero Page-X"]) {
        return @"addressZeroX";
    } else if([addressingMode isEqual:@"Zero Page-Y"]) {
        return @"addressZeroY";
    }

    NSError* error = nil;
    @throw error;
    return @"Problem";
}

-(NSArray*)preprocess:(NSString*)string {
    NSArray* array = [string componentsSeparatedByString:@"\t"];
    NSMutableArray* arrayReturn = [[NSMutableArray alloc] init];

    for(int i = 0; i < [array count]; ++i) {
        NSString* temp = [array[i] stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [arrayReturn addObject: temp];
    }

    return [arrayReturn copy];
}

-(void)dumpContent:(NSString*)content {
    [self dumpContent:content path:@__FILE__];
}

-(void)dumpContent:(NSString*)content path:(NSString*)path {
    [self writeToFile:@"" content:content path:path type:@"txt"];
}

-(void)dumpArray:(NSArray*)content path:(NSString*)path {
    NSString* content2 = [content componentsJoinedByString:@"\n"];
    [self writeToFile:@"dumped" content:content2 path:path type:@"txt"];
}


@end
