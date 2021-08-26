//
//  FileReader.h
//  NESEmulator
//
//  Created by Cosme Jordan on 23.08.21.
//

#import <Foundation/Foundation.h>
#import "../Utils.h"
NS_ASSUME_NONNULL_BEGIN

typedef struct {
    NSData* data;
    NES_u8* bytePtr;
    NSInteger size;
} ByteArray;

@interface FileManager : NSObject

- (NSString*)readFileFromBundle:(NSString*)fileName type:(NSString*)type;
- (NSString*)readFile:(NSString*)filePath;
- (ByteArray)readFileBytes:(NSString*)fileName type:(NSString*)type;


- (void)writeFileToBundle:(NSString*)fileName content:(NSString*)content;
- (void)writeToFile:(NSString*)fileName content:(NSString*)content
               path:(NSString*)path type:(NSString*)type;

- (void)writeToFile:(NSString*)filePath content:(NSString*)content;




- (NSArray*)separateLines:(NSString*)fileName;
- (NSArray*)getOpcodeWrappers;
- (NSArray*)getPalette:(NSString*)fileName;

-(void)dumpContent:(NSString*)content;
-(void)dumpArray:(NSString*)content path:(NSString*)path;


@end

NS_ASSUME_NONNULL_END
