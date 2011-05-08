//
//  RootViewController.m
//  SeaglassControlsDemo
//
//  Copyright (c) 2011 Ken Joyner.
//  http://kjoyner.com
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//

#import "RootViewController.h"

#import "SGPopoverDemoController.h"
#import "SGRatingController.h"

@implementation RootViewController

- (void)viewDidLoad
{
  self.title = @"Demo";
  [super viewDidLoad];
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


// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 2;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
    
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
    
  NSUInteger row = indexPath.row;
  switch (row)
  {
    case 0:
      cell.textLabel.text = @"Popovers";
      break;
    case 1:
      cell.textLabel.text = @"Rating Controls";
      break;
  }
  
  return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  UIViewController* controller = nil;
  
  NSUInteger row = indexPath.row;
  switch (row)
  {
    case 0:
      controller = [[[SGPopoverDemoController alloc] init] autorelease]; 
      break;
    case 1:
      controller = [[[SGRatingController alloc] initWithNibName:@"SGRatingController" bundle:nil] autorelease];
      break;
  }

  if (controller != nil)   
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)dealloc
{
    [super dealloc];
}

@end
