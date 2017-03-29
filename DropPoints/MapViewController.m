//
//  ViewController.m
//  DropPoints
//
//  Created by Yaniv Hasbani on 3/25/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>

#import "CLLocation+DPLocation.h"
#import "SearchViewController.h"
#import "TableViewController.h"
#import "MapViewController.h"
#import "DPMapDataModel.h"
#import "DPAPIManager.h"
#import "DPMarker.h"
#import "DPUtils.h"

static NSString const * kNormalType = @"Normal";
static NSString const * kSatelliteType = @"Satellite";
static NSString const * kHybridType = @"Hybrid";
static NSString const * kTerrainType = @"Terrain";
typedef void(^displayMarker)(CLLocation *marker);

@interface MapViewController ()<GMSMapViewDelegate, CLLocationManagerDelegate>

@end

static MapViewController *singeltonMap;

@implementation MapViewController {
  UIView *_infoView;
  IBOutlet UIBarButtonItem *_rightBarButton;
  IBOutlet UIBarButtonItem *_leftBarButton;
  IBOutlet UINavigationBar *_navigationBar;
  BOOL _firstLocationUpdate;
  GMSMapView *_mapView;
  UISegmentedControl *_mapTypeSwitcher;
  TableViewController *_tableViewController;
  SearchViewController *_searchViewController;
}

#pragma mark -
#pragma mark APIs
-(GMSMapView *)mapView {
  return _mapView;
}

#pragma mark -
#pragma mark LifeCycle
- (void)viewDidLoad {
  [super viewDidLoad];
  
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                          longitude:151.2086
                                                               zoom:12];
  _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  _mapView.settings.myLocationButton = YES;
  
  // Listen to the myLocation property of GMSMapView.
  [_mapView addObserver:self
             forKeyPath:@"myLocation"
                options:NSKeyValueObservingOptionNew |
   NSKeyValueObservingOptionOld
                context:NULL];
  
  _mapView.delegate = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    _mapView.myLocationEnabled = YES;
    NSArray *types = @[kNormalType, kSatelliteType, kHybridType, kTerrainType];
    
    // Create a UISegmentedControl that is the navigationItem's titleView.
    _mapTypeSwitcher = [[UISegmentedControl alloc] initWithItems:types];
    _mapTypeSwitcher.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleBottomMargin;
    _mapTypeSwitcher.selectedSegmentIndex = 0;
    
    // Listen to touch events on the UISegmentedControl.
    [_mapTypeSwitcher addTarget:self action:@selector(didChangeSwitcher)
               forControlEvents:UIControlEventValueChanged];
    _navigationBar.items[0].titleView = _mapTypeSwitcher;
    [_mapView addSubview:_navigationBar];
  });
  
  self.view = _mapView;
}

-(void)dealloc {
  [_mapView removeObserver:self forKeyPath:@"myLocation"];
}

#pragma mark -
#pragma mark Actions
- (void)didChangeSwitcher {
  // Switch to the type clicked on.
  NSString *title =
  [_mapTypeSwitcher titleForSegmentAtIndex:_mapTypeSwitcher.selectedSegmentIndex];
  if ([kNormalType isEqualToString:title]) {
    _mapView.mapType = kGMSTypeNormal;
  } else if ([kSatelliteType isEqualToString:title]) {
    _mapView.mapType = kGMSTypeSatellite;
  } else if ([kHybridType isEqualToString:title]) {
    _mapView.mapType = kGMSTypeHybrid;
  } else if ([kTerrainType isEqualToString:title]) {
    _mapView.mapType = kGMSTypeTerrain;
  }
}

- (IBAction)revealNearby:(id)sender {
  if (!_tableViewController) {
    _tableViewController = [TableViewController new];
    _tableViewController.view.frame = self.view.bounds;
    [self addChildViewController:_tableViewController];
  }
  
  if (_searchViewController) {
    _searchViewController = nil;
  }
  
  [DPMapDataModel sharedData].path.map = nil;
  
  [self.view addSubview:_tableViewController.view];
  [self.view layoutSubviews];
}

