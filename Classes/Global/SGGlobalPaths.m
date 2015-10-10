//
//  SGGlobalPaths.m
//  SeaGlass
//
//  Copyright (c) 2011 Ken Joyner.
//  http://kjoyner.com
//
//  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//

#import "SGGlobalPaths.h"

static NSString* kSGBundleName = @"SeaGlass";

@interface SGBundle : NSBundle
{
  
}

+ sharedSGBundle;

@end

@implementation SGBundle

+ (id)sharedSGBundle
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (id)init
{
  NSString* mainBundleResourcePath = [[NSBundle mainBundle] resourcePath];
  NSString* bundlePath = [NSString stringWithFormat:@"%@/%@.bundle", mainBundleResourcePath, kSGBundleName];
  
  self = [super initWithPath:bundlePath];
  return self;
}

@end

NSString* SGPathForBundleImageResource(NSString* imageName, NSString* typeName)
{
  SGBundle* bundle = [SGBundle sharedSGBundle];

  NSString* path = [bundle pathForResource:imageName ofType:typeName inDirectory:@"Images"];
  return path;
}
