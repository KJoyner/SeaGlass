//
//  SGPopoverView.h
//  SeaGlass
//
//  Copyright (c) 2011 Ken Joyner.
//  http://kjoyner.com
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

#import "SGPopoverViewProperties.h"

@interface SGPopoverView : UIView

@property(nonatomic, assign) CGRect     anchor;
@property(nonatomic, assign) CGRect     clipFrame;
@property(nonatomic, assign) CGSize     contentSize;
@property(nonatomic, retain) UIView*    contentView;
@property(nonatomic, assign) CGRect     displayFrame;
@property(nonatomic, assign) CGRect     overlayFrame;
@property(nonatomic, retain) NSArray*   passthroughViews;
@property(nonatomic, assign) NSUInteger permittedArrowDirections;

@property(nonatomic, retain) SGPopoverViewProperties* properties;
@property(nonatomic, assign, readonly) SGPopoverArrowDirection arrowDirection;

@property(nonatomic, assign, readonly) CGRect popoverFrame;

@end
