//
//  SGPopoverView.m
//  SeaGlass
//
//  Copyright (c) 2011 Ken Joyner.
//  http://kjoyner.com
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//

#import "SGPopoverView.h"

#import "SGPopoverViewProperties.h"

// epsilon can be very large when dealing with screen coordinates
#define FloatNotZero(a) (fabs((a)) > 0.1)

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SGPopoverContainerView
////////////////////////////////////////////////////////////////////////////////////////////////////

@interface SGPopoverView()

@property(nonatomic, assign) SGPopoverArrowDirection arrowDirection;
@property(nonatomic, retain) UIView* popoverView;

- (UIImage *) bgImageForPopoverContentFrame:(CGRect)popoverContentFrame 
                               popoverFrame:(CGRect)popoverFrame 
                                 arrowImage:(UIImage *)arrowImage
                                arrowOffset:(CGPoint)arrowOffset;
                                
- (SGPopoverArrowDirection) bestHorizontalDirectionForAnchor:(CGRect)anchor 
                                              leftArrowImage:(UIImage *)leftArrowImage 
                                             rightArrowImage:(UIImage *)rightArrowImage;
- (SGPopoverArrowDirection) bestVerticalDirectionForAnchor:(CGRect)anchor 
                                              upArrowImage:(UIImage *)upArrowImage 
                                            downArrowImage:(UIImage *)downArrowImage;
                                            
- (void) forHorizontalDirection:(SGPopoverArrowDirection)direction 
      adjustPopoverContentFrame:(CGRect *)popoverContentFrame
                  andArrowFrame:(CGRect *)arrowFrame;
- (void) forVerticalDirection:(SGPopoverArrowDirection)direction 
    adjustPopoverContentFrame:(CGRect *)popoverContentFrame
                andArrowFrame:(CGRect *)arrowFrame;
                
- (void) setupViewsForPopoverFrame:(CGRect)popoverFrame bgImage:(UIImage *)bgImage;


@end


@implementation SGPopoverView

@synthesize anchor                   = i_anchor;
@synthesize arrowDirection           = i_arrowDirection;
@synthesize clipFrame                = i_clipFrame;
@synthesize contentSize              = i_contentSize;
@synthesize contentView              = i_contentView;
@synthesize displayFrame             = i_displayFrame;
@synthesize overlayFrame             = i_overlayFrame;
@synthesize permittedArrowDirections = i_permittedArrowDirections;
@synthesize passthroughViews         = i_passthroughViews;
@synthesize popoverView              = i_popoverView;
@synthesize properties               = i_properties;

- (id) initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
  {
    i_arrowDirection = SGPopoverArrowDirectionUnknown;
    i_permittedArrowDirections = SGPopoverArrowDirectionAny;
    
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;    
  }
  return self;
}


- (void) dealloc 
{
  [i_contentView release];
  [i_passthroughViews release];
  [i_properties release];
  
  [i_popoverView release];
    
  [super dealloc];
}


- (void) setAnchor:(CGRect)anchor
{
  i_anchor = anchor;
  [self setNeedsLayout];
}


- (void) setClipFrame:(CGRect)frame
{
  i_clipFrame = frame;
  [self setNeedsLayout];
}

- (void) setContentSize:(CGSize)size
{
  i_contentSize = size;
  [self setNeedsLayout];
}

- (void) setContentView:(UIView *)contentView
{
  if (i_contentView != contentView)
  {
    [i_contentView autorelease];
    [i_contentView release];
    
    i_contentView = [contentView retain];
    [self setNeedsLayout];
  }
}

- (void) setDisplayFrame:(CGRect)frame
{
  i_displayFrame = frame;
  [self setNeedsLayout];
}

- (void) setOverlayFrame:(CGRect)frame
{
  i_overlayFrame = frame;
  [self setNeedsLayout];
}

- (void) setPermittedArrowDirections:(NSUInteger)permittedArrowDirections
{
  i_permittedArrowDirections = permittedArrowDirections;
  [self setNeedsLayout];
}

- (SGPopoverViewProperties *)properties
{
  if (i_properties == nil)
    i_properties = [[SGPopoverViewProperties alloc] init];
  return i_properties;
}

