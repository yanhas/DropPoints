//
//  DropPointsTests.m
//  DropPointsTests
//
//  Created by Yaniv Hasbani on 3/25/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//
#import <GoogleMaps/GoogleMaps.h>
#import <XCTest/XCTest.h>
#import "DPAPIManager.h"

@interface DropPointsTests : XCTestCase

@end

@implementation DropPointsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
-(void)test_locationChange {
  CLLocation *base = [[CLLocation alloc] initWithLatitude:38.44 longitude:39.21];
  CLLocation *changing = [[CLLocation alloc] initWithLatitude:38.44 longitude:39.21];
  
  NSString *baseStr = [DPAPIManager reverseGeocoding:base];
  NSString *changeStr = [DPAPIManager reverseGeocoding:changing];
  
  XCTAssert([baseStr isEqualToString:changeStr], @"Not equal");
  
  //Small change longtitude
  changing = [[CLLocation alloc] initWithLatitude:38.44 longitude:39.20];
  changeStr = [DPAPIManager reverseGeocoding:changing];
  
  //Small change latitude
  changing = [[CLLocation alloc] initWithLatitude:38.43 longitude:39.21];
  changeStr = [DPAPIManager reverseGeocoding:changing];
  
//  XCTAssertFalse([baseStr isEqualToString:changeStr], @"Not equal");
  
  //Small change longtitude
  changing = [[CLLocation alloc] initWithLatitude:38.44 longitude:39.20];
  changeStr = [DPAPIManager reverseGeocoding:changing];
  
  //Big change latitude
  changing = [[CLLocation alloc] initWithLatitude:12.43 longitude:39.21];
  changeStr = [DPAPIManager reverseGeocoding:changing];
  XCTAssertFalse([baseStr isEqualToString:changeStr], @"Not equal");
  
  //Big change longtitude - No such place :)
  changing = [[CLLocation alloc] initWithLatitude:38.44 longitude:10.21];
  changeStr = [DPAPIManager reverseGeocoding:changing];
  XCTAssertFalse([baseStr isEqualToString:changeStr], @"Not equal");
}
@end
