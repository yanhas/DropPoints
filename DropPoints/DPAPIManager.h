//
//  DPAPIManager.h
//  DropPoints
//
//  Created by Yaniv Hasbani on 3/25/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import <Foundation/Foundation.h>

@interface DPAPIManager : NSObject
/**
 * Get the description for a specific location
 *
 * @param location The location required description
 *
 * @result The description
 */
+(NSString *)reverseGeocoding:(CLLocation *)location;

/**
 * Get nearby locations by location and radius
 *
 * @param location the required location
 * @param radius the redius in which to search
 *
 * @result An array of intresting location next to you
 */
+(NSArray *)getNearbyListByLocation:(CLLocation *)location radius:(NSNumber *)radius;

/**
 * Autocomplete by prefix and location
 *
 * @param prefix the input the user gave on the search so far
 * @param location try to keep in the proximity of this location (50m radius)
 *
 * @result An array of locations that match the prefix and location
 */
+(NSArray *)autocompleteText:(NSString *)prefix location:(CLLocation *)location;

/**
 * Get location from description
 *
 * @param addressStr address as string
 *
 * @result location, if exists, that match the description
 */
+(CLLocation *)getAddressFromString:(NSString *)addressStr;

/**
 * Get encoded path between per of points
 * 
 * @param marker The starting point
 * @param toLocation the en dpoint
 *
 * @result encoded string path
 */
+(NSString *)getEncodedPathFromCurrentTo:(CLLocation *)marker to:(CLLocation *)toLocation;

@end
