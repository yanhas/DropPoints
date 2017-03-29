//
//  DPUtils.m
//  DropPoints
//
//  Created by Yaniv Hasbani on 3/25/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

#import "CLLocation+DPLocation.h"
#import "MapViewController.h"
#import "DPAPIManager.h"
#import "DPUtils.h"


@implementation DPUtils

#pragma mark -
#pragma mark APIs
+(BOOL)checkIfLocationHasChanged:(CLLocation *)location {
  static CLLocation *lastLocation;
  if ([location compareLocation:lastLocation]) {
    return NO;
  }
  
  lastLocation = location;
  
  return YES;
}

@end
