//
//  NetworkManager.m
//  HeadsUp
//
//  Created by Brian Vo on 2018-05-02.
//  Copyright © 2018 Brian Vo & Ray Lin. All rights reserved.
//

#import "NetworkManager.h"
#import "HeadsUp-Swift.h"

@implementation NetworkManager

-(void)fetchCafesWithUserLocation:(CLLocationCoordinate2D)location searchTerm:(NSString *)searchTerm completion:(void(^)(NSArray<MKAnnotation>*))handler {
    
    NSString *yelpAPIString = @"https://api.yelp.com/v3/businesses/search";
    NSString *yelpAPIKey = @"czW64vnYPyjrfugdWlPn8HDwFHioGEc_-0TU7qjQuwQTOyan2QcnzafJOmKIa5xt2NLkxvWkQz_VNQ-cvkxoNzGkjFhoxL_-vtAky871KgUQxwRMYVk4MBAOdZvjWnYx";
    
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:yelpAPIString];
    NSURLQueryItem *categoryItem = [NSURLQueryItem queryItemWithName:@"categories" value:@"cafes"];
    NSURLQueryItem *searchItem = [NSURLQueryItem queryItemWithName:@"term" value:searchTerm];
    NSURLQueryItem *latItem = [NSURLQueryItem queryItemWithName:@"latitude" value:@(location.latitude).stringValue];
    NSURLQueryItem *lngItem = [NSURLQueryItem queryItemWithName:@"longitude" value:@(location.longitude).stringValue];
    urlComponents.queryItems = @[categoryItem, latItem, lngItem,searchItem];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlComponents.URL];
    request.HTTPMethod = @"GET";
    [request addValue:[NSString stringWithFormat:@"Bearer %@", yelpAPIKey] forHTTPHeaderField:@"Authorization"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"%@", error.localizedDescription);
            return;
        }
        
        NSUInteger statusCode = ((NSHTTPURLResponse*)response).statusCode;
        
        if (statusCode != 200) {
            NSLog(@"Error: status code is equal to %@", @(statusCode));
            return;
        }
        if (data == nil) {
            NSLog(@"Error: data is nil");
            return;
        }
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSArray<NSDictionary *>*jsonArray = json[@"businesses"];
        
        NSMutableArray *cafes = [NSMutableArray arrayWithCapacity:jsonArray.count];
        
        for (NSDictionary *item in jsonArray) {
            CafeModel *cafeModel = [[CafeModel alloc] initWithDictionary:item];
            [cafes addObject:cafeModel];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            handler([cafes copy]);
        }];
        
    }];
    
    [task resume];
}

@end
