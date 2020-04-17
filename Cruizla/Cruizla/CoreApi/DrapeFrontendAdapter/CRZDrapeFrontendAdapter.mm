//
//  CRZDrapeFrontendAdapter.m
//  Cruizla
//
//  Created by Vladimir Mironiuk on 04.04.2020.
//  Copyright © 2020 Vladimir Mironiuk. All rights reserved.
//

#import "CRZDrapeFrontendAdapter.h"

#include "drape_frontend/user_event_stream.hpp"

#include "Framework.h"

@implementation CRZDrapeFrontendAdapter

#pragma mark - Class Methods

+ (instancetype)sharedDrapeFrontendAdapter {
  static CRZDrapeFrontendAdapter* sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

#pragma mark - Public

- (void)sendTouchType:(CRZDrapeFrontendTouchType)type
          withTouches:(NSSet *)touches
                event:(UIEvent *)event
              mapView:(UIView *)mapView
{
  df::TouchEvent::ETouchType dfType = [self p_dfTouchType:type];
  [self p_sendTouchType:dfType withTouches:touches event:event mapView:mapView];
}

#pragma mark - Private

- (df::TouchEvent::ETouchType)p_dfTouchType:(CRZDrapeFrontendTouchType)dfAdapterTouchType {
  switch (dfAdapterTouchType) {
    case CRZDrapeFrontendTouchTypeTouchDown:
      return df::TouchEvent::TOUCH_DOWN;
    case CRZDrapeFrontendTouchTypeTouchMove:
      return df::TouchEvent::TOUCH_MOVE;
    case CRZDrapeFrontendTouchTypeTouchUp:
      return df::TouchEvent::TOUCH_UP;
    case CRZDrapeFrontendTouchTypeTouchCancel:
      return df::TouchEvent::TOUCH_CANCEL;
  }
}

- (BOOL)p_hasForceTouchInMapView:(UIView *)mapView {
  return mapView.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
}

- (void)p_checkMaskedPointer:(UITouch *)touch withEvent:(df::TouchEvent &)e
{
  int64_t id = reinterpret_cast<int64_t>(touch);
  int8_t pointerIndex = df::TouchEvent::INVALID_MASKED_POINTER;
  if (e.GetFirstTouch().m_id == id) {
    pointerIndex = 0;
  } else if (e.GetSecondTouch().m_id == id) {
    pointerIndex = 1;
  }

  if (e.GetFirstMaskedPointer() == df::TouchEvent::INVALID_MASKED_POINTER)
    e.SetFirstMaskedPointer(pointerIndex);
  else
    e.SetSecondMaskedPointer(pointerIndex);
}

- (void)p_sendTouchType:(df::TouchEvent::ETouchType)type
            withTouches:(NSSet *)touches
                  event:(UIEvent *)event
                mapView:(UIView *)mapView
{
  NSArray*  allTouches = [[event allTouches] allObjects];
  if ([allTouches count] < 1) {
    return;
  }
  
  const CGFloat scaleFactor = mapView.contentScaleFactor;
  
  df::TouchEvent e;
  UITouch* touch = [allTouches objectAtIndex:0];
  const CGPoint point = [touch locationInView:mapView];
  
  e.SetTouchType(type);
  
  df::Touch t0;
  t0.m_location = m2::Point(point.x * scaleFactor, point.y * scaleFactor);
  t0.m_id = reinterpret_cast<int64_t>(touch);
  if ([self p_hasForceTouchInMapView:mapView]) {
    t0.m_force = touch.force / touch.maximumPossibleForce;
  }
  e.SetFirstTouch(t0);
  
  if ([allTouches count] > 1) {
    UITouch* touch = [allTouches objectAtIndex:1];
    const CGPoint point = [touch locationInView:mapView];
    
    df::Touch t1;
    t1.m_location = m2::PointD(point.x * scaleFactor, point.y * scaleFactor);
    t1.m_id = reinterpret_cast<int64_t>(touch);
    if ([self p_hasForceTouchInMapView:mapView]) {
      t1.m_force = touch.force / touch.maximumPossibleForce;
    }
    e.SetSecondTouch(t1);
  }
  
  NSArray* toggledTouches = [touches allObjects];
  if ([toggledTouches count] > 0) {
    [self p_checkMaskedPointer:[toggledTouches objectAtIndex:0] withEvent:e];
  }
  if ([toggledTouches count] > 1) {
    [self p_checkMaskedPointer:[toggledTouches objectAtIndex:1] withEvent:e];
  }
  
  Framework& f = GetFramework();
  f.TouchEvent(e);
}

@end
