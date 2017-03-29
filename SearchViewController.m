//
//  SearchViewController.m
//  DropPoints
//
//  Created by Yaniv Hasbani on 3/26/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

#import "CLLocation+DPLocation.h"
#import "SearchViewController.h"
#import "MapViewController.h"
#import "DPMapDataModel.h"
#import "DPAPIManager.h"
#import "DPMarker.h"
#import "DPUtils.h"

@interface SearchViewController ()
@property (nonatomic, strong) NSMutableArray *dataForSearchTableView;
@property (nonatomic, strong) NSMutableArray<DPMarker *> *searchedPoints;;
@end

@implementation SearchViewController
{
  
}

#pragma mark -
#pragma mark Lifecycle
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  _dataForSearchTableView = [NSMutableArray new];
  
  _searchedPoints = [NSMutableArray new];
  
  UISwipeGestureRecognizer * swipe =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe:)];
  [swipe setNumberOfTouchesRequired:1];
  swipe.direction= UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
  _searchTableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  [_searchTableView setUserInteractionEnabled:YES];
  [_searchTableView addGestureRecognizer:swipe];
  _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, 50)];
  _searchBar.delegate = self;
  _searchTableView.delegate = self;
  _searchTableView.frame = CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
  _searchTableView.dataSource = self;
  
  [_searchTableView addSubview:_searchBar];
  [self.view addSubview:_searchTableView];
  
}

-(void)viewDidAppear:(BOOL)animated {
}

-(void)viewWillDisappear:(BOOL)animated {
  
}

#pragma mark -
#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_dataForSearchTableView count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"Cell";
  
  UITableViewCell *cell = [_searchTableView dequeueReusableCellWithIdentifier:cellId];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:cellId];
  }
  
  cell.textLabel.adjustsFontSizeToFitWidth = YES;
  
  if (indexPath.row) {
    cell.textLabel.text = [_dataForSearchTableView objectAtIndex:indexPath.row-1];
  }
  
  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *addrStr = [_dataForSearchTableView objectAtIndex:indexPath.row-1];
  CLLocation *l = [DPAPIManager getAddressFromString:addrStr];
  if (l) {
    dispatch_async(dispatch_get_main_queue(), ^{
      //Remove old markers
      for (DPMarker * marker in _searchedPoints) {
        marker.map = nil;
      }
      [_searchedPoints removeAllObjects];
      //Create the new found marker
      DPMarker *m = [DPMarker addMarker:l];
      [m displayOnMap:[((MapViewController *)self.parentViewController) mapView]];
      [m drawLineTo:[DPMapDataModel sharedData].currentLocation];
      m.map.camera = [GMSCameraPosition cameraWithTarget:m.position
                                                    zoom:14];
      [_searchedPoints addObject:m];
      [self.view removeFromSuperview];
    });
  } else {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Cannot find address" message:[NSString stringWithFormat:@"We are sorry, but we cannot find loaction for address = %@", addrStr] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
#pragma clang diagnostic pop
  }
}

#pragma mark -
#pragma mark UISearchBarDelegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  [_dataForSearchTableView removeAllObjects];
  NSArray *data = [DPAPIManager autocompleteText:searchText
                                        location:[CLLocation createFrom2DCL:[DPMapDataModel sharedData].currentLocation.position]];
  if (data) {
    for (NSDictionary *location in data) {
      if ([location objectForKey:@"description"]){
        [_dataForSearchTableView addObject:location[@"description"]];
      }
    }
    [self.searchTableView reloadData];
  }
}

#pragma mark -
#pragma mark Action
-(void)swipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
  [self.view removeFromSuperview];
}


@end
