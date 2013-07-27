//
//  SGPopoverModalOptionController.m
//  SeaGlass
//
//  Copyright (c) 2011 Ken Joyner.
//  http://kjoyner.com
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//

#import "SGPopoverModalOptionController.h"

@interface SGPopoverModalOptionController() 

@property(nonatomic, assign) NSUInteger numOptions;
@property(nonatomic, assign) NSUInteger selectedRow;

@end

@implementation SGPopoverModalOptionController

@synthesize delegate = i_delegate;
@synthesize option = i_option;
@synthesize numOptions = i_numOptions;
@synthesize selectedRow = i_selectedRow;

- (id)initWithStyle:(UITableViewStyle) style
{
  self = [super initWithStyle:style];
  if (self) 
  {
    i_numOptions = 6;
    
    i_option = SGPopoverInWindow;    
    [self setContentSizeForViewInPopover:CGSizeMake( 200.0f, 44.0 * i_numOptions)];
  }
  return self;
}


- (NSString*) optionTextForOption:(NSUInteger)option
{
  switch (option)
  {
    case SGPopoverInWindow:
      return @"In Window";
    case SGPopoverInScrollView:
      return @"In ScrollView";
    case SGPopoverInWindowModal:
      return @"In Window - Modal";
    case SGPopoverInScrollViewModal:
      return @"In ScrollView - Modal";
    case SGPopoverInWindowPassThrough:
      return @"In Window - PassThrough";
    case SGPopoverInScrollViewPassThrough:
      return @"In ScrollView - PassThrough";
  }
  return nil;
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.numOptions;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString* CellIdentifier = @"Cell";
    
  UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) 
  {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
  }      
  
  NSUInteger row = indexPath.row;
  if (row == self.selectedRow)
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  else
    cell.accessoryType = UITableViewCellAccessoryNone;
    
  cell.textLabel.text = [self optionTextForOption:indexPath.row];    

  return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSUInteger row = indexPath.row;
  
  if (self.selectedRow != row)
  {
    NSIndexPath* currentlySelectedIndexPath = [NSIndexPath indexPathForRow:self.selectedRow inSection:0];
    self.selectedRow = row;
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:currentlySelectedIndexPath, indexPath, nil] 
                     withRowAnimation:NO];
  }
    
  self.option = indexPath.row;  
  [self.delegate sgPopoverModalOptionController:self optionSelected:self.option];
}

@end
