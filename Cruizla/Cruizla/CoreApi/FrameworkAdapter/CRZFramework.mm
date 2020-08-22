//
//  CRZFramework.m
//  Cruizla
//
//  Created by Vladimir Mironiuk on 19.06.2020.
//  Copyright © 2020 Vladimir Mironiuk. All rights reserved.
//

#import "CRZFramework.h"

#include "Framework.h"

#include "geometry/screenbase.hpp"

#include "platform/location.hpp"

@implementation CRZFramework

#pragma mark - Lifecycle

+ (instancetype)sharedFramework {
  static CRZFramework* framework = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    framework = [[CRZFramework alloc] init];
  });
  return framework;
}

- (instancetype)init {
  if (self = [super init]) {
    [self p_setupFrameworkListeners];
  }
  return self;
}

#pragma mark - Public

- (void)switchMyPositionNextMode {
  GetFramework().SwitchMyPositionNextMode();
}

- (void)zoomIn {
  GetFramework().Scale(Framework::SCALE_MAG, true);
}

- (void)zoomOut {
  GetFramework().Scale(Framework::SCALE_MIN, true);
}

- (void)compassTapped {
  GetFramework().GetDrapeEngine()->OnCompassTapped();
}

- (void)setVisibleViewport:(CGRect)rect scaleFactor:(CGFloat)scale {
  CGFloat const x0 = rect.origin.x * scale;
  CGFloat const y0 = rect.origin.y * scale;
  CGFloat const x1 = x0 + rect.size.width * scale;
  CGFloat const y1 = y0 + rect.size.height * scale;
  GetFramework().SetVisibleViewport(m2::RectD(x0, y0, x1, y1));
}

#pragma mark - Private

- (void)p_setupFrameworkListeners {
  Framework& f = GetFramework();
  
  f.SetPlacePageListeners([self] () {
    [self p_mapObjectSelected];
  }, [self] (bool isNeedSwitchToFullScreen) {
    [self p_mapObjectDeselectedAndNeedSwitchToFullScreen:isNeedSwitchToFullScreen];
  }, [self] () {
    [self p_mapObjectUpdated];
  });
  
  f.SetMyPositionModeListener([self](location::EMyPositionMode mode, bool isRoutingActive){
    [self p_processUserPositionMode:mode];
  });
  
  f.SetMyPositionPendingTimeoutListener([self] () {
    [self p_processUserPositionPendingTimeout];
  });
  
  f.SetViewportListener([self](const ScreenBase& screen){
    [self p_processViewportAngleChanged:screen.GetAngle()];
  });
}

- (void)p_mapObjectSelected {
  NSLog(@"CRZ_LOGGER: %s", __PRETTY_FUNCTION__);
}

- (void)p_mapObjectDeselectedAndNeedSwitchToFullScreen:(BOOL)needSwitchToFullScreen {
  NSLog(@"CRZ_LOGGER: %s", __PRETTY_FUNCTION__);
}

- (void)p_mapObjectUpdated {
  NSLog(@"CRZ_LOGGER: %s", __PRETTY_FUNCTION__);
}

- (void)p_processUserPositionMode:(location::EMyPositionMode)mode {
  switch (mode) {
    case location::EMyPositionMode::PendingPosition:
      [[NSNotificationCenter defaultCenter]
       postNotificationName:CRZFrameworkUserPositionModePendingPositionNotification object:self];
      break;
    case location::EMyPositionMode::NotFollowNoPosition:
      [[NSNotificationCenter defaultCenter]
       postNotificationName:CRZFrameworkUserPositionModeNotFollowNoPositionNotification object:self];
      break;
    case location::EMyPositionMode::NotFollow:
      [[NSNotificationCenter defaultCenter]
       postNotificationName:CRZFrameworkUserPositionModeNotFollowNotification object:self];
      break;
    case location::EMyPositionMode::Follow:
      [[NSNotificationCenter defaultCenter]
       postNotificationName:CRZFrameworkUserPositionModeFollowNotification object:self];
      break;
    case location::EMyPositionMode::FollowAndRotate:
      [[NSNotificationCenter defaultCenter]
       postNotificationName:CRZFrameworkUserPositionModeFollowAndRotateNotification object:self];
      break;
  }
}

- (void)p_processUserPositionPendingTimeout {
  NSLog(@"CRZ_LOGGER: %s", __PRETTY_FUNCTION__);
}

- (void)p_processViewportAngleChanged:(double)angle {
  [[NSNotificationCenter defaultCenter]
   postNotificationName:CRZFrameworkViewportAngleChangedNotification object:self
   userInfo:@{@"angle": [NSNumber numberWithDouble:angle]}];
}

@end

// Position mode notification names
NSNotificationName const CRZFrameworkUserPositionModePendingPositionNotification =
  @"CRZFrameworkUserPositionModePendingPositionNotification";
NSNotificationName const CRZFrameworkUserPositionModeNotFollowNoPositionNotification =
  @"CRZFrameworkUserPositionModeNotFollowNoPositionNotification";
NSNotificationName const CRZFrameworkUserPositionModeNotFollowNotification =
  @"CRZFrameworkUserPositionModeNotFollowNotification";
NSNotificationName const CRZFrameworkUserPositionModeFollowNotification =
  @"CRZFrameworkUserPositionModeFollowNotification";
NSNotificationName const CRZFrameworkUserPositionModeFollowAndRotateNotification =
  @"CRZFrameworkUserPositionModeFollowAndRotateNotification";

// Viewport angle change notification name
NSNotificationName const CRZFrameworkViewportAngleChangedNotification=
  @"CRZFrameworkViewportAngleChangedNotification";
