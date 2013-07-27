//
//  SGPopoverViewProperties.m
//  SeaGlass
//
//  This idea of using a view property class to handle properties related to how a popover looks is
//  from the WEPopover project, see https://github.com/werner77/WEPopover
//
//  Copyright 2010 Werner IT Consultancy.
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

#import "SGPopoverViewProperties.h"

#import "SGGlobalPaths.h"


static NSString* kImageType = @"png";

// These constants are determined by the popoverBg.png image file and are image dependent
static NSString* kBgImageName = @"SGPopoverBg";
static CGFloat   kBgCapSize = 31.0;
static CGFloat   kBgMargin  = 13.0;

static NSString* kUpArrowImageName    = @"SGPopoverArrowUp";
static NSString* kDownArrowImageName  = @"SGPopoverArrowDown";
static NSString* kLeftArrowImageName  = @"SGPopoverArrowLeft";
static NSString* kRightArrowImageName = @"SGPopoverArrowRight";

static CGFloat kContentInset = 4.0f;

@interface SGPopoverViewProperties ()

@property(nonatomic, copy)   NSString* bgImageName;
@property(nonatomic, assign) NSInteger topBgCapHeight;
@property(nonatomic, assign) NSInteger leftBgCapWidth;

@end

 
@implementation SGPopoverViewProperties

@synthesize bgImageName    = i_bgImageName;
@synthesize leftBgCapWidth = i_leftBgCapWidth;
@synthesize topBgCapHeight = i_topBgCapHeight;

@synthesize margins       = i_margins;
@synthesize contentInsets = i_contentInsets;

@synthesize enchroachment = i_enchroachment;

@synthesize upArrowImageName    = i_upArrowImageName;
@synthesize downArrowImageName  = i_downArrowImageName;
@synthesize leftArrowImageName  = i_leftArrowImageName;
@synthesize rightArrowImageName = i_rightArrowImageName;
 
- (id) init
{
  self = [super init];
  if (self != nil)
  {
    i_bgImageName    = SGPathForBundleImageResource(kBgImageName, kImageType);
    i_leftBgCapWidth = kBgCapSize;
    i_topBgCapHeight = kBgCapSize;
    
    i_margins = 
      UIEdgeInsetsMake(kBgMargin, kBgMargin, kBgMargin, kBgMargin);
    
    i_contentInsets = UIEdgeInsetsMake(kContentInset, kContentInset, kContentInset, kContentInset);
    
    // by default, margins should not enchroach outside the display area
    i_enchroachment = 0.0f;
    
    i_upArrowImageName    = SGPathForBundleImageResource(kUpArrowImageName, kImageType);
    i_downArrowImageName  = SGPathForBundleImageResource(kDownArrowImageName, kImageType);
    i_leftArrowImageName  = SGPathForBundleImageResource(kLeftArrowImageName, kImageType);
    i_rightArrowImageName = SGPathForBundleImageResource(kRightArrowImageName, kImageType);
  }  
  return self;
}




- (void) setBackgroundImageName:(NSString *)name 
                   leftCapWidth:(NSInteger)leftCapWidth 
                   topCapHeight:(NSInteger)topCapHeight
{
  self.bgImageName    = name;
  self.leftBgCapWidth = leftCapWidth;
  self.topBgCapHeight = topCapHeight;
}

@end

