//
//  SGPopoverArrowDirectionOption.m
//  SeaGlass
//
//  Copyright (c) 2011 Ken Joyner.
//  http://kjoyner.com
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//

#import "SGPopoverArrowDirectionOptionController.h"

@interface SGPopoverArrowDirectionOptionController() 

@property(nonatomic, assign) NSUInteger numOptions;

@end

@implementation SGPopoverArrowDirectionOptionController

@synthesize delegate    = i_delegate;
@synthesize option      = i_option;
@synthesize numOptions  = i_numOptions;

- (id)initWithStyle:(UITableViewStyle) style
{
  self = [super initWithStyle:style];
  if (self) 
  {
    i_numOptions = 5;
    
    i_option = SGPopoverArrowDirectionOptionAny;    
    [self setContentSizeForViewInPopover:CGSizeMake( 200.0f, 44.0 * i_numOptions)];
  }
  return self;
}




- (NSString*) optionTextForOption:(NSUInteger)option
{
  switch (option)
  {
    case SGPopoverArrowDirectionOptionAny:
      return @"Any Direction";
    case SGPopoverArrowDirectionOptionUp:
      return @"Up Arrows Only";    
    case SGPopoverArrowDirectionOptionDown:
      return @"Down Arrows Only";
    case SGPopoverArrowDirectionOptionLeft:
      return @"Left Arrows Only";
    case SGPopoverArrowDirectionOptionRight:
      return @"Right Arrows Only";
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
  if (row == self.option)
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
  
  if (self.option != row)
  {
    NSIndexPath* currentlySelectedIndexPath = [NSIndexPath indexPathForRow:self.option inSection:0];
    self.option = row;
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:currentlySelectedIndexPath, indexPath, nil] 
                     withRowAnimation:NO];
  }
  
  [self.delegate sgPopoverArrowDirectionOptionController:self optionSelected:self.option];
}

@end
