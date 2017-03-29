//
//  DPMapDataModel.h
//  DropPoints
//
//  Created by Yaniv Hasbani on 3/29/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation,DPMarker, GMSMapView, GMSPolyline;
@interface DPMapDataModel : NSObject

+(instancetype)sharedData;

@property (nonatomic, strong) DPMarker *currentLocation;
@property (nonatomic, strong) NSArray<DPMarker *> *currentMarkers;
@property (nonatomic, strong) GMSPolyline *path;
@end
