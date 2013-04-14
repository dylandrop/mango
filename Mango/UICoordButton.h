//
//  UICoordButton.h
//  Colorific
//
//  Created by Dylan Drop on 4/14/13.
//  Copyright (c) 2013 Columbia University. All rights reserved.
//

@interface UICoordButton : UIButton 
{
    NSString *btnType;
}

@property (nonatomic, assign) int i;
@property (nonatomic, assign) int j;

- (void)setCoordsWithI:(int)i_coord J:(int)j_coord;
- (int)getI;
- (int)getJ;
@end
