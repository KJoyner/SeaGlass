//
//  SGPopoverController.h
//  SeaGlass
//
//  Copyright (c) 2011 Ken Joyner.
//  http://kjoyner.com
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//

#import "SGPopoverController.h"

#import "SGPopoverView.h"
#import "SGPopoverViewProperties.h"

//! @cond include_private

static CGFloat kAnimationDuration = 0.25f;

typedef enum 
{
  kUserSetClipFrame          = 1,
  kUserSetDisplayFrame       = kUserSetClipFrame << 1,
  kUserSetModal              = kUserSetDisplayFrame << 1,
  kUserSetOverlayFrame       = kUserSetModal << 1,
  kUserSetPopoverContentSize = kUserSetOverlayFrame << 1,
} UserSetTrackedProperty;

@interface SGPopoverController()

@property(nonatomic, strong) UITapGestureRecognizer* tapGesture;
@property(nonatomic, assign) NSUInteger              userSetTrackedProperites;
@property(nonatomic, strong) SGPopoverView*          view;

@property(nonatomic, getter=isPopoverVisible) BOOL   popoverVisible;

- (void) setDefaultFramePropertiesForView:(UIView *)view;
- (void) setDefaultPopoverContentSize;

@end

//! @endcond include_private

@implementation SGPopoverController

@synthesize clipFrame                = i_clipFrame;
@synthesize contentViewController    = i_contentViewController;
@synthesize properties               = i_properties;
@synthesize delegate                 = i_delegate;
@synthesize displayFrame             = i_displayFrame;
@synthesize modal                    = i_modal;
@synthesize overlayFrame             = i_overlayFrame;
@synthesize passthroughViews         = i_passthroughViews;
@synthesize popoverContentSize       = i_popoverContentSize;
@synthesize popoverVisible           = i_popoverVisible;
@synthesize popoverArrowDirection    = i_popoverArrowDirection;
@synthesize tapGesture               = i_tapGesture;
@synthesize userSetTrackedProperites = i_userSetTrackedProperties;
@synthesize view                     = i_view;

////////////////////////////////////////////////////////////////////////////////////////////////////
//! @name Initializing the Popover
//!
//! @{

//! Returns an initialized popover controller object.
//! 
//! @param controller 
//!   The controller for managing the popover’s content. This parameter must not be nil.
//!
//! @return 
//!   An initialized popover content view controller object.
//!
//! @par Discussion
//!   When initializing a popover controller, you must specify the popover content view controller   
//!   object whose content is to be displayed in the popover. You can change this controller later  
//!   by modifying the contentViewController property.
//!
- (id) initWithContentViewController:(id<SGPopoverContentViewController>)controller 
{
  self = [super init];  
  if (self != nil) 
  {
    i_contentViewController = controller;
    i_popoverContentSize = [controller contentSizeForViewInPopover];
    i_modal = YES;
    
    if ([i_contentViewController respondsToSelector:@selector(setSgParentPopoverController:)])
      [i_contentViewController setSgParentPopoverController:self];
  }
  return self;
}


- (void) dealloc 
{
  if (i_view != nil)
  {
    [i_tapGesture.view removeGestureRecognizer:i_tapGesture];  
  
    if ([i_contentViewController respondsToSelector:@selector(viewWillDisappear:)])
      [i_contentViewController viewWillDisappear:NO];
    
     [i_view removeFromSuperview];
     
     if ([i_contentViewController respondsToSelector:@selector(viewDidDisappear:)])
       [i_contentViewController viewDidDisappear:NO];
  }
    
  if ([i_contentViewController respondsToSelector:@selector(setSgParentPopoverController:)])
    [i_contentViewController setSgParentPopoverController:nil];
  
  
      
}


//! @} End of Managing Segment Content
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
//! @name Configuring the Popover Attributes
//!
//! @{

- (BOOL) didUserSetProperty:(UserSetTrackedProperty)property
{
  return (self.userSetTrackedProperites & property) != 0;
}


- (void) markPropertyAsUserSet:(UserSetTrackedProperty)property
{
  self.userSetTrackedProperites |= property;
}


- (void) unmarkPropertyAsUserSet:(UserSetTrackedProperty)property
{
  self.userSetTrackedProperites &= ~property;
}


- (void) setClipFrame:(CGRect)frame
{
  i_clipFrame = frame;
  [self markPropertyAsUserSet:kUserSetClipFrame];
}


- (void) setContentViewController:(id<SGPopoverContentViewController>)controller 
{
  [self setContentViewController:controller animated:NO];
}


