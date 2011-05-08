//
//  SGPopoverArrowDirectionOption.h
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

@protocol SGPopoverArrowDirectionOptionControllerDelegate;


@interface SGPopoverArrowDirectionOptionController : UITableViewController 
  <SGPopoverContentViewController>

@property(nonatomic, assign) id<SGPopoverArrowDirectionOptionControllerDelegate> delegate;
@property(nonatomic, assign) SGPopoverArrowDirectionOptions option;

@end


@protocol SGPopoverArrowDirectionOptionControllerDelegate <NSObject>

- (void) sgPopoverArrowDirectionOptionController:(SGPopoverArrowDirectionOptionController *)controller
                                  optionSelected:(SGPopoverArrowDirectionOptions)option;

@end
@interface SGPopoverArrowDirectionOption : UITableViewController {
    
}

@end
