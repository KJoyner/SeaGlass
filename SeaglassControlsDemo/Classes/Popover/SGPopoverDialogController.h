//
//  PopoverController1.h
//  SeaGlass
//
//  Copyright (c) 2011 Ken Joyner.
//  http://kjoyner.com
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

#import "SGPopoverContentViewController.h"

@protocol SGPopoverDialogControllerDelegate;

@interface SGPopoverDialogController : UIViewController <SGPopoverContentViewController>
{
  id<SGPopoverDialogControllerDelegate> __unsafe_unretained i_delegate;
  SGPopoverController* __unsafe_unretained i_sgParentPopoverController;
}

@property(nonatomic, unsafe_unretained) id<SGPopoverDialogControllerDelegate> delegate;

- (IBAction) resizeAction;
- (IBAction) dismissAction;

@end

@protocol SGPopoverDialogControllerDelegate <NSObject>

- (void) controllerDidFinish:(SGPopoverDialogController *)controller;

@end