//! Sets the popover content view controller responsible for the content portion of the popover.
//!
//! @param controller 
//!   The new popover contentview controller whose content should be displayed by the popover.
//! @param animated 
//!   Specify YES if the change of controllers should be animated or NO if the change should
//!   occur immediately.
//!
//! @par Note
//!   This will also reset the popoverContentSize based upon the new contentViewController. If
//!   needed, you can reset the popoverContentSize after calling this function.
- (void) setContentViewController:(id<SGPopoverContentViewController>)controller 
                         animated:(BOOL)animated
{
  if (i_contentViewController != controller)
  {
    if (self.view != nil)
    {
      // notify existing content view controller that it is about to disappear
      if ([i_contentViewController respondsToSelector:@selector(viewWillDisappear:)])
        [i_contentViewController viewWillDisappear:animated];
    }

    // current content view will no longer be managed by this popover    
    if ([i_contentViewController respondsToSelector:@selector(setSgParentPopoverController:)])
      [i_contentViewController setSgParentPopoverController:nil];

    // need to save so we can notify content view controller that it did disappear    
    id<SGPopoverContentViewController> previousController = i_contentViewController;
    
    // now we are working with the new content view controller
    i_contentViewController = controller;
    
    // new content view is now managed by this popover    
    if ([i_contentViewController respondsToSelector:@selector(setSgParentPopoverController:)])
      [i_contentViewController setSgParentPopoverController:self];
    
    // notify new content view controller that it is about to appear
    if ([i_contentViewController respondsToSelector:@selector(viewWillAppear:)])
      [i_contentViewController viewWillDisappear:animated];
     
    // since we changed content view, reset the default popover content size
    [self setDefaultPopoverContentSize];
      
    [UIView animateWithDuration:(animated ? kAnimationDuration : 0.0f) 
                     animations:^
      {
        self.view.contentSize = self.popoverContentSize;
        self.view.contentView = i_contentViewController.view;      
      }
                     completion:^(BOOL finished)
      {
        // notify previous content view controller that it did disappear
        if ([previousController respondsToSelector:@selector(viewDidDisappear:)])
            [previousController viewDidDisappear:animated];
         
        // notify new content view controller that it did appear
        if ([i_contentViewController respondsToSelector:@selector(viewDidAppear:)])
          [i_contentViewController viewDidAppear:animated];
      }];          
  }
}


- (void) setDefaultFramePropertiesForView:(UIView *)view 
{
  // note: we modify ivars directly so we don't trigger user set flags
  
  if (![self didUserSetProperty:kUserSetDisplayFrame])
  {  
    if ([view isKindOfClass:[UIScrollView class]])
    {
      // even though we are adding content to a scroll view, try to stay on screen
      CGPoint contentOffset = [(UIScrollView *)view contentOffset];
      i_displayFrame = CGRectMake(contentOffset.x, contentOffset.y, 
                                  view.bounds.size.width, view.bounds.size.height);
      
      // in a scroll view, the default action will clip to the display frame
      if (![self didUserSetProperty:kUserSetClipFrame])
      {
        UIScrollView* scrollView = (UIScrollView *)view;
        
        UIEdgeInsets insets = scrollView.contentInset; 
        
        CGSize size = scrollView.contentSize;
        size.width  -= (insets.left + insets.right);
        size.height -= (insets.top + insets.bottom);
        
        i_clipFrame = CGRectMake(insets.left, insets.bottom, size.width, size.height);
      }      
    }
    else 
    {
      i_displayFrame = view.bounds;
      if (![self didUserSetProperty:kUserSetClipFrame])
        i_clipFrame = i_displayFrame;
    }
  }
  else if (![self didUserSetProperty:kUserSetClipFrame])
  {
    i_clipFrame = i_displayFrame;
  }
  
  if (![self didUserSetProperty:kUserSetOverlayFrame])
  {
    if ([view isKindOfClass:[UIScrollView class]])
    {
      // do not place an overlay frame in a scroll view, will not be able to capture events as 
      // expected, taps would only be detected within the overlay instead of the entire scroll 
      // view and other events (i.e. drag) will still be interpreted by the scroll view
      
      i_overlayFrame = CGRectZero;
    }
    else 
    {
      // By default, will set the overlay to the boundary of the parent view.
      // However, if the parent view is a passthrough view then will not set
      // an overlay frame so that way we do not even attempt to capture the 
      // parent views events.
      
      BOOL viewIsPassThroughView = NO;
      for (UIView* passthroughView in self.passthroughViews)
      {
        if (passthroughView == view)
        {
          viewIsPassThroughView = YES;
          break;
        }
      }
      
      if (!viewIsPassThroughView)
        i_overlayFrame = view.bounds;
      else
        i_overlayFrame = CGRectZero;
    }
  }
}


