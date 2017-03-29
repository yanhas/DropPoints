//
//  CLLocation+DPLocation.m
//  DropPoints
//
//  Created by Yaniv Hasbani on 3/25/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

#import "CLLocation+DPLocation.h"

static float THRESHOLD_FOR_MOVMENT = 0.001;

@implementation CLLocation (DPLocation)


+(CLLocation *)createFrom2DCL:(CLLocationCoordinate2D)location {
  return [[CLLocation alloc] initWithLatitude:location.latitude
                                    longitude:location.longitude];
}
-(BOOL)compareLocation:(CLLocation *)location {
  return (fabs(self.coordinate.latitude - location.coordinate.latitude) < THRESHOLD_FOR_MOVMENT) ||
            (fabs(self.coordinate.longitude - location.coordinate.longitude) < THRESHOLD_FOR_MOVMENT);
}

-(BOOL)compareExactLocation:(CLLocation *)location {
  return (self.coordinate.latitude == location.coordinate.latitude) &&
            (self.coordinate.longitude == location.coordinate.longitude);
}

@end