- (void) setProperties:(SGPopoverViewProperties *)properties
{
  if (i_properties != properties)
  {
    [i_properties autorelease];
    [i_properties release];
    
    i_properties = [properties retain];
    [self setNeedsLayout];
  }
}

- (CGRect) popoverFrame
{
  return i_popoverView.frame;
}


- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event
{  
  UIView* result = [super hitTest:point withEvent:event];

  // we only need to perform this check if we have an overlay frame
  if (!CGSizeEqualToSize(self.overlayFrame.size,CGSizeZero))
  {
    // make sure content view receives clicks
    if ([result isDescendantOfView:self.contentView])
      return result;
      
    // pass any hits onto the passThroughViews
    for (UIView* passthroughView in self.passthroughViews)
      if ([result isDescendantOfView:passthroughView])
        return result;

    // will pass hits onto ourselves only        
    return self;
  }
  
  return result;  
}


- (void) layoutSubviews
{
  SGPopoverViewProperties* properties = self.properties;
  
  CGSize contentSize = self.contentSize;
  
  UIEdgeInsets margins = self.properties.margins;
  UIEdgeInsets insets  = self.properties.contentInsets;
  
  CGFloat popoverWidth  = margins.left + insets.left + 
                          contentSize.width + 
                          insets.right + margins.right;
  CGFloat popoverHeight = margins.top + insets.top + 
                          contentSize.height + 
                          insets.bottom + margins.bottom;

  // determine best horizontal direction and set direction, arrow and offset
  //
  UIImage* leftArrowImage  = [UIImage imageWithContentsOfFile:properties.leftArrowImageName];
  UIImage* rightArrowImage = [UIImage imageWithContentsOfFile:properties.rightArrowImageName];  
  
  SGPopoverArrowDirection bestHorizontalDirection = 
    [self bestHorizontalDirectionForAnchor:self.anchor 
                            leftArrowImage:leftArrowImage 
                           rightArrowImage:rightArrowImage];

  UIImage* hArrowImage = nil;
  CGRect   hPopoverContentFrame = CGRectZero;
  CGRect   hArrowFrame = CGRectZero;
  
  if (bestHorizontalDirection != SGPopoverArrowDirectionNone)
  {
    hArrowImage = (bestHorizontalDirection == SGPopoverArrowDirectionLeft) ? 
                  leftArrowImage : 
                  rightArrowImage; 
    
    hPopoverContentFrame.size = CGSizeMake(popoverWidth, popoverHeight);
    hArrowFrame.size = CGSizeMake(hArrowImage.size.width, hArrowImage.size.height);
    
    [self forHorizontalDirection:bestHorizontalDirection
       adjustPopoverContentFrame:&hPopoverContentFrame
                   andArrowFrame:&hArrowFrame];   
  }
    
  // determine best vertical direction and set direction, arrow and offset
  //
  UIImage* vArrowImage = nil;
  CGRect   vPopoverContentFrame = CGRectZero;
  CGRect   vArrowFrame = CGRectZero;
    
  UIImage* upArrowImage    = [UIImage imageWithContentsOfFile:properties.upArrowImageName];
  UIImage* downArrowImage  = [UIImage imageWithContentsOfFile:properties.downArrowImageName];
  
  SGPopoverArrowDirection bestVerticalDirection = 
    [self bestVerticalDirectionForAnchor:self.anchor 
                            upArrowImage:upArrowImage 
                          downArrowImage:downArrowImage];  
    
  if (bestVerticalDirection != SGPopoverArrowDirectionNone)
  {
    vArrowImage = (bestVerticalDirection == SGPopoverArrowDirectionUp) ? 
                  upArrowImage : 
                  downArrowImage;    
    
    vPopoverContentFrame.size = CGSizeMake(popoverWidth, popoverHeight);
    vArrowFrame.size = CGSizeMake(vArrowImage.size.width, vArrowImage.size.height);

    [self forVerticalDirection:bestVerticalDirection
     adjustPopoverContentFrame:&vPopoverContentFrame
                 andArrowFrame:&vArrowFrame];   
  }

  CGRect displayFrame = self.displayFrame;

  CGRect  hVisibleFrame = CGRectIntersection(hPopoverContentFrame, displayFrame);
  CGFloat hSurfaceArea = hVisibleFrame.size.width * hVisibleFrame.size.height;
  
  CGRect  vVisibleFrame = CGRectIntersection(vPopoverContentFrame, displayFrame);
  CGFloat vSurfaceArea = vVisibleFrame.size.width * vVisibleFrame.size.height;
  
  UIImage* arrowImage;
  CGRect   arrowFrame;
  CGRect   popoverContentFrame;
      
  if (vSurfaceArea >= hSurfaceArea)
  {
    self.arrowDirection = bestVerticalDirection;
    arrowImage          = vArrowImage;
    arrowFrame          = vArrowFrame;
    popoverContentFrame = vPopoverContentFrame;
  }
  else
  {
    self.arrowDirection = bestVerticalDirection;
    arrowImage          = hArrowImage;
    arrowFrame          = hArrowFrame;
    popoverContentFrame = hPopoverContentFrame;
  }
    
  popoverContentFrame = CGRectIntegral(popoverContentFrame);
  CGRect popoverFrame = CGRectUnion(popoverContentFrame, arrowFrame);

  UIImage* bgImage = [self bgImageForPopoverContentFrame:popoverContentFrame 
                                            popoverFrame:popoverFrame 
                                              arrowImage:arrowImage
                                             arrowOffset:arrowFrame.origin];
                                             
  [self setupViewsForPopoverFrame:popoverFrame bgImage:bgImage];
}