- (void) setDisplayFrame:(CGRect)frame
{
  i_displayFrame = frame;
  [self markPropertyAsUserSet:kUserSetDisplayFrame];
}


- (BOOL) modal
{
  if ([self didUserSetProperty:kUserSetModal])
    return i_modal;
    
  if ([self.contentViewController respondsToSelector:@selector(modalInPopover)])
    return [self.contentViewController modalInPopover];
    
  return NO; 
}


- (void) setModal:(BOOL)modal 
{
  i_modal = modal;
  [self markPropertyAsUserSet:kUserSetModal];
}


- (SGPopoverArrowDirection)popoverArrowDirection
{
  if (self.view == nil)
    return SGPopoverArrowDirectionUnknown;
  return self.view.arrowDirection;
}


- (CGRect) popoverFrame
{
  if (self.view == nil)
    return CGRectZero;
  return self.view.popoverFrame;
}


- (void) setPopoverContentSize:(CGSize)size
{
  [self setPopoverContentSize:size animated:NO];
}


//! Changes the size of the popover’s content view.
//!
//! @param size 
//!   The new size to apply to the content view
//! @param animated 
//!   Specify YES if the change of view controllers should be animated or NO if the change 
//!   should occur immediately.
//!
- (void) setPopoverContentSize:(CGSize)size 
                      animated:(BOOL)animated
{
  if (!CGSizeEqualToSize(size,CGSizeZero))
    [self markPropertyAsUserSet:kUserSetPopoverContentSize];
  else
    [self unmarkPropertyAsUserSet:kUserSetPopoverContentSize];

  if (!CGSizeEqualToSize(i_popoverContentSize, size))
  {
    i_popoverContentSize = size;
    if (self.view != nil)
    {
      self.view.alpha = 0.0f;
      [UIView animateWithDuration:(animated ? kAnimationDuration : 0.0f) 
                       animations:^
       {
         self.view.alpha = 1.0f;
         self.view.contentSize = size;
       }];          
    }
  }
}


- (void) setDefaultPopoverContentSize
{
  if (![self didUserSetProperty:kUserSetPopoverContentSize])
  {
    CGSize size = CGSizeZero;
    
    // will first attempt to use the property contentSizeForViewInPopover
    if ([self.contentViewController respondsToSelector:@selector(contentSizeForViewInPopover)])
    {
      size = [self.contentViewController contentSizeForViewInPopover];
      if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
      {
        // if not iPAD UI, check and see whether property contains iPAD defaults and if so reset
        if (CGSizeEqualToSize(size, CGSizeMake(320.0f, 1100.0f)))
          size = CGSizeZero;
      }
    }
    
    // next, try to use content view size
    if (CGSizeEqualToSize(size, CGSizeZero))
      size = self.contentViewController.view.bounds.size;
    
    // last, used hardcoded values
    if (CGSizeEqualToSize(size, CGSizeZero))
    {
      UIEdgeInsets margins = self.properties.margins;
      UIEdgeInsets insets  = self.properties.contentInsets;
      
      CGFloat width = 320.0f - margins.right - insets.right - insets.left - margins.left;
      
      if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        size = CGSizeMake(width, 400.0f);
      else
        size = CGSizeMake(width, 800.0f); 
    }
    
    // set ivar directly so we do not trigger the user set flag
    i_popoverContentSize = size;
  }
}


//! @} End of Configuring the Popover Attributes
///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Presenting and Dismissing the Popover
///////////////////////////////////////////////////////////////////////////////////////////////////
//! @name Presenting and Dismissing the Popover
//!
//! @{

