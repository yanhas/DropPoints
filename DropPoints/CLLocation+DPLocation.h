//
//  CLLocation+DPLocation.h
//  DropPoints
//
//  Created by Yaniv Hasbani on 3/25/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface CLLocation (DPLocation)

-(BOOL)compareLocation:(CLLocation *)loction;
-(BOOL)compareExactLocation:(CLLocation *)location;
+(CLLocation *)createFrom2DCL:(CLLocationCoordinate2D)location;

@end
