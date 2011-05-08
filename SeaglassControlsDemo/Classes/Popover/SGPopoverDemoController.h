//
//  PopoverDemoController.h
//  SeaGlass
//
//  Copyright (c) 2011 Ken Joyner.
//  http://kjoyner.com
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>


typedef enum
{
  SGPopoverArrowDirectionOptionAny,
  SGPopoverArrowDirectionOptionUp,
  SGPopoverArrowDirectionOptionDown,
  SGPopoverArrowDirectionOptionLeft,
  SGPopoverArrowDirectionOptionRight,
} SGPopoverArrowDirectionOptions;


typedef enum 
{
  SGPopoverInWindow,
  SGPopoverInScrollView,
  SGPopoverInWindowModal,
  SGPopoverInScrollViewModal,
  SGPopoverInWindowPassThrough,
  SGPopoverInScrollViewPassThrough,
} SGPopoverModalOptions;


@interface SGPopoverDemoController : UITableViewController

    
@end
