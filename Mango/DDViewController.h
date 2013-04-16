//
//  DDViewController.h
//  Colorific
//
//  Created by Dylan Drop on 12/25/12.
//  Copyright (c) 2012 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "UICoordButton.h"
#import "Synth.h"
#import "MHAudioBufferPlayer.h"
@interface DDViewController : UIViewController
- (IBAction)changeColor:(id)sender;
- (IBAction)changeColor2:(id)sender;
- (void)setUpAudioBufferPlayer;
- (void)loopThroughGrid:(NSNumber *)col;
@end
