//
//  DPMarker.h
//  DropPoints
//
//  Created by Yaniv Hasbani on 3/25/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import <Foundation/Foundation.h>

@interface DPMarker : GMSMarker

/**
 * create a new marker with it's title (Calls reverseGeocoding)
 *
 * @param location The location in which the marker should be presented
 *
 * @result a new marker
 */
+(instancetype)addMarker:(CLLocation *)location;

/**
 * add marker to map
 *
 * @param mapView The map which we wish to add the marker on
 *
 */
-(void)displayOnMap:(GMSMapView *)mapView;

/**
 * draw a walking path from self to marker, if exists
 *
 * @param marker The marker we wish to get to
 *
 */
-(void)drawLineTo:(DPMarker *)marker;

@end
