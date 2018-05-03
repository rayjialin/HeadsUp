//
//  NetworkManager.h
//  HeadsUp
//
//  Created by Brian Vo on 2018-05-02.
//  Copyright © 2018 Brian Vo & Ray Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
@import CoreLocation;

@interface NetworkManager : NSObject


-(void)fetchCafesWithUserLocation:(CLLocationCoordinate2D)location radius:(int)radius completion:(void(^)(NSArray<MKAnnotation>*))handler;

@end
