//
//  NESLoadable.h
//  NESEmulator
//
//  Created by Cosme Jordan on 29.08.21.
//

#ifndef NESLoadable_h
#define NESLoadable_h

@protocol NESLoadable <NSObject>
@required
- (void)loadNES;
@end


#endif /* NESLoadable_h */
