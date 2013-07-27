//
//  SGRatingController.h
//  SeaGlass
//
//  Copyright (c) 2011 Ken Joyner.
//  http://kjoyner.com
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

#import "SGRatingControl.h"

@interface SGRatingController : UIViewController 
{
  SGRatingControl* i_ratingControl;
  UILabel* i_currentRatingLabel;
}

@property(nonatomic, strong) IBOutlet SGRatingControl* ratingControl;
@property(nonatomic, strong) IBOutlet UILabel* currentRatingLabel;

- (IBAction) ratingChanged;

@end