- (UIImage *) bgImageForPopoverContentFrame:(CGRect)popoverContentFrame 
                               popoverFrame:(CGRect)popoverFrame 
                                 arrowImage:(UIImage *)arrowImage
                                arrowOffset:(CGPoint)arrowOffset
{
  SGPopoverViewProperties* properties = self.properties;
  
  UIImage* bgImage = [UIImage imageWithContentsOfFile:properties.bgImageName];
  bgImage = [bgImage stretchableImageWithLeftCapWidth:properties.leftBgCapWidth 
                                         topCapHeight:properties.topBgCapHeight];

  UIGraphicsBeginImageContextWithOptions(popoverFrame.size, NO, 0.0);

  CGFloat originX = popoverContentFrame.origin.x - popoverFrame.origin.x;
  CGFloat originY = popoverContentFrame.origin.y - popoverFrame.origin.y;

  [bgImage drawInRect:CGRectMake(originX, originY, 
                                 popoverContentFrame.size.width, popoverContentFrame.size.height)];

  originX = arrowOffset.x - popoverFrame.origin.x;
  originY = arrowOffset.y - popoverFrame.origin.y;

  [arrowImage drawAtPoint:CGPointMake(originX, originY)];

  bgImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return bgImage;
}


- (SGPopoverArrowDirection) bestHorizontalDirectionForAnchor:(CGRect)anchor 
                                              leftArrowImage:(UIImage *)leftArrowImage 
                                             rightArrowImage:(UIImage *)rightArrowImage
{
  SGPopoverArrowDirection bestHorizontalDirection = SGPopoverArrowDirectionNone;
  
  SGPopoverArrowDirection permittedArrowDirections = self.permittedArrowDirections;
  if ((permittedArrowDirections & SGPopoverArrowDirectionLeft) && 
      (permittedArrowDirections & SGPopoverArrowDirectionRight))
  {
    // The basic idea here is to check whether the middle of the anchor point is to the left or 
    // right of the middle of the display rectangle. If it is to the left then will prefer a right 
    // arrow otherwise we prefer a left arrow.
    //
    CGFloat anchorMidX  = CGRectGetMidX(anchor);
    CGFloat displayMidX = CGRectGetMidX(self.displayFrame);
    
    // this extra indirection is needed in-case the left/right arrows are different widths
    //
    CGFloat leftPointToCheck  = anchorMidX - leftArrowImage.size.width;
    CGFloat rightPointToCheck = anchorMidX + rightArrowImage.size.width;
    
    if (leftPointToCheck > displayMidX)
      bestHorizontalDirection = SGPopoverArrowDirectionRight;
    else if (rightPointToCheck < displayMidX)
      bestHorizontalDirection = SGPopoverArrowDirectionLeft;
    else
    {
      CGFloat distanceLeftPointToMid  = displayMidX - leftPointToCheck;
      CGFloat distanceRightPointToMid = rightPointToCheck - displayMidX;
      
      if (distanceLeftPointToMid < distanceRightPointToMid)
        bestHorizontalDirection = SGPopoverArrowDirectionRight;
      else
        bestHorizontalDirection = SGPopoverArrowDirectionLeft;
    }
  }
  else if (permittedArrowDirections & SGPopoverArrowDirectionLeft)
    bestHorizontalDirection = SGPopoverArrowDirectionLeft;
  else if (permittedArrowDirections & SGPopoverArrowDirectionRight)
    bestHorizontalDirection = SGPopoverArrowDirectionRight;
  
  return bestHorizontalDirection;
}


