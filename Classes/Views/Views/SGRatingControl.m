//
//  SGRatingControl.m
//  SeaGlass
//
//  Copyright (c) 2011 Ken Joyner.
//  http://kjoyner.com
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//

#import "SGRatingControl.h"

#import "SGGlobalPaths.h"

static NSUInteger kDefaultNumberRatings = 5;

// the default hit area will support 5 rating areas with before and after target areas
// along with margins of up to 13.0f and still fit within a width of 320.0
static CGFloat kDefaultHitArea = 42.0f;  // (7 * 42) + (2 * 13) = 320.0
 
@interface SGRatingControl ()

@property(nonatomic, assign) BOOL checkForToggleOffAction;

- (void) commonInit;
- (void) processTouch:(UITouch *)touch;

@end


@implementation SGRatingControl

@synthesize rating     = i_rating;
@synthesize numRatings = i_numRatings;

@synthesize hitArea = i_hitArea;

@synthesize nonRatedImage = i_nonRatedImage;
@synthesize ratedImage    = i_ratedImage;

@synthesize disableCheckForToggleOffAction = i_disableCheckForToggleOffAction;

// Private property used to track state related to toggling on/off a specific rating.
@synthesize checkForToggleOffAction = i_checkForToggleOffAction;


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization and Deallocation
////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) commonInit
{
  i_numRatings = kDefaultNumberRatings;
  
  i_hitArea = kDefaultHitArea;
  
  NSString* nonRatedImagePath = SGPathForBundleImageResource(@"SGNonRatedImage", @"png");
  i_nonRatedImage = [[UIImage alloc] initWithContentsOfFile:nonRatedImagePath];
  
  NSString* ratedImagePath = SGPathForBundleImageResource(@"SGRatedImage", @"png");
  i_ratedImage = [[UIImage alloc] initWithContentsOfFile:ratedImagePath];
}


//! Initialzer when this control is instantiated within Interface Builder. To instanticate
//! within Interface Builder, add a UIView and then set the class to SGRatingControl.
- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self != nil) 
  {
    [self commonInit];
  }
  return self;
}  


//! Designated Initializer.
- (id) initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
	if (self != nil)
	{
    [self commonInit];
	}	
	return self;
}




//! Determine the best size for this control.
//!
//! @param size
//!   This paramenter is not used.
//! @return 
//!   The best size for this control.
//!
//! @par Discussion
//!   The size will be based upon the number of ratings, the size of the hit area and the 
//!   image sizes.
- (CGSize) sizeThatFits:(CGSize)size
{
  // the input size parameter value is ignored
  
  CGSize nonRatedImageSize = self.nonRatedImage.size;
  CGSize ratedImageSize = self.ratedImage.size;
  
  CGFloat widthOfRating = MAX(nonRatedImageSize.width, ratedImageSize.width);
  widthOfRating = MAX(widthOfRating, self.hitArea);
  
  // add room for 0 rating before and max ratings after
  size.width = widthOfRating * (self.numRatings + 2);
  
  size.height = MAX(nonRatedImageSize.height, ratedImageSize.height);
  size.height = MAX(size.height, self.hitArea);
  
  return size;  
}


- (void) drawRect:(CGRect)rect
{
  // Note: Ignores rect parameter. Will always draw the entire control.
     
  CGSize size = self.frame.size;
  
  CGSize nonRatedImageSize  = self.nonRatedImage.size;
  CGSize ratedImageSize     = self.ratedImage.size;
  
  CGFloat stepWidth = MAX(nonRatedImageSize.width, ratedImageSize.width);
  stepWidth = MAX(stepWidth, self.hitArea);
  
  CGFloat nonRatedImageOffsetY  = round((size.height - nonRatedImageSize.height) / 2);
  CGFloat ratedImageOffsetY = round((size.height - ratedImageSize.height) / 2);

  // determine center of first rating (make space for 0 rating to left of first rating)     
	CGFloat currentCenterX = round(self.hitArea + (self.hitArea / 2.0f));
  
  NSUInteger currentDrawnRating = 0;
  
  // draw rated images first
  NSUInteger rating = self.rating;
	for (CGPoint currentDrawPoint = CGPointMake(0.0, ratedImageOffsetY);
       currentDrawnRating < rating; 
       currentDrawnRating++)
	{
    currentDrawPoint.x = round(currentCenterX - (ratedImageSize.width / 2));
		[self.ratedImage drawAtPoint:currentDrawPoint];
    currentCenterX += stepWidth;
	}
	
  // then draw non-rated images
  NSUInteger numRatings = self.numRatings;
	for (CGPoint currentDrawPoint = CGPointMake(0.0, nonRatedImageOffsetY);
       currentDrawnRating < numRatings; 
       currentDrawnRating++)
	{
    currentDrawPoint.x = round(currentCenterX - (nonRatedImageSize.width / 2));
		[self.nonRatedImage drawAtPoint:currentDrawPoint];
    currentCenterX += stepWidth;
	}	
}


- (void) processTouch:(UITouch *)touch
{
	CGPoint location = [touch locationInView:self];

  NSUInteger ratingHit = location.x / self.hitArea;

  BOOL hitOutsideRatingRange = NO;  
  if (ratingHit == 0)
  {
    hitOutsideRatingRange = YES;
  }
  else if (ratingHit > self.numRatings)
  {
    hitOutsideRatingRange = YES;
    ratingHit = self.numRatings;
  }
  
  if (self.rating != ratingHit)
  {
    // make sure we are not checking for the toggle off action
    self.checkForToggleOffAction = NO;
    
    self.rating = ratingHit;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];    
    [self setNeedsDisplay];
  }
  else 
  {
    if (touch.phase == UITouchPhaseBegan && !self.disableCheckForToggleOffAction)
    {
      // make sure that when we begin a touch phase, we set whether we should perform
      // checking for the toggle off action
      
      if (hitOutsideRatingRange)
        self.checkForToggleOffAction = NO;
      else
        self.checkForToggleOffAction = YES;
    }
    else if (touch.phase == UITouchPhaseEnded && self.checkForToggleOffAction)
    {
      self.rating = ratingHit - 1;
      
      [self sendActionsForControlEvents:UIControlEventValueChanged];      
      [self setNeedsDisplay];
    }
  }
}


- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{  
  [self processTouch:touch];    
	return YES;
}


- (BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
  [self processTouch:touch];
  return YES;
}


- (void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
  [self processTouch:touch];  
}


@end
