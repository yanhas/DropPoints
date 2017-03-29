//
//  DPMarker.m
//  DropPoints
//
//  Created by Yaniv Hasbani on 3/25/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "CLLocation+DPLocation.h"
#import "MapViewController.h"
#import "DPMapDataModel.h"
#import "DPAPIManager.h"
#import "DPMarker.h"
#import "DPUtils.h"

@implementation DPMarker

-(NSString *)description {
  return [NSString stringWithFormat:@"latitude = %f, longtitude = %f", self.position.latitude, self.position.longitude];
}

+(instancetype)addMarker:(CLLocation *)location {
  // Add a custom 'glow' marker with a pulsing blue shadow on Sydney.
  
  DPMarker *marker = [DPMarker new];
  
  NSString *title = [DPAPIManager reverseGeocoding:location];
  marker.title = title;
  marker.iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glow-marker"]];
  marker.position = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
  marker.iconView.contentMode = UIViewContentModeCenter;
  CGRect oldBound = marker.iconView.bounds;
  CGRect bound = oldBound;
  bound.size.width *= 2;
  bound.size.height *= 2;
  marker.iconView.bounds = bound;
  marker.groundAnchor = CGPointMake(0.5, 0.75);
  marker.infoWindowAnchor = CGPointMake(0.5, 0.25);
  
  return marker;
}

-(void)displayOnMap:(GMSMapView *)mapView {
  UIView *glow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glow-marker"]];
  glow.layer.shadowColor = [UIColor blueColor].CGColor;
  glow.layer.shadowOffset = CGSizeZero;
  glow.layer.shadowRadius = 8.0;
  glow.layer.shadowOpacity = 1.0;
  glow.layer.opacity = 0.0;
  [self.iconView addSubview:glow];
  glow.center = CGPointMake(self.iconView.bounds.size.width/2, self.iconView.bounds.size.height/2);
  self.map = mapView;
  [UIView animateWithDuration:1.0
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut | UIViewKeyframeAnimationOptionAutoreverse |
   UIViewKeyframeAnimationOptionRepeat
                   animations:^{
                     glow.layer.opacity = 1.0;
                   }
                   completion:^(BOOL finished) {
                     self.tracksViewChanges = YES;
                   }];
}

-(void)drawLineTo:(DPMarker *)marker {
  NSString *encodedPath = [DPAPIManager getEncodedPathFromCurrentTo:[CLLocation createFrom2DCL:marker.position]
                                                                 to:[CLLocation createFrom2DCL:self.position]];
  if (!encodedPath) {
    return;
  }
  GMSPath *path =[GMSPath pathFromEncodedPath:encodedPath];
  GMSPolyline *singleLine = [GMSPolyline polylineWithPath:path];
  singleLine.strokeWidth = 7;
  singleLine.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
  singleLine.map = self.map;
  [DPMapDataModel sharedData].path = singleLine;
}
@end