- (SGPopoverArrowDirection) bestVerticalDirectionForAnchor:(CGRect)anchor 
                                              upArrowImage:(UIImage *)upArrowImage 
                                            downArrowImage:(UIImage *)downArrowImage
{
  SGPopoverArrowDirection bestVerticalDirection = SGPopoverArrowDirectionNone;
  
  SGPopoverArrowDirection permittedArrowDirections = self.permittedArrowDirections;
  if ((permittedArrowDirections & SGPopoverArrowDirectionUp) && 
      (permittedArrowDirections & SGPopoverArrowDirectionDown))
  {
    // The basic idea here is to check whether the middle of the anchor point is above or below the 
    // middle of the display rectangle. If it above then we prefer an up arrow otherwise we prefer 
    // a down arrow.
    //
    CGFloat anchorMidY  = CGRectGetMidY(anchor);    
    CGFloat displayMidY = CGRectGetMidY(self.displayFrame);

    
    // this extra checking is needed in-case the up/down arrows are different heights
    //
    CGFloat topPointToCheck    = anchorMidY - upArrowImage.size.height;
    CGFloat bottomPointToCheck = anchorMidY + downArrowImage.size.height;
    
    if (topPointToCheck > displayMidY)
      bestVerticalDirection = SGPopoverArrowDirectionDown;
    else if (bottomPointToCheck < displayMidY)
      bestVerticalDirection = SGPopoverArrowDirectionUp;
    else
    {
      CGFloat distanceTopPointToMid    = displayMidY - topPointToCheck;
      CGFloat distanceBottomPointToMid = bottomPointToCheck - displayMidY;
      
      if (distanceTopPointToMid < distanceBottomPointToMid)
        bestVerticalDirection = SGPopoverArrowDirectionUp;
      else
        bestVerticalDirection = SGPopoverArrowDirectionDown;
    }
  }
  else if (permittedArrowDirections & SGPopoverArrowDirectionUp)
    bestVerticalDirection = SGPopoverArrowDirectionUp;
  else if (permittedArrowDirections & SGPopoverArrowDirectionDown)
    bestVerticalDirection = SGPopoverArrowDirectionDown;
  
  return bestVerticalDirection;  
}


