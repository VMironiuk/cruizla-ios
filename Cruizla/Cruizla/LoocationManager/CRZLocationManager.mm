//
//  CRZLocationManager.m
//  Cruizla
//
//  Created by Vladimir Mironiuk on 08.06.2020.
//  Copyright © 2020 Vladimir Mironiuk. All rights reserved.
//

#import "CRZLocationManager.h"

#import <CoreLocation/CoreLocation.h>

#include "Framework.h"

static location::GpsInfo gpsInfoFromLocation(CLLocation * l, location::TLocationSource source)
{
  location::GpsInfo info;
  info.m_source = source;

  info.m_latitude = l.coordinate.latitude;
  info.m_longitude = l.coordinate.longitude;
  info.m_timestamp = l.timestamp.timeIntervalSince1970;

  if (l.horizontalAccuracy >= 0.0)
    info.m_horizontalAccuracy = l.horizontalAccuracy;

  if (l.verticalAccuracy >= 0.0)
  {
    info.m_verticalAccuracy = l.verticalAccuracy;
    info.m_altitude = l.altitude;
  }

  if (l.course >= 0.0)
    info.m_bearing = l.course;

  if (l.speed >= 0.0)
    info.m_speedMpS = l.speed;
  return info;
}

@interface CRZLocationManager ()<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager* locationManager;

@end

@implementation CRZLocationManager

#pragma mark - Lifecycle

- (instancetype)init {
  if (self = [super init]) {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [self checkForLocationAccess];
  }
  return self;
}

+ (instancetype)sharedManager {
  static CRZLocationManager* manager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    manager = [[CRZLocationManager alloc] init];
  });
  return manager;
}

#pragma mark - Public

- (void)start {
  [self.locationManager startUpdatingLocation];
}

- (void)stop {
  [self.locationManager stopUpdatingLocation];
}

#pragma mark - Private

- (void)checkForLocationAccess {
  if (![CLLocationManager locationServicesEnabled]) {
    [self.locationManager startUpdatingLocation];
    return;
  }
  [self.locationManager requestWhenInUseAuthorization];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
  // TODO: add implementation
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
  auto& f = GetFramework();
  auto locationSourse = location::TLocationSource::EAppleNative;
  location::GpsInfo const gpsInfo = gpsInfoFromLocation([locations lastObject], locationSourse);
  f.OnLocationUpdate(gpsInfo);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  // TODO: add implementation
}


@end