//! Displays the popover and anchors it to the specified location in the view.
//!
//! @param rect
//!   The rectangle in view at which to anchor the popover window.
//! @param view
//!   The view containing the anchor rectangle for the popover.
//! @param arrowDirections
//!   The arrow directions the popover is permitted to use. You can use this value to force the 
//!   popover to be positioned on a specific side of the rectangle. However, it is generally better 
//!   to specify UIPopoverArrowDirectionAny and let the popover decide the best placement. You must 
//!   not specify UIPopoverArrowDirectionUnknown for this parameter.
//! @param animated
//!   Specify YES to animate the presentation of the popover or NO to display it immediately.
//!
//! @par Discussion
//!   If the popover is currently being displayed, it will be dismissed.
//!
- (void) presentPopoverFromRect:(CGRect)anchor 
                         inView:(UIView *)inView 
       permittedArrowDirections:(SGPopoverArrowDirection)arrowDirections 
                       animated:(BOOL)animated 
{ 
  [self dismissPopoverAnimated:NO];
  
  [self setDefaultFramePropertiesForView:inView];
  [self setDefaultPopoverContentSize];
  
  SGPopoverView* view = [[SGPopoverView alloc] init];
  
  view.anchor       = anchor;
  view.clipFrame     = self.clipFrame;
  view.contentSize  = self.popoverContentSize;  
  view.contentView  = self.contentViewController.view;
  view.displayFrame  = self.displayFrame;
  view.overlayFrame = self.overlayFrame;
  view.passthroughViews = self.passthroughViews;
  view.permittedArrowDirections = arrowDirections;
  view.properties  = self.properties;
  
  // modal means we will not interpret taps and automatically dismiss popover when tap occurs
  // outside popover (follows behavoir of UIPopoverController)
  if (!self.modal)
  {
    UIView* tapGestureView = inView;
    
    // if we are going to add an overlay view, just capture taps within that view
    if (!CGSizeEqualToSize(self.overlayFrame.size, CGSizeZero))
      tapGestureView = view;
     
    // if view that we would normally detect taps is a passthrough view, then do not setup
    // a tap gesture in that view
    for (UIView* passthroughView in self.passthroughViews)
    {
      if (tapGestureView == passthroughView)
      {
        tapGestureView = nil;
        break;
      }
    }
    
    if (tapGestureView != nil)
    {
      UITapGestureRecognizer* gesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                 action:@selector(dismissOnTap:)];
      self.tapGesture = gesture;
    
      gesture.cancelsTouchesInView = YES;
      [tapGestureView addGestureRecognizer:gesture];
    }
  }

  [inView addSubview:view];
  self.view = view;
  
  if ([self.contentViewController respondsToSelector:@selector(viewWillAppear:)])
    [self.contentViewController viewWillAppear:animated];

  view.alpha = 0.0;  
  [UIView animateWithDuration:(animated ? kAnimationDuration : 0.0f) 
                   animations:^
   {
     view.alpha = 1.0;
   }
                   completion:^(BOOL finished)
   {
     self.popoverVisible = YES;

     // notify content view controller that it did appear
     if ([i_contentViewController respondsToSelector:@selector(viewDidAppear:)])
       [i_contentViewController viewDidAppear:animated];
       
     self.view.userInteractionEnabled = YES;
   }];  
}


//! Dismisses the popover programmatically.
//!
//! @param animated 
//!   Specify YES to animate the dismissal of the popover or NO to dismiss it immediately.
//!
//! @par Discussion
//!   You can use this method to dismiss the popover programmatically in response to taps inside the 
//!   popover window. If modal, taps outside of the popover’s contents automatically dismiss the 
//!   popover (unless the tap occurred on a passthrough view).
//!
- (void) dismissPopoverAnimated:(BOOL)animated 
{  
  if (self.view != nil) 
  {    
    // stop detecting taps, 
    //   need to do it here since tap gesture may be in either parent view or container view
    [self.tapGesture.view removeGestureRecognizer:self.tapGesture];    
    self.tapGesture = nil;
    
    if ([self.contentViewController respondsToSelector:@selector(viewWillDisappear:)])
      [self.contentViewController viewWillDisappear:animated];
    
    self.view.userInteractionEnabled = NO;
    self.popoverVisible = NO;
    
    [UIView animateWithDuration:(animated ? kAnimationDuration : 0.0f)
                     animations:^
      {
        self.view.alpha = 0.0f;
      }
                     completion:^(BOOL finished)
      {        
        [self.view removeFromSuperview];
        self.view = nil;    
       
        // notify content view controller that it did disappear
        if ([self.contentViewController respondsToSelector:@selector(viewDidDisappear:)])
          [self.contentViewController viewDidDisappear:animated];
      }];
  }          
}


- (void) dismissOnTap:(UITapGestureRecognizer *)gesture 
{
  // If tap was inside popover, do not automatically dismiss
  
  CGPoint tapPointInView = [gesture locationInView:self.view];  
  if (CGRectContainsPoint(self.view.popoverFrame, tapPointInView))
    return;
  
  BOOL shouldDismiss = YES;
  
  id<SGPopoverControllerDelegate> delegate = self.delegate;
  
  if([delegate respondsToSelector:@selector(popoverControllerShouldDismissPopover:)]) 
    shouldDismiss = [delegate popoverControllerShouldDismissPopover:self];

  if (shouldDismiss)
  {  
    [self dismissPopoverAnimated:YES]; 
  
    if ([self.delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)])
    {
      // this will allow user to release popover during callback      
      [self.delegate popoverControllerDidDismissPopover:self]; 
    }
  }
}


//! @} End of Presenting and Dismissing the Popover
////////////////////////////////////////////////////////////////////////////////////////////////////

@end

