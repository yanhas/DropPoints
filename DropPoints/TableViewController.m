//
//  TableViewController.m
//  DropPoints
//
//  Created by Yaniv Hasbani on 3/25/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//
#import "TableViewController.h"
#import "MapViewController.h"
#import "DPMapDataModel.h"
#import "DPMarker.h"


@implementation TableViewController

#pragma mark -
#pragma mark LifeCycle
- (void)viewDidLoad {
  [super viewDidLoad];
  
  _tableViewObject = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  _tableViewObject.dataSource = self;
  _tableViewObject.delegate = self;
  
  UISwipeGestureRecognizer * swipe=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe:)];
  swipe.direction=UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
  [swipe setNumberOfTouchesRequired:1];
  
  [_tableViewObject addGestureRecognizer:swipe];
  [_tableViewObject setUserInteractionEnabled:YES];
  [self.view addSubview:_tableViewObject];
}

#pragma mark -
#pragma mark Gestures
-(void)swipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
  [self.view removeFromSuperview];
}

#pragma mark -
#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSArray *markers = [[DPMapDataModel sharedData] currentMarkers];
  return [markers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *cellId = @"Cell";
  
  UITableViewCell *cell = [_tableViewObject dequeueReusableCellWithIdentifier:cellId];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:cellId];
  }
  
  cell.textLabel.adjustsFontSizeToFitWidth = YES;
  
  NSArray *markers = [[DPMapDataModel sharedData] currentMarkers];
  if (indexPath.row) {
    DPMarker *marker = [markers objectAtIndex:indexPath.row];
    cell.textLabel.text = marker.title;
  } else {
    DPMarker *marker = [markers objectAtIndex:0];
    cell.textLabel.text = marker.title;
  }
  
  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSArray *markers = [[DPMapDataModel sharedData] currentMarkers];
  DPMarker *marker = [markers objectAtIndex:indexPath.row];
  [marker drawLineTo:[DPMapDataModel sharedData].currentLocation];
  marker.map.camera = [GMSCameraPosition cameraWithTarget:marker.position
                                                     zoom:14];
  
  [self.view removeFromSuperview];
}

@end
