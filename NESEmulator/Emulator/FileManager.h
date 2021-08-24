//
//  FileReader.h
//  NESEmulator
//
//  Created by Cosme Jordan on 23.08.21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileManager : NSObject

- (NSString*)readFileFromBundle:(NSString*)fileName type:(NSString*)type;
- (NSString*)readFile:(NSString*)filePath;
- (void)writeFileToBundle:(NSString*)fileName content:(NSString*)content;
- (void)writeToFile:(NSString*)fileName content:(NSString*)content
               path:(NSString*)path type:(NSString*)type;

- (void)writeToFile:(NSString*)filePath content:(NSString*)content;


- (NSArray*)separateLines:(NSString*)fileName;
- (NSArray*)getOpcodeWrappers;

-(void)dumpContent:(NSString*)content;
-(void)dumpArray:(NSString*)content path:(NSString*)path;


@end

NS_ASSUME_NONNULL_END