-(void)revealSearch:(BOOL)animated {
  if (!_searchViewController) {
    _searchViewController = [SearchViewController new];
    _searchViewController.view.frame = self.view.bounds;
    [self addChildViewController:_searchViewController];
  }
  
  if (_tableViewController) {
    _tableViewController = nil;
  }
  [DPMapDataModel sharedData].path.map = nil;
  [self.view addSubview:_searchViewController.view];
}

#pragma mark - KVO updates
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if (!_firstLocationUpdate) {
    // If the first location update has not yet been recieved, then jump to that
    // location.
    _firstLocationUpdate = YES;
    CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
    _mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                     zoom:14];
  }
  
  __block CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
  __block NSMutableArray *nearbyToDisplay = [NSMutableArray new];
  displayMarker displayCurrennLocationBlock = ^void(CLLocation *location){
    //Display current marker
    DPMarker *marker = [DPMarker addMarker:location];
    NSArray *frames = @[[UIImage imageNamed:@"step1"],
                        [UIImage imageNamed:@"step2"],
                        [UIImage imageNamed:@"step3"],
                        [UIImage imageNamed:@"step4"],
                        [UIImage imageNamed:@"step5"],
                        [UIImage imageNamed:@"step6"],
                        [UIImage imageNamed:@"step7"],
                        [UIImage imageNamed:@"step8"]];
    marker.icon = [UIImage animatedImageWithImages:frames duration:0.8];
    marker.iconView = nil;
    [DPMapDataModel sharedData].currentLocation = marker;
    [_mapView clear];
    _mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                     zoom:14];
    [marker displayOnMap:_mapView];
    
    
    NSArray *apiData = [DPAPIManager getNearbyListByLocation:location radius:@(50000)];
    for (NSDictionary * nearby in apiData) {
      NSNumber *latitude = nearby[@"geometry"][@"location"][@"lat"];
      NSNumber *longtitude = nearby[@"geometry"][@"location"][@"lng"];
      CLLocation *nearbyLocation = [[CLLocation alloc] initWithLatitude:[latitude floatValue]
                                                              longitude:[longtitude floatValue]];
      [nearbyToDisplay addObject:[DPMarker addMarker:nearbyLocation]];
    }
    
    for (DPMarker *marker in nearbyToDisplay) {
      [marker displayOnMap:_mapView];
    }
    
    [DPMapDataModel sharedData].currentMarkers = [nearbyToDisplay copy];
  };
  
  if (location) {
    if ([DPUtils checkIfLocationHasChanged:location]) {
      if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          displayCurrennLocationBlock(location);
        });
      } else {
        displayCurrennLocationBlock(location);
      }
    }
  }
}

//
//- (UIView *)mapView:(GMSMapView *)mapView markerInfoContents:(GMSMarker *)marker {
//  // Show an info window with dynamic content - a simple background color animation.
//  NSString *title = [DPUtils reverseGeocoding:[CLLocation createFrom2DCL:marker.position]];
//  marker.title = title;
//  _infoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
//  UIView *infoView = _infoView;
//  marker.tracksInfoWindowChanges = YES;
//  UIColor *color = [UIColor colorWithHue:randf() saturation:1.f brightness:1.f alpha:1.0f];
//  _infoView.backgroundColor = [UIColor clearColor];
//  [UIView animateWithDuration:1.0
//                        delay:1.0
//                      options:UIViewAnimationOptionCurveLinear
//                   animations:^{
//                     infoView.backgroundColor = color;
//                   }
//                   completion:^(BOOL finished) {
//                     [UIView animateWithDuration:1.0
//                                           delay:0.0
//                                         options:UIViewAnimationOptionCurveLinear
//                                      animations:^{
//                                        infoView.backgroundColor = [UIColor clearColor];
//                                      }
//                                      completion:^(BOOL finished2) {
//                                        marker.tracksInfoWindowChanges = NO;
//                                      }];
//                   }];
//
//  return _infoView;
//}

@end