- (void) forHorizontalDirection:(SGPopoverArrowDirection)direction 
      adjustPopoverContentFrame:(CGRect *)popoverContentFrame 
                  andArrowFrame:(CGRect *)arrowFrame
{  
  CGPoint arrowOrigin   = CGPointZero;
  CGSize  arrowSize     = arrowFrame->size;
  CGPoint popoverOrigin = CGPointZero;
  CGSize  popoverSize   = popoverContentFrame->size;
  CGFloat popoverMidY = popoverSize.height / 2;
  
  CGRect  displayFrame = self.displayFrame;
  CGFloat displayMinX  = CGRectGetMinX(displayFrame);
  CGFloat displayMaxX  = CGRectGetMaxX(displayFrame);
  CGFloat displayMinY  = CGRectGetMinY(displayFrame);
  CGFloat displayMaxY  = CGRectGetMaxY(displayFrame);
  
  CGRect  clipFrame = self.clipFrame;
  CGFloat clipMinX  = CGRectGetMinX(clipFrame);
  CGFloat clipMaxX  = CGRectGetMaxX(clipFrame);
  CGFloat clipMinY  = CGRectGetMinY(clipFrame);
  CGFloat clipMaxY  = CGRectGetMaxY(clipFrame);
  
  BOOL clip = !CGSizeEqualToSize(clipFrame.size, CGSizeZero);
  if (clip)
  {
    displayMinX = MAX(displayMinX, clipMinX);
    displayMaxX = MIN(displayMaxX, clipMaxX);
    displayMinY = MAX(displayMinY, clipMinY);
    displayMaxY = MIN(displayMaxY, clipMaxY);
  }

  CGRect  anchorRect = self.anchor;
  CGFloat anchorMinX = CGRectGetMinX(anchorRect);
  CGFloat anchorMaxX = CGRectGetMaxX(anchorRect);
  CGFloat anchorMidY = CGRectGetMidY(anchorRect);
  
  UIEdgeInsets margins = self.properties.margins;
  CGFloat enchroachment = self.properties.enchroachment;
  
  if (direction == SGPopoverArrowDirectionLeft)
  {
    if (anchorMaxX > displayMinX)
      arrowOrigin.x = anchorMaxX;
    else
      arrowOrigin.x = displayMinX;
    
    CGFloat arrowMaxX = arrowOrigin.x + arrowSize.width;    
    if (clip && arrowMaxX > clipMaxX)
      arrowSize.width -= (arrowMaxX - clipMaxX); 
    
    // popover is to the right of arrow origin but adjusted so that left margin 
    // becomes the arrow width
    popoverOrigin.x = arrowOrigin.x + arrowSize.width - margins.left;

    if (clip)
    {
      // make sure popover fits within within clip frame, if not adjust width
      //
      CGFloat popoverMaxX = popoverOrigin.x + popoverSize.width - (margins.right * enchroachment);
      
      if (popoverMaxX > clipMaxX)
        popoverSize.width -= (popoverMaxX - clipMaxX);
        
      // special case where popover really shouldn't be drawn because only margins which 
      // should disappear are in bounds 
      if ((arrowSize.width < margins.left) && (margins.left - arrowSize.width > popoverSize.width))
        popoverSize.width = 0;
    }
  }
  else  // direction is right
  {
    if (anchorMinX < displayMaxX)
      arrowOrigin.x = anchorMinX;
    else
      arrowOrigin.x = displayMaxX;
    arrowOrigin.x -= arrowSize.width;
    
    if (clip && arrowOrigin.x < clipMinX)
    {
      arrowSize.width -= (clipMinX - arrowOrigin.x); 
      arrowOrigin.x = clipMinX;
    }
    
    // adjust offset so that the right margin becomes the arrow width
    popoverOrigin.x = arrowOrigin.x + margins.right - popoverSize.width;

    if (clip)
    {
      // make sure popover can fit within display frame, if not then adjust size
      //
      CGFloat popoverMinX = popoverOrigin.x - (margins.left * enchroachment);
      
      if (popoverMinX < clipMinX)
      {
        popoverSize.width -= (clipMinX - popoverMinX);
        popoverOrigin.x = clipMinX;
      }
        
      // special case where popover really shouldn't be drawn because only margins which 
      // should disappear are in bounds 
      if ((arrowSize.width < margins.right) && 
          (margins.right - arrowSize.width > popoverSize.width))
        popoverSize.width = 0;

    }
  }

  
  // start with placing middle of popover vertically aligned with middle of anchor
  popoverOrigin.y = anchorMidY - popoverMidY;

  if (popoverOrigin.y < displayMinY)
  {
    // the popover is going out of bounds on the top, so move the top into bounds
    popoverOrigin.y = displayMinY;
  }
  else if ((popoverOrigin.y + popoverSize.height) > displayMaxY)
  {
    // the popover is going of of bounds on the bottom, so move it up (but do 
    // allow the top to go out of bounds)
    popoverOrigin.y = MAX(displayMaxY - popoverSize.height, displayMinY);
  }
  
  
  // now determine if popover will fit vertically 
  //
  CGFloat popoverMaxY = popoverOrigin.y + popoverSize.height;
  if (popoverMaxY > displayMaxY)
  {
    CGFloat topEnchroachment    = margins.top * enchroachment;
    CGFloat bottomEnchroachment = margins.bottom * enchroachment;
    
    CGFloat totalEnchroachment  = topEnchroachment + bottomEnchroachment;
    
    if ((popoverMaxY - totalEnchroachment) <= displayMaxY)
    {
      // popover will fit with allowed enchroachment
      
      // determine top enchroachment based on its percentage of the total enchroachment
      CGFloat enchroachmentNeeded = popoverMaxY - displayMaxY;
      topEnchroachment = enchroachmentNeeded * (topEnchroachment / totalEnchroachment);
      
      popoverOrigin.y -= topEnchroachment;
    }
    else 
    {
      popoverOrigin.y -= topEnchroachment;
      popoverMaxY += topEnchroachment;
      
      if (clip && (popoverMaxY > clipMaxY))
      {
        popoverMaxY += bottomEnchroachment;
        popoverSize.height -= (popoverMaxY - clipMaxY);
        
        // since we adjusted size, need to adjust bottom margin for calculating arrow offset
        //   don't need to adjust top margin cause that is handled by a negative origin
        margins.bottom -= bottomEnchroachment;
      }
    }
  }

  // start arrow at middle of anchor  
  arrowOrigin.y = anchorMidY - (arrowSize.height / 2);
  
  // make sure arrow is not positioned outside popover
  //
  CGFloat minArrowOffsetY = MIN(popoverOrigin.y + margins.top, displayMaxY);
  if (arrowOrigin.y < minArrowOffsetY)
  {
    arrowOrigin.y = minArrowOffsetY;
  }
  else
  {
    CGFloat maxArrowOffsetY = 
      popoverOrigin.y + popoverSize.height - margins.bottom - arrowSize.height;
    maxArrowOffsetY = MAX(maxArrowOffsetY, minArrowOffsetY);
    
    if (arrowOrigin.y > maxArrowOffsetY)
      arrowOrigin.y = maxArrowOffsetY;
  }
  
  if (clip)
  { 
    if ((arrowOrigin.y + arrowSize.height) > clipMaxY)
      arrowSize.height -= ((arrowOrigin.y + arrowSize.height) - clipMaxY);
  }
  
  arrowFrame->origin = arrowOrigin;
  arrowFrame->size   = arrowSize;
  popoverContentFrame->origin = popoverOrigin;
  popoverContentFrame->size   = popoverSize;
}


