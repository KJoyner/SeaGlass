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

#import "SGSynthesizeSingleton.h"

static NSString* kSGBundleName = @"SeaGlass";

@interface SGBundle : NSBundle
{
  
}

+ sharedSGBundle;

@end

@implementation SGBundle

SG_SYNTHESIZE_SINGLETON_FOR_CLASS(SGBundle)

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
