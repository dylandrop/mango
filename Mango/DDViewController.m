//
//  DDViewController.m
//  Colorific
//
//  Created by Dylan Drop on 12/25/12.
//  Copyright (c) 2012 Columbia University. All rights reserved.
//

#import "DDViewController.h"

@implementation DDViewController
{
	MHAudioBufferPlayer *_player;
	Synth *_synth;
	NSLock *_synthLock;
    bool KEEP_PLAYING;
    bool tones[8][8];
}
int scale[8] = {60,62,64,65,67,69,71,72};

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    KEEP_PLAYING = true;
    self.view.backgroundColor = [UIColor colorWithRed:193.0f/255.0f green:194.0f/255.0f blue:196.0f/255.0f alpha:1.0];
    CGFloat width = [UIScreen mainScreen].bounds.size.width / 8;
    [self setUpAudioBufferPlayer];
    for (int y=0; y < 8; y++) {
        for (int x = 0; x < 8; x++) {
            UICoordButton * button = [UICoordButton buttonWithType:UIButtonTypeCustom];
            [button setCoordsWithI:y J:x];
            button.frame = CGRectMake(width * x, width * y, width, width);
            [[button layer] setBorderWidth:1.0f];
            [[button layer] setBorderColor:[UIColor colorWithRed:193.0f/255.0f green:194.0f/255.0f blue:196.0f/255.0f alpha:1.0].CGColor];
            
            unsigned buttonNumber = y * 9 + x + 1;
            button.tag = buttonNumber;
            
            button.backgroundColor = [UIColor colorWithRed:35.0f/255.0f green:31.0f/255.0f blue:32.0f/255.0f alpha:1.0];
            
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:(UIControlEventTouchUpInside)];
            [self.view addSubview: button];
        }
    }
    [self loopThroughGrid:0];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)loopThroughGrid:(NSNumber *)col
{
    int number = [col intValue];
    NSMutableArray *buttons= [[NSMutableArray alloc]initWithObjects: nil];
    if(KEEP_PLAYING) {
        for(int i = 0; i < 8; i++) {
            if(tones[i][number]) {
                [_synthLock lock];
                
                // The tag of each button corresponds to its MIDI note number.
                int midiNote = scale[7-i];
                
                int tag = i * 9 + number + 1;
                UIButton *button = (UIButton *)[self.view viewWithTag:tag];
                [buttons addObject:button];
                button.backgroundColor = [UIColor colorWithRed:193.0f/255.0f green:194.0f/255.0f blue:196.0f/255.0f alpha:1.0];
                [_synth playNote:midiNote];
                
                [_synthLock unlock];
            }
        }
    }
    int temp = (number + 1) % 8;
    [self performSelector:@selector(loopThroughGrid:) withObject:[NSNumber numberWithInt:(temp)] afterDelay:(0.5)];
    [self performSelector:@selector(releaseButtons:) withObject:buttons afterDelay:(0.5)];
}

- (void)releaseButtons:(NSMutableArray *)buttons
{
    for (UICoordButton *button in buttons){
        if(!tones[[button getI]][[button getJ]]){
            [button setBackgroundColor:[UIColor colorWithRed:35.0f/255.0f green:31.0f/255.0f blue:32.0f/255.0f alpha:1.0]];
        }
        else {
            [button setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:187.0f/255.0f blue:226.0f/255.0f alpha:1.0]];
        }
    }
    [buttons removeAllObjects];
}

- (void)setUpAudioBufferPlayer
{
    // We need a lock because we update the Synth's state from the main thread
	// whenever the user presses a button, but we also read its state from an
	// audio thread in the MHAudioBufferPlayer callback. Doing both at the same
	// time is a bad idea and the lock prevents that.
	_synthLock = [[NSLock alloc] init];
    
	// The Synth and the MHAudioBufferPlayer must use the same sample rate.
	// Note that the iPhone is a lot slower than a desktop computer, so choose
	// a sample rate that is not too high and a buffer size that is not too low.
	// For example, a buffer size of 800 packets and a sample rate of 16000 Hz
	// means you need to fill up the buffer in less than 0.05 seconds. If it
	// takes longer, the sound will crack up.
	float sampleRate = 16000.0f;
    
	_synth = [[Synth alloc] initWithSampleRate:sampleRate];
    
	_player = [[MHAudioBufferPlayer alloc] initWithSampleRate:sampleRate
													 channels:1
											   bitsPerChannel:16
											 packetsPerBuffer:1024];
	_player.gain = 0.9f;
    
	__block __weak DDViewController *weakSelf = self;
	_player.block = ^(AudioQueueBufferRef buffer, AudioStreamBasicDescription audioFormat)
	{
		DDViewController *blockSelf = weakSelf;
		if (blockSelf != nil)
		{
			// Lock access to the synth. This callback runs on an internal
			// Audio Queue thread and we don't want to allow any other thread
			// to change the Synth's state while we're still filling up the
			// audio buffer.
			[blockSelf->_synthLock lock];
            
			// Calculate how many packets fit into this buffer. Remember that a
			// packet equals one frame because we are dealing with uncompressed
			// audio; a frame is a set of left+right samples for stereo sound,
			// or a single sample for mono sound. Each sample consists of one
			// or more bytes. So for 16-bit mono sound, each packet is 2 bytes.
			// For stereo it would be 4 bytes.
			int packetsPerBuffer = buffer->mAudioDataBytesCapacity / audioFormat.mBytesPerPacket;
            
			// Let the Synth write into the buffer. The Synth just knows how to
			// fill up buffers in a particular format and does not care where
			// they come from.
			int packetsWritten = [blockSelf->_synth fillBuffer:buffer->mAudioData frames:packetsPerBuffer];
            
			// We have to tell the buffer how many bytes we wrote into it. 
			buffer->mAudioDataByteSize = packetsWritten * audioFormat.mBytesPerPacket;	
            
			[blockSelf->_synthLock unlock];
		}
	};
    
	[_player start];
}

- (void)viewDidUnload
{
    KEEP_PLAYING = false;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)buttonPressed:(UICoordButton *)button {
    if(tones[[button getI]][[button getJ]]){
        [button setBackgroundColor:[UIColor colorWithRed:35.0f/255.0f green:31.0f/255.0f blue:32.0f/255.0f alpha:1.0]];
    }
    else {
        [button setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:187.0f/255.0f blue:226.0f/255.0f alpha:1.0]];
    }
    tones[[button getI]][[button getJ]] = tones[[button getI]][[button getJ]] ? false : true;
}

- (IBAction)changeWaveType:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if([[segmentedControl titleForSegmentAtIndex:segmentedControl.selectedSegmentIndex] isEqualToString:@"Square"]) {
        [_synth buildSquareTable];
    }
    else {
        [_synth buildSineTable];
    }
}

@end
