//
//  SGRatingController.m
//  SeaGlass
//
//  Copyright (c) 2011 Ken Joyner.
//  http://kjoyner.com
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//

#import "SGRatingController.h"

@interface SGRatingController()

- (void) updateCurrentRatingLabel;

@end


@implementation SGRatingController

@synthesize ratingControl = i_ratingControl;
@synthesize currentRatingLabel = i_currentRatingLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.ratingControl sizeToFit];
  
  self.ratingControl.rating = 3;
  [self updateCurrentRatingLabel];
}

- (void) ratingChanged
{
  [self updateCurrentRatingLabel];
}

- (void) updateCurrentRatingLabel
{
  NSString* text = [NSString stringWithFormat:@"Current rating is %d", self.ratingControl.rating];
  self.currentRatingLabel.text = text;
}

@end
