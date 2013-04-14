//
//  UICoordButton.m
//  Colorific
//
//  Created by Dylan Drop on 4/14/13.
//  Copyright (c) 2013 Columbia University. All rights reserved.
//

#import "UICoordButton.h"

@implementation UICoordButton
@synthesize i,j;

- (void)setCoordsWithI:(int)i_coord J:(int)j_coord {
    i = i_coord;
    j = j_coord;
}

- (int)getI {
    return i;
}

- (int)getJ {
    return j;
}
@end
