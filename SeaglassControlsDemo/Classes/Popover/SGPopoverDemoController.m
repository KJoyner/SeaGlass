//
//  PopoverDemoController.m
//  SeaGlass
//
//  Copyright (c) 2011 Ken Joyner.
//  http://kjoyner.com
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//

#import "SGPopoverDemoController.h"

#import "SGPopoverController.h"

#import "SGPopoverDialogController.h"
#import "SGPopoverArrowDirectionOptionController.h"
#import "SGPopoverModalOptionController.h"


@interface SGPopoverDemoController() 
  <SGPopoverControllerDelegate, 
   SGPopoverArrowDirectionOptionControllerDelegate, 
   SGPopoverDialogControllerDelegate,
   SGPopoverModalOptionControllerDelegate>

@property(nonatomic, assign) SGPopoverArrowDirectionOptions arrowDirectionOption;
@property(nonatomic, assign) SGPopoverModalOptions modalOption;
@property(nonatomic, strong) SGPopoverController*  systemPopover;
@property(nonatomic, strong) SGPopoverController*  tablePopover;

- (void) configureModalOption:(UIBarButtonItem *)item event:(UIEvent *)event;

@end


@implementation SGPopoverDemoController

@synthesize arrowDirectionOption = i_arrowDirectionOption;
@synthesize modalOption   = i_modalOption;
@synthesize systemPopover = i_systemPopover;
@synthesize tablePopover  = i_tablePopover;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) 
    {
      i_arrowDirectionOption = SGPopoverArrowDirectionOptionAny;
      i_modalOption = SGPopoverInWindow;
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.title = @"Popovers Demo";
  
  UIBarButtonItem* item = [[UIBarButtonItem alloc] 
                            initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                            target:self 
                            action:@selector(configureModalOption:event:)];
  self.navigationItem.rightBarButtonItem = item;

  
  self.navigationController.toolbarHidden = NO;
  NSMutableArray* toolbarItems = [NSMutableArray arrayWithCapacity:4];
  
  UIBarButtonItem* item1 = [[UIBarButtonItem alloc] 
    initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                         target:self 
                         action:@selector(configureModalOption:event:)];
  [toolbarItems addObject:item1];
  
  UIBarButtonItem* spacer = [[UIBarButtonItem alloc] 
    initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                         target:nil
                         action:nil];
  [toolbarItems addObject:spacer];
  
  UIBarButtonItem* item2 = [[UIBarButtonItem alloc] 
    initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                         target:self 
                         action:@selector(configureArrowDirectionOption:event:)];
                         
  [toolbarItems addObject:item2];
  self.toolbarItems = toolbarItems;
}

- (BOOL) hidesBottomBarWhenPushed
{
  return NO;
}

- (void)viewDidUnload
{
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
  if (self.systemPopover && interfaceOrientation != self.interfaceOrientation)
    return NO;
    
  return YES;
}


- (void) configureArrowDirectionOption:(UIBarButtonItem *)item event:(UIEvent *)event
{
  UIView* primaryView = self.view.window.rootViewController.view;
  CGRect  anchor;
      
  if ([event respondsToSelector:@selector(allTouches)])
  {
    // If user taps semi-close to the UIBarButtonItem, we may receive an event
    // for the item, but the event will not contain the view information that we
    // use to create an anchor. Therefore, you can either ignore the event (the
    // item will still respond by moving to the selected state as if the user did 
    // touch it or create an anchor by some other means (i.e. hardcoding, anchor
    // to a portion of the UINavigationBar or UIToolBar item is located in, etc.).

    UIView* itemView = [[event.allTouches anyObject] view];
    anchor = [itemView convertRect:itemView.bounds toView:primaryView];
  }
  else
  {
    // we ignore the event and just return if we cannot determine an anchor
    return;
  }
  
  SGPopoverArrowDirectionOptionController* controller = 
    [[SGPopoverArrowDirectionOptionController alloc] init];
  controller.delegate = self;
  controller.option = self.arrowDirectionOption;
    
  SGPopoverController* popover = 
    [[SGPopoverController alloc] initWithContentViewController:controller];
  popover.delegate = self;
    
  // we are presenting inside the root view
  [popover presentPopoverFromRect:anchor 
                           inView:primaryView 
         permittedArrowDirections:UIPopoverArrowDirectionAny 
                         animated:YES];
  
  self.systemPopover = popover;
}
 

