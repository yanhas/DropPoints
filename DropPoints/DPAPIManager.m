//
//  DPAPIManager.m
//  DropPoints
//
//  Created by Yaniv Hasbani on 3/25/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

#import "DPAPIManager.h"

@interface NSString (HTTPRequestParameters)
-(NSString *)appendHTTPRequestParameters:(NSDictionary *)parameterDic;
-(NSString *)turnAddressStringToParamForAPI;
@end

@implementation DPAPIManager
#pragma mark -
#pragma mark Consts

const NSString *API_KEY = @"AIzaSyD69Fh_rgo72lzd8mOxXndW3lK0hX7mvas";
NSString * _Nonnull kSuccess = @"OK";


#pragma mark -
#pragma mark APIs
+(NSString *)reverseGeocoding:(CLLocation *)location {
  NSString *baseRequest = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&key=%@", location.coordinate.latitude, location.coordinate.longitude, API_KEY];
  
  baseRequest = [baseRequest appendHTTPRequestParameters:@{@"language" : @"iw"}];
  
  NSString *locationStr;
  NSDictionary *responseObject = [self makeSyncronicHTTPRequest:baseRequest];
  if (responseObject) {
    locationStr = responseObject[@"results"][0][@"formatted_address"];
  }
  
  return locationStr;
}

+(NSArray *)getNearbyListByLocation:(CLLocation *)location
                             radius:(NSNumber *)radius {
  NSString *baseRequest = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f", location.coordinate.latitude, location.coordinate.longitude];
  
  baseRequest = [baseRequest appendHTTPRequestParameters:@{@"language" : @"iw",
                                                           @"radius" : radius}];
  
  NSDictionary *responseObject = [self makeSyncronicHTTPRequest:baseRequest];
  if (!responseObject) {
      return nil;
  }
  
  return [responseObject[@"results"] copy];
}

+(NSArray *)autocompleteText:(NSString *)prefix
                    location:(CLLocation *)location {
  NSString *baseRequest = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@", prefix];
  
  //&types=(cities)
  //&language=pt_BR
  baseRequest = [baseRequest appendHTTPRequestParameters:@{
                                                          @"radius" : @(50),
                                                          @"location" : location,
                                                          @"language" : @"en"
                                                          }];
  NSDictionary *response = [self makeSyncronicHTTPRequest:baseRequest];
  if (!response) {
    return nil;
  }
  
  return [response objectForKey:@"predictions"];
}

+(CLLocation *)getAddressFromString:(NSString *)addressStr {
  NSString *baseRequest = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@", [addressStr turnAddressStringToParamForAPI]];
  
  baseRequest = [baseRequest appendHTTPRequestParameters:@{}];
  
  NSDictionary *response = [self makeSyncronicHTTPRequest:baseRequest];
  if (!response) {
      return nil;
  }
  
  NSDictionary<NSString *, NSNumber *> *coordinates = response[@"results"][0][@"geometry"][@"location"];
  if (!coordinates) {
    return nil;
  }
  
  return [[CLLocation alloc] initWithLatitude:[coordinates[@"lat"] doubleValue]
                                    longitude:[coordinates[@"lng"] doubleValue]];
}

+(NSString *)getEncodedPathFromCurrentTo:(CLLocation *)marker to:(CLLocation *)toLocation {
  NSString *baseRequest = [NSString stringWithFormat:
                           @"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=true",
                         marker.coordinate.latitude,
                         marker.coordinate.longitude,
                         toLocation.coordinate.latitude,
                         toLocation.coordinate.longitude];
  
  baseRequest = [baseRequest appendHTTPRequestParameters:@{@"mode": @"walking"}];
  NSDictionary *response = [self makeSyncronicHTTPRequest:baseRequest];
  if (!response) {
    return nil;
  }
  
  return response[@"routes"][0][@"overview_polyline"][@"points"];
}


#pragma mark -
#pragma mark Utils
+(NSDictionary *)makeSyncronicHTTPRequest:(NSString *)requestStr {
  __block NSDictionary *responseObject;
  dispatch_group_t group = dispatch_group_create();
  dispatch_group_enter(group);
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestStr]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
      if (error) {
        NSLog(@"Error in HTTP request = %@, error = %@", requestStr, error);
      } else {
        responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
          NSLog(@"Error in parsing json = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
          responseObject = nil;
        } else if (![responseObject[@"status"] isEqualToString:kSuccess]){
          NSLog(@"Error in HTTP response from server. Status = %@, request = %@", responseObject[@"status"], request);
          responseObject = nil;
        } else if  ([responseObject objectForKey:@"next_page_token"]) {
          //Need to add the next round of locations
          //I am assuming 20 is enough for this exercise...
        } else  {
          
        }
      }
      
      dispatch_group_leave(group);
    }];
    
    [task resume];
  });
  
  dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
  
  return responseObject;
}

@end

@implementation NSString (HTTPRequestParameters)

-(NSString *)appendHTTPRequestParameters:(NSDictionary *)parameterDic {
  NSString *baseRequest = self;
  if ([parameterDic objectForKey:@"type"]) {
    baseRequest = [baseRequest stringByAppendingString:[NSString stringWithFormat:@"&type=%@", parameterDic[@"type"]]];
  }
  
  if ([parameterDic objectForKey:@"keyword"]) {
    baseRequest = [baseRequest stringByAppendingString:[NSString stringWithFormat:@"&keyword=%@", [parameterDic objectForKey:@"keyword"]]];
  }
  
  if ([parameterDic objectForKey:@"language"]) {
    baseRequest = [baseRequest stringByAppendingString:[NSString stringWithFormat:@"&language=%@", [parameterDic objectForKey:@"language"]]];
  }
  
  if ([parameterDic objectForKey:@"radius"]) {
    baseRequest = [baseRequest stringByAppendingString:[NSString stringWithFormat:@"&radius=%@", [parameterDic objectForKey:@"radius"]]];
  }
  
  if ([parameterDic objectForKey:@"location"]) {
    CLLocation *location = (CLLocation *)[parameterDic objectForKey:@"location"];
    baseRequest = [baseRequest stringByAppendingString:[NSString stringWithFormat:@"&latlng=%f,%f", location.coordinate.latitude, location.coordinate.longitude]];
  }
  
  if ([parameterDic objectForKey:@"mode"]) {
    baseRequest = [baseRequest stringByAppendingString:[NSString stringWithFormat:@"&mode=%@", [parameterDic objectForKey:@"mode"]]];
  }
  
  baseRequest = [baseRequest stringByAppendingString:[NSString stringWithFormat:@"&key=%@", API_KEY]];
  
  return baseRequest;
}

-(NSString *)turnAddressStringToParamForAPI {
  return [self stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

@end
