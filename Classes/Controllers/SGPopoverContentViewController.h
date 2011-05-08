//
//  SGPopoverContentViewController.h
//  SeaGlass
//
//  Copyright (c) 2011 Ken Joyner.
//  http://kjoyner.com
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

@class SGPopoverController;

@protocol SGPopoverContentViewController <NSObject>

@optional

@property(nonatomic, assign) BOOL modalInPopover;
@property(nonatomic, retain) UIView* view;

@property(nonatomic, assign) SGPopoverController* sgParentPopoverController;

- (CGSize) contentSizeForViewInPopover;

- (void) viewWillAppear:(BOOL)animated;
- (void) viewDidAppear:(BOOL)animated;
- (void) viewWillDisappear:(BOOL)animated;
- (void) viewDidDisappear:(BOOL)animated;

@end
