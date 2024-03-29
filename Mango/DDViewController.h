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
- (void)setUpAudioBufferPlayer;
- (void)loopThroughGrid:(NSNumber *)col;
- (IBAction)changeWaveType:(id)sender;
- (IBAction)setMinorScale:(id)sender;
- (IBAction)setMajorScale:(id)sender;
- (IBAction)setPentatonicScale:(id)sender;
- (IBAction)setTempo:(id)sender;
@end
