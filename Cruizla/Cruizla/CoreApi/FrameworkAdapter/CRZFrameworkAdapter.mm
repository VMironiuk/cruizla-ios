//
//  CRZFrameworkAdapter.m
//  Cruizla
//
//  Created by Vladimir Mironiuk on 19.06.2020.
//  Copyright © 2020 Vladimir Mironiuk. All rights reserved.
//

#import "CRZFrameworkAdapter.h"

#include "Framework.h"

#include "platform/location.hpp"

@implementation CRZFrameworkAdapter

#pragma mark - Lifecycle

+ (instancetype)sharedFramework {
  static CRZFrameworkAdapter* framework = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    framework = [[CRZFrameworkAdapter alloc] init];
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

@end

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