- (void) forVerticalDirection:(SGPopoverArrowDirection)direction 
    adjustPopoverContentFrame:(CGRect *)popoverContentFrame 
                andArrowFrame:(CGRect *)arrowFrame
{
  CGPoint arrowOrigin   = CGPointZero;
  CGSize  arrowSize     = arrowFrame->size;
  CGPoint popoverOrigin = CGPointZero;
  CGSize  popoverSize   = popoverContentFrame->size;  
  CGFloat popoverMidX = popoverSize.width / 2;
  
  CGRect  displayFrame = self.displayFrame;
  CGFloat displayMinX  = CGRectGetMinX(displayFrame);
  CGFloat displayMaxX  = CGRectGetMaxX(displayFrame);
  CGFloat displayMinY  = CGRectGetMinY(displayFrame);
  CGFloat displayMaxY  = CGRectGetMaxY(displayFrame);
  
  CGRect  clipFrame = self.clipFrame;
  CGFloat clipMinX  = CGRectGetMinX(clipFrame);
  CGFloat clipMaxX  = CGRectGetMaxX(clipFrame);
  CGFloat clipMinY  = CGRectGetMinY(clipFrame);
  CGFloat clipMaxY  = CGRectGetMaxY(clipFrame);
  
  BOOL clip = !CGSizeEqualToSize(clipFrame.size, CGSizeZero);
  if (clip)
  {
    displayMinX = MAX(displayMinX, clipMinX);
    displayMaxX = MIN(displayMaxX, clipMaxX);
    displayMinY = MAX(displayMinY, clipMinY);
    displayMaxY = MIN(displayMaxY, clipMaxY);
  }
  
  CGRect  anchorRect = self.anchor;
  CGFloat anchorMidX = CGRectGetMidX(anchorRect);
  CGFloat anchorMinY = CGRectGetMinY(anchorRect);
  CGFloat anchorMaxY = CGRectGetMaxY(anchorRect);
  
  UIEdgeInsets margins = self.properties.margins;
  CGFloat enchroachment = self.properties.enchroachment;

  if (direction == SGPopoverArrowDirectionUp)
  {
    if (anchorMaxY > displayMinY)
      arrowOrigin.y = anchorMaxY;
    else
      arrowOrigin.y = displayMinY;
      
    CGFloat arrowMaxY = arrowOrigin.y + arrowSize.height;    
    if (clip && arrowMaxY > clipMaxY)
      arrowSize.height -= (arrowMaxY - clipMaxY); 

    // popover is below the arrow origin but adjusted so that top margin becomes the arrow width
    popoverOrigin.y = arrowOrigin.y + arrowSize.height - margins.top;
    
    if (clip)
    {
      // make sure popover can fit with within display frame, if not adjust height
      //
      CGFloat popoverMaxY = popoverOrigin.y + popoverSize.height - (margins.bottom * enchroachment);
      
      if (popoverMaxY > clipMaxY)
        popoverSize.height -= (popoverMaxY - clipMaxY);
        
      // special case where popover really shouldn't be drawn because only margins which 
      // should disappear are in bounds 
      if ((arrowSize.height < margins.top) && (margins.top - arrowSize.height) > popoverSize.height)
        popoverSize.height = 0;
    }
  }
  else  // direction is down
  {
    if (anchorMinY < displayMaxY)
      arrowOrigin.y = anchorMinY;
    else
      arrowOrigin.y = displayMaxY;
    arrowOrigin.y -= arrowSize.height;
    
    if (clip && (arrowOrigin.y < clipMinY))
    {
      arrowSize.height -= (clipMinY - arrowOrigin.y);
      arrowOrigin.y = clipMinY;
    }
    
    // popover is above the arrow origin but adjusted so that bottom margin becomes the arrow width
    popoverOrigin.y = arrowOrigin.y + margins.bottom - popoverSize.height;
    
    if (clip)
    {
      // make sure popover can fit with within display frame, if not adjust height
      //
      CGFloat popoverMinY = popoverOrigin.y - (margins.bottom * enchroachment);
      
      if (popoverMinY < clipMinY)
      {
        popoverSize.height -= (clipMinY - popoverMinY);
        popoverOrigin.y = clipMinY;
      }

      // special case where popover really shouldn't be drawn because only margins which 
      // should disappear are in bounds 
      if ((arrowSize.height < margins.bottom) && 
          (margins.bottom - arrowSize.height > popoverSize.height))
        popoverSize.height = 0;
    }
  }
    
  
  // start with placing middle of popover horizontally aligned with middle of anchor
  popoverOrigin.x = anchorMidX - popoverMidX;
  
  if (popoverOrigin.x < displayMinX)
  {
    // the popover is going out of bounds to the left, so adjust it back into bounds
    popoverOrigin.x = displayMinX;
  }
  else if ((popoverOrigin.x + popoverSize.width) >displayMaxX)
  {
    // the popover is going of of bounds to the right, so move it left but do
    // not allow the left side to go out of bounds 
    popoverOrigin.x = MAX(displayMaxX - popoverSize.width, displayMinX);
  }
  
  // now determine if popover will fit horizontally
  //
  CGFloat popoverMaxX = popoverOrigin.x + popoverSize.width;
  if (popoverMaxX > displayMaxX)
  {
    CGFloat leftEnchroachment  = margins.left * enchroachment;
    CGFloat rightEnchroachment = margins.right * enchroachment;
    
    CGFloat totalEnchroachment  = leftEnchroachment + rightEnchroachment;
    
    if ((popoverMaxX - totalEnchroachment) <= displayMaxX)
    {
      // popover will fit with allowed enchroachment
      
      // determine left enchroachment based on its percentage of the total enchroachment
      CGFloat enchroachmentNeeded = popoverMaxX - displayMaxX;
      leftEnchroachment = enchroachmentNeeded * (leftEnchroachment / totalEnchroachment);
      
      popoverOrigin.x -= leftEnchroachment;
    }
    else 
    {
      popoverOrigin.x -= leftEnchroachment;
      popoverMaxX += leftEnchroachment;
      
      if (clip && (popoverMaxX > clipMaxX))
      {
        popoverMaxX += rightEnchroachment;
        popoverSize.width -= (popoverMaxX - clipMaxX);
        
        // since we adjusted size, need to adjust right margin for calculating arrow offset
        //   don't need to adjust left margin cause that is handled by a negative origin
        margins.right -= rightEnchroachment;
      }
    }
  }
  
  // start arrow at middle of anchor  
  arrowOrigin.x = anchorMidX - (arrowSize.width / 2);
  
  // make sure arrow is not positioned outside popover
  //
  CGFloat minArrowOffsetX = MIN(popoverOrigin.x + margins.left, displayMaxX);
  if (arrowOrigin.x < minArrowOffsetX)
  {
    arrowOrigin.x = minArrowOffsetX;
  }
  else
  {
    CGFloat maxArrowOffsetX = popoverOrigin.x + popoverSize.width - margins.right - arrowSize.width;
    maxArrowOffsetX = MAX(maxArrowOffsetX, minArrowOffsetX);
    
    if (arrowOrigin.x > maxArrowOffsetX)
      arrowOrigin.x = maxArrowOffsetX;
  }
  
  if (clip)
  {
    if ((arrowOrigin.x + arrowSize.width) > clipMaxX)
      arrowSize.width -= ((arrowOrigin.x + arrowSize.width) - clipMaxX);
  }
  
  arrowFrame->origin = arrowOrigin;
  arrowFrame->size   = arrowSize;
  popoverContentFrame->origin = popoverOrigin;
  popoverContentFrame->size   = popoverSize;
}


