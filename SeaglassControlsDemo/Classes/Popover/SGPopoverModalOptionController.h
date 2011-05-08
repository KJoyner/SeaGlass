//
//  SGPopoverModalOptionController.h
//  SeaGlass
//
//  Copyright (c) 2011 Ken Joyner.
//  http://kjoyner.com
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

#import "SGPopoverContentViewController.h"
#import "SGPopoverDemoController.h"

@protocol SGPopoverModalOptionControllerDelegate;


@interface SGPopoverModalOptionController : UITableViewController 
  <SGPopoverContentViewController>

@property(nonatomic, assign) id<SGPopoverModalOptionControllerDelegate> delegate;
@property(nonatomic, assign) SGPopoverModalOptions option;

@end


@protocol SGPopoverModalOptionControllerDelegate <NSObject>

- (void) sgPopoverModalOptionController:(SGPopoverModalOptionController *)controller
                         optionSelected:(SGPopoverModalOptions)option;

@end