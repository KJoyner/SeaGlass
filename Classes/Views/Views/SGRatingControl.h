//
//  SGRatingControl.h
//  SeaGlass
//
//  Copyright (c) 2011 Ken Joyner.
//  http://kjoyner.com
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>


@interface SGRatingControl : UIControl 
{
@private	
	NSUInteger i_rating;
  NSUInteger i_numRatings;
	
  UIImage* i_nonRatedImage;
	UIImage* i_ratedImage;
  
  CGFloat i_hitArea;
  
  BOOL i_disableCheckForToggleOffAction;
  BOOL i_checkForToggleOffAction;
}


//! The currently selected rating.
@property(nonatomic, assign) NSUInteger rating;

//! The number of ratings. Default is 5.
@property(nonatomic, assign) NSUInteger numRatings;

//! The minimim hit size. Default is 42x42.
//!
//! @par Discussion
//!   The larger of this value or the image sizes will be used to determine the preferred size of
//!   control, the layout and the hit locations for each rating.  
@property(nonatomic, assign) CGFloat hitArea;

//! Image that represents a non-rated setting.
@property(nonatomic, retain) UIImage* nonRatedImage;

//! Image that represents a rated setting.
@property(nonatomic, retain) UIImage* ratedImage;

//! Disables the check for toggling the last rating value off.
//!
//! @par Discussion
//!   By default, it user clicks the last rated value and it is already on, then that rating
//!   will be toggled off.  
@property(nonatomic, assign) BOOL disableCheckForToggleOffAction;

@end