- (void) setupViewsForPopoverFrame:(CGRect)popoverFrame
                           bgImage:(UIImage *)bgImage

{  
  // view hierarchy is as follows:
  //
  // this view (container view)
  //   popover view (contains popover image as bgimage and enforces clipping)
  //     content view (users content)

  // setup container view (this view) 
  //
  CGRect containerViewFrame = CGRectZero;  
  if (!CGSizeEqualToSize(self.overlayFrame.size, CGSizeZero))
  {
    // set frame to modal overlay frame, but make sure frame can hold the popover 
    containerViewFrame = CGRectUnion(self.overlayFrame, popoverFrame);
  }
  else
  {
    containerViewFrame = popoverFrame;
  }
  self.frame = containerViewFrame;

  // setup popover view
  //  
  // adjust popover origin to be relative to this container views origin
  popoverFrame.origin.x -= containerViewFrame.origin.x;
  popoverFrame.origin.y -= containerViewFrame.origin.y;

  UIView* popoverView = [[[UIView alloc] initWithFrame:popoverFrame] autorelease];
  
  popoverView.clipsToBounds = YES;
  popoverView.userInteractionEnabled = YES;
    
  // for transparency to work, the opaque call must come after setting backgroundColor
  popoverView.backgroundColor = [UIColor colorWithPatternImage:bgImage];
  popoverView.opaque = NO;
  
  if (self.popoverView != nil)
  {
    [self.contentView removeFromSuperview];
    [self.popoverView removeFromSuperview];    
  }
  
  [popoverView addSubview:self.contentView];
  [self addSubview:popoverView];
  
  self.popoverView = popoverView;    
    
  // setup content view
  //
  UIEdgeInsets margins = self.properties.margins;
  UIEdgeInsets insets  = self.properties.contentInsets;

  CGFloat contentWidth  = 
    popoverFrame.size.width - margins.left - insets.left - insets.right - margins.right;
  CGFloat contentHeight = 
    popoverFrame.size.height - margins.top - insets.top - insets.bottom - margins.bottom;
    
  self.contentView.frame = CGRectMake(margins.left + insets.left, margins.right + insets.right, 
                                      contentWidth, contentHeight);  
  
  self.contentView.backgroundColor = [UIColor clearColor];
  self.contentView.clipsToBounds = YES;
}

@end
