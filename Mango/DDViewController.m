//
//  DDViewController.m
//  Colorific
//
//  Created by Dylan Drop on 12/25/12.
//  Copyright (c) 2012 Columbia University. All rights reserved.
//

#import "DDViewController.h"

@implementation DDViewController

bool tones[8][8];
BleepMachine * m_bleepMachine;
int scale[8] = {440,493.88,523.25,587.33,659.26,698.46,783.99, 880.00};

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    m_bleepMachine = new BleepMachine; m_bleepMachine->Initialise(); m_bleepMachine->Start();
    self.view.backgroundColor = [UIColor colorWithRed:193.0f/255.0f green:194.0f/255.0f blue:196.0f/255.0f alpha:1.0];
    CGFloat width = [UIScreen mainScreen].bounds.size.width / 8;
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
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    delete m_bleepMachine;
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

- (IBAction)changeColor:(id)sender {
    int r = arc4random() % 255;
    int g = arc4random() % 255;
    int b = arc4random() % 255;
    UIColor *color = [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0];
    [self.view setBackgroundColor:color];
}

- (IBAction)changeColor2:(id)sender {
    int b = 255;
    UIColor *color = [UIColor colorWithRed:(0) green:(0) blue:(b/255.0) alpha:1.0];
    [self.view setBackgroundColor:color];
}

- (void)buttonPressed:(UICoordButton *)button {
    m_bleepMachine->SetWave(0, scale[[button getI]], 0.5);
    m_bleepMachine->SetWave(1, scale[[button getI]], 0.5);
    if(tones[[button getI]][[button getJ]]){
        [button setBackgroundColor:[UIColor colorWithRed:35.0f/255.0f green:31.0f/255.0f blue:32.0f/255.0f alpha:1.0]];
    }
    else {
        [button setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:187.0f/255.0f blue:226.0f/255.0f alpha:1.0]];
    }
    tones[[button getI]][[button getJ]] = tones[[button getI]][[button getJ]] ? false : true;
}



@end
