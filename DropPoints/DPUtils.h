//
//  DPUtils.h
//  DropPoints
//
//  Created by Yaniv Hasbani on 3/25/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface DPUtils : NSObject
/**
 * check if since the last location update, the location has change by more than THRESHOLD
 *
 * @param location The new location
 *
 * @result YES if location has changed
 */
+(BOOL)checkIfLocationHasChanged:(CLLocation *)location;

@end
