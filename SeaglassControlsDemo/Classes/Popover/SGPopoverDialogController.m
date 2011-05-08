//
//  PopoverController1.m
//  SeaGlass
//
//  Copyright (c) 2011 Ken Joyner.
//  http://kjoyner.com
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//

#import "SGPopoverDialogController.h"

#import "SGPopoverModalOptionController.h"
#import "SGPopoverController.h"

@implementation SGPopoverDialogController

@synthesize delegate = i_delegate;
@synthesize sgParentPopoverController = i_sgParentPopoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
      self.title = @"Test";
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
  // Do any additional setup after loading the view from its nib.
}
 
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

- (void) setSgParentPopoverController:(SGPopoverController *)sgParentPopoverController
{
  i_sgParentPopoverController = sgParentPopoverController;
}

- (IBAction) resizeAction
{
  SGPopoverController* popover = [self sgParentPopoverController];
  [popover setPopoverContentSize:CGSizeMake( 250.0, 175.0) animated:YES];  
}

- (IBAction) dismissAction
{
  [self.delegate controllerDidFinish:self];
}

@end
