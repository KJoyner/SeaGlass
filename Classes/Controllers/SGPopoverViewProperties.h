//
//  SGPopoverViewProperties.h
//  SeaGlass
//
//  This idea of using a view property class to handle properties related to how a popover looks is
//  from the WEPopover project, see https://github.com/werner77/WEPopover
//
//  Copyright 2010 Werner IT Consultancy.
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

#import <UIKit/UIKit.h>

enum 
{
  SGPopoverArrowDirectionNone    = 0,
  SGPopoverArrowDirectionUp      = 1UL << 0,
  SGPopoverArrowDirectionDown    = 1UL << 1,
  SGPopoverArrowDirectionLeft    = 1UL << 2,
  SGPopoverArrowDirectionRight   = 1UL << 3,
  SGPopoverArrowDirectionAny     = SGPopoverArrowDirectionUp | SGPopoverArrowDirectionDown | 
                                   SGPopoverArrowDirectionLeft | SGPopoverArrowDirectionRight,
  SGPopoverArrowDirectionUnknown = NSUIntegerMax
};
typedef NSUInteger SGPopoverArrowDirection;

@interface SGPopoverViewProperties : NSObject
{
  NSString* i_bgImageName;
  NSInteger i_leftBgCapWidth;
  NSInteger i_topBgCapHeight;
  
  UIEdgeInsets i_margins;
  UIEdgeInsets i_contentInsets;
  
  CGFloat i_enchroachment;
  
  NSString* i_upArrowImageName;
  NSString* i_downArrowImageName;
  NSString* i_leftArrowImageName;
  NSString* i_rightArrowImageName;
}

@property(nonatomic, copy, readonly)   NSString* bgImageName;
@property(nonatomic, assign, readonly) NSInteger leftBgCapWidth;
@property(nonatomic, assign, readonly) NSInteger topBgCapHeight;

@property(nonatomic, assign) UIEdgeInsets margins;
@property(nonatomic, assign) UIEdgeInsets contentInsets;

@property(nonatomic, assign) CGFloat enchroachment;

@property(nonatomic, copy) NSString* upArrowImageName;
@property(nonatomic, copy) NSString* downArrowImageName;
@property(nonatomic, copy) NSString* leftArrowImageName;
@property(nonatomic, copy) NSString* rightArrowImageName;

- (void) setBackgroundImageName:(NSString *)name 
                   leftCapWidth:(NSInteger)leftCapWidth 
                   topCapHeight:(NSInteger)topCapHeight;

@end