- (void) configureModalOption:(UIBarButtonItem *)item event:(UIEvent *)event
{
  UIView* primaryView = self.view.window.rootViewController.view;
  CGRect  anchor;
  
  if ([event respondsToSelector:@selector(allTouches)])
  {
    // If user taps semi-close to the UIBarButtonItem, we may receive an event
    // for the item, but the event will not contain the view information that we
    // use to create an anchor. Therefore, you can either ignore the event (the
    // item will still respond by moving to the selected state as if the user did 
    // touch it or create an anchor by some other means (i.e. hardcoding, anchor
    // to a portion of the UINavigationBar or UIToolBar item is located in, etc.).
    UIView*  itemView = [[event.allTouches anyObject] view];
    anchor = [itemView convertRect:itemView.bounds toView:primaryView];
    
  }
  else
  {
    // we ignore the event and just return if we cannot determine an anchor
    return;
  }

  SGPopoverModalOptionController* controller = [[SGPopoverModalOptionController alloc] init];
  controller.delegate = self;
  controller.option = self.modalOption;

  SGPopoverController* popover = 
    [[SGPopoverController alloc] initWithContentViewController:controller];
  popover.delegate = self;
  
  // we are presenting inside the primary view
  [popover presentPopoverFromRect:anchor inView:primaryView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  
  self.systemPopover = popover;
}


- (void) sgPopoverModalOptionController:(SGPopoverModalOptionController *)controller 
                         optionSelected:(SGPopoverModalOptions)option 
{
  self.modalOption = option;
  
  [self.systemPopover dismissPopoverAnimated:YES];
  self.systemPopover = nil;
  
  [self.tableView reloadData];
}


- (void) sgPopoverArrowDirectionOptionController:(SGPopoverArrowDirectionOptionController *)controller 
                                  optionSelected:(SGPopoverArrowDirectionOptions)option  
{
  self.arrowDirectionOption = option;  
  [self.systemPopover dismissPopoverAnimated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
    
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) 
  {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
  }
  
  NSUInteger row = indexPath.row;
  
	cell.textLabel.text = [NSString stringWithFormat:@"Row %d", row];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"Anchor at position %d", row % 10];
    
  return cell;
}


#pragma mark - Table view delegate

- (CGRect) anchorForRowAtIndexPath:(NSIndexPath *)indexPath inView:(UIView *)view
{
  CGRect anchor = [self.tableView rectForRowAtIndexPath:indexPath];
  
  NSUInteger anchorColumn = indexPath.row % 10;
  
  anchor.size.width = anchor.size.width / 10;
  anchor.origin.x   = anchorColumn * anchor.size.width; 
  
  anchor = [self.tableView convertRect:anchor toView:view];  
  return anchor;
}  


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (self.tablePopover != nil)
    return;
    
  SGPopoverDialogController* contentController = 
    [[SGPopoverDialogController alloc] init];
  contentController.delegate = self;
    
  SGPopoverController* popover = [[SGPopoverController alloc] 
                                   initWithContentViewController:contentController];
  popover.delegate = self;

  UIView* inView = tableView.window.rootViewController.view;
  if (self.modalOption == SGPopoverInScrollView || 
      self.modalOption == SGPopoverInScrollViewModal ||
      self.modalOption == SGPopoverInScrollViewPassThrough)
  {
    inView = tableView;
  }
  
  if (self.modalOption == SGPopoverInScrollViewModal || self.modalOption == SGPopoverInWindowModal)
    popover.modal = TRUE;
    
  if (self.modalOption == SGPopoverInScrollViewPassThrough ||
      self.modalOption == SGPopoverInWindowPassThrough)
    popover.passthroughViews = [NSArray arrayWithObject:inView];
  
  CGRect  anchor = [self anchorForRowAtIndexPath:indexPath inView:inView];
  
  SGPopoverArrowDirection permittedArrowDirection;
  switch (self.arrowDirectionOption)
  {
    case SGPopoverArrowDirectionOptionAny:
      permittedArrowDirection = SGPopoverArrowDirectionAny;
      break;
    case SGPopoverArrowDirectionOptionUp:
      permittedArrowDirection = SGPopoverArrowDirectionUp;
      break;
    case SGPopoverArrowDirectionOptionDown:
      permittedArrowDirection = SGPopoverArrowDirectionDown;
      break;
    case SGPopoverArrowDirectionOptionLeft:
      permittedArrowDirection = SGPopoverArrowDirectionLeft;
      break;
    case SGPopoverArrowDirectionOptionRight:
      permittedArrowDirection = SGPopoverArrowDirectionRight;
      break;
  }
  
  
  [popover presentPopoverFromRect:anchor 
                           inView:inView 
         permittedArrowDirections:permittedArrowDirection 
                         animated:YES];
  
   self.tablePopover = popover;
}

- (void) controllerDidFinish:(SGPopoverDialogController *)controller
{
  [self.tablePopover dismissPopoverAnimated:YES];
  self.tablePopover = nil;
}

- (void) popoverControllerDidDismissPopover:(SGPopoverController *)popoverController
{
  if (popoverController == self.tablePopover)
    self.tablePopover = nil;
  else if (popoverController == self.systemPopover)
    self.systemPopover = nil;
}      


@end
