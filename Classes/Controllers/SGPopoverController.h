//
//  SGPopoverController.h
//  SeaGlass
//
//  Copyright (c) 2011 Ken Joyner.
//  http://kjoyner.com
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//
//  This control uses some ideas, code and images (particuarlly the View Properties abstraction)  
//  from the WEPopover project https://github.com/werner77/WEPopover written by Werner Altewischer. 
//  I decided not to fork from that project and write another Popover Controller because of 
//  significant differences in both interface and behavoir that I needed for my project. 

#import <UIKit/UIKit.h>

#import "SGPopoverViewProperties.h"
#import "SGPopoverContentViewController.h"

@class    SGPopoverView;
@protocol SGPopoverControllerDelegate;

@interface SGPopoverController : NSObject
{
@private
  CGRect                             i_clipFrame;
  id<SGPopoverContentViewController> i_contentViewController;
  id<SGPopoverControllerDelegate>    i_delegate;
  CGRect                             i_displayFrame;
  CGRect                             i_overlayFrame;
  BOOL                               i_modal;
  NSArray*                           i_passthroughViews;
  SGPopoverArrowDirection            i_popoverArrowDirection;
  CGSize                             i_popoverContentSize;
  BOOL                               i_popoverVisible;
  SGPopoverViewProperties*           i_properties;
  UITapGestureRecognizer*            i_tapGesture;
  NSUInteger                         i_userSetTrackedProperties;
  SGPopoverView*                     i_view;
}

//! Popover will not be allowed to go outside this frame. By default, the clip frame is the 
//! same as the display frame, except when placed into a scroll view. If placed in a scroll
//! view then the default clip frame is the same as the content size in the scroll view.  
@property(nonatomic, assign) CGRect clipFrame;

//! The view controller responsible for the content portion of the popover. This is initially set
//! to the content view controller passed to the initWithPopoverContentViewController: method. You
//! can change the value of this property later to swap content views (also, see the method
//! setContentViewController:animated:). 
@property(nonatomic, retain) id<SGPopoverContentViewController> contentViewController;

//! The delegate to receive popover controller messages. For more information, see the 
//! SGPopoverControllerDelegate protocol.
@property(nonatomic, assign) id<SGPopoverControllerDelegate> delegate;

//! The popover location and arrow direction will be determined based upon this frame. Preference 
//! will be given to display popover in this frame; however, if needed the popover may extend
//! outside the display frame (but not outside the clip frame). By default, the display frame is
//! set to the bounds of the view the popover is placed in, except when placed into a scroll
//! view. If placed into a scroll view, then the frame will be set to the current content offset
//! plus the size of the scroll view (not the content view).
@property(nonatomic, assign) CGRect displayFrame;

//! Determines whether the popover controller should be presented modally. If YES, then the popover
//! controller will not automatically dismiss itself by taps outside the popover controller. By
//! default, the value of modalInPopover from the content view controller will be used. If this
//! property is not defined by the content view controller, then the default setting is NO.  
@property(nonatomic, assign) BOOL modal;

//! This frame is used to create a container overlay view which actually contains the popover. This
//! overlay view captures all touch interactions and decides whether they are delivered to views
//! under the overlay view based upon the passthroughViews property. By default, the overlay frame
//! is set to the boundary of the view in which the popover is presented into except if presented
//! into a scroll view or the view presented into is a passthroughView. If presented into a scroll
//! view or if the view presented into is a passthroughView, then no overlay view will be used.
//! You can set this to CGRectZero to disable the user of an overlay view. 
@property(nonatomic, assign) CGRect overlayFrame;

//! An array of views that the user can still interact with when the popover is visible. It is
//! valid to specify the view which is being presented into as a passthroughView. In this case, 
//! any interaction outside the popover will not be detected by the popover. This in effect creates
//! a popover that remains visible in the view it is presented into until it is programatically
//! dismissed.
@property(nonatomic, copy) NSArray* passthroughViews;

//! The direction of the popover arrow that is being used when presented. Any other time returns
//! SGPopoverArrowDirectionUnknown.
@property(nonatomic, readonly) SGPopoverArrowDirection popoverArrowDirection;

//! This can be read when a popover is presented to determine the actual frame used for the 
//! popover. One use for this is when you display a popover in a scroll view you may want to adjust 
//! the scroll views content offset values after a popover is displayed. Generally, this would
//! not be needed because the display frame is used to determine a popover location. However, if 
//! it is constrained (for example, must use a down arrow direction) then the popover may be 
//! positioned outside the display frame (but never the clip frame).
@property(nonatomic, assign, readonly) CGRect popoverFrame;

//! The size of the popover content view. For more information, see the method
//! setPopoverContentSize:animiated.
@property(nonatomic, assign) CGSize popoverContentSize;

//! The view properties for customizing how a popover looks. This includes the background image,
//! arrow images, margins, content insets, etc. For more information, see the class 
//! SGPopoverViewProperties.
@property(nonatomic, retain) SGPopoverViewProperties* properties;


// Initializing the Popover
- (id) initWithContentViewController:(id<SGPopoverContentViewController>)controller;

// Configuring the Popover Attributes
- (void) setContentViewController:(id<SGPopoverContentViewController>)controller 
                         animated:(BOOL)animated;
- (void) setPopoverContentSize:(CGSize)size animated:(BOOL) animated;

// Presenting and Dismissing the Popover
- (void)presentPopoverFromRect:(CGRect)rect 
            inView:(UIView *)view 
    permittedArrowDirections:(SGPopoverArrowDirection)arrowDirections 
            animated:(BOOL)animated;
- (void)dismissPopoverAnimated:(BOOL)animated;

@end


//! The SGPopoverControllerDelegate protocol defines the methods you can implement for the delegate 
//! of an SGPopoverController object. Popover controllers notify their delegate whenever user 
//! interactions would cause the dismissal of the popover and, in some cases, give the user a chance 
//! to prevent that dismissal.
@protocol SGPopoverControllerDelegate <NSObject>

@optional

//! Ask the delegate if the popover should be dismissed. 
//!
//! @param popoverController
//!   The popover controller to be dismissed.
//!
//! @return
//!   YES if the popover should be dismissed.
//!
//! @par Discussion
//!   This method is called in response to user-initiated attempts to dismiss the popover. It is not 
//!   called when you dismiss the popover using the dismissPopoverAnimated: method of the popover 
//!   controller. If you do not implement this method in your delegate, the default return value is 
//!   assumed to be YES.
//!
- (BOOL) popoverControllerShouldDismissPopover:(SGPopoverController *)popoverController;

//! Tells the delegate that the popover was dismissed. 
//!
//! @param popoverController
//!   The popover controller that was dismissed.
//!
//! @par Discussion
//!   The popover controller does not call this method in response to programmatic calls to the 
//!   dismissPopoverAnimated: method. If you dismiss the popover programmatically, you should 
//!   perform any cleanup actions immediately after calling the dismissPopoverAnimated: method.
//!
//!   You can use this method to incorporate any changes from the popover’s content view controller
//!   back into your application. If you do not plan to use the object in the popoverController 
//!   parameter again, it is safe to release it from this method. 
//!
- (void) popoverControllerDidDismissPopover:(SGPopoverController *)popoverController;

@end


