//
//  DPMapDataModel.m
//  DropPoints
//
//  Created by Yaniv Hasbani on 3/29/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//
#import <GoogleMaps/GoogleMaps.h>

#import "DPMapDataModel.h"
#import "DPMarker.h"
#import "DPUtils.h"

static DPMapDataModel *singelton;
@implementation DPMapDataModel

+(instancetype)sharedData {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    singelton = [DPMapDataModel new];
    singelton.currentMarkers = [NSArray new];
  });
  
  return singelton;
}

@end
