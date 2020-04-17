//
//  EAGLView.mm
//  Cruizla
//
//  Created by Vladimir Mironiuk on 26.10.2019.
//  Copyright © 2019 Vladimir Mironiuk. All rights reserved.
//

#import "EAGLView.h"
#import "IosOGLContextFactory.h"

#import "3party/Alohalytics/src/alohalytics_objc.h"

#include "base/assert.hpp"
#include "base/logging.hpp"

#include "drape/drape_global.hpp"
#include "drape/pointers.hpp"
#include "drape_frontend/user_event_stream.hpp"
#include "drape/visual_scale.hpp"
#include "drape_frontend/visual_params.hpp"

#include "Framework.h"

namespace dp {
  class GraphicsContextFactory;
}

@interface EAGLView() {
  dp::ApiVersion m_apiVersion;
  drape_ptr<dp::GraphicsContextFactory> m_factory;
  CGRect m_lastViewSize;
  bool m_presentAvailable;
  double m_mainVisualScale;
}

@property(nonatomic, readwrite) BOOL graphicContextInitialized;

@end

@implementation EAGLView

namespace {
// Returns DPI as exact as possible. It works for iPhone, iPad and iWatch.
double getExactDPI(double contentScaleFactor) {
  const float iPadDPI = 132.f;
  const float iPhoneDPI = 163.f;
  const float mDPI = 160.f;

  switch (UI_USER_INTERFACE_IDIOM()) {
    case UIUserInterfaceIdiomPhone:
      return iPhoneDPI * contentScaleFactor;
    case UIUserInterfaceIdiomPad:
      return iPadDPI * contentScaleFactor;
    default:
      return mDPI * contentScaleFactor;
  }
}
} //  namespace

#pragma mark - Custom Accessors

- (CGSize)pixelSize {
  CGSize const s = self.bounds.size;
  
  CGFloat const w = s.width * self.contentScaleFactor;
  CGFloat const h = s.height * self.contentScaleFactor;
  return CGSizeMake(w, h);
}

#pragma mark - Class Methods

+ (dp::ApiVersion)supportedApiVersion {
  static dp::ApiVersion apiVersion = dp::ApiVersion::Invalid;
  if (apiVersion != dp::ApiVersion::Invalid) {
    return apiVersion;
  }
  
  if (apiVersion == dp::ApiVersion::Invalid) {
    EAGLContext * tempContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    apiVersion = (tempContext != nullptr)
      ? dp::ApiVersion::OpenGLES3
      : dp::ApiVersion::OpenGLES2;
  }
  return apiVersion;
}

// You must implement this method
+ (Class)layerClass {
  return [CAEAGLLayer class];
}

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self p_initialize];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  if (self = [super initWithCoder:coder]) {
    [self p_initialize];
  }
  return self;
}

- (void)addSubview:(UIView *)view {
  [super addSubview:view];
}

- (void)layoutSubviews {
  if (!CGRectEqualToRect(m_lastViewSize, self.frame)) {
    m_lastViewSize = self.frame;
    CGSize const objcSize = [self pixelSize];
    m2::PointU const s = m2::PointU(
        static_cast<uint32_t>(objcSize.width),
        static_cast<uint32_t>(objcSize.height));
    GetFramework().OnSize(s.x, s.y);
  }
  [super layoutSubviews];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self p_sendTouchType:df::TouchEvent::TOUCH_DOWN withTouches:touches event:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self p_sendTouchType:df::TouchEvent::TOUCH_MOVE withTouches:nil event:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self p_sendTouchType:df::TouchEvent::TOUCH_UP withTouches:touches event:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self p_sendTouchType:df::TouchEvent::TOUCH_CANCEL withTouches:touches event:event];
}

#pragma mark - Public

- (void)createDrapeEngine {
  CGSize const objcSize = [self pixelSize];
  m2::PointU const s = m2::PointU(
      static_cast<uint32_t>(objcSize.width),
      static_cast<uint32_t>(objcSize.height));
  
  m_factory = make_unique_dp<dp::ThreadSafeFactory>(
    new IosOGLContextFactory((CAEAGLLayer *)self.layer, m_apiVersion, m_presentAvailable));
  
  [self createDrapeEngineWithWidth:s.x height:s.y];
}

- (void)deallocateNative {
  GetFramework().PrepareToShutdown();
  m_factory.reset();
}

- (void)setPresentAvailable:(BOOL)available {
  m_presentAvailable = available;
  if (m_factory != nullptr) {
    m_factory->SetPresentAvailable(m_presentAvailable);
  }
}

- (void)updateVisualScaleTo:(CGFloat)visualScale {
  m_mainVisualScale = df::VisualParams::Instance().GetVisualScale();
  GetFramework().UpdateVisualScale(visualScale);
}

- (void)updateVisualScaleToMain {
  GetFramework().UpdateVisualScale(m_mainVisualScale);
}

#pragma mark - Private

#pragma mark - Initialisation Helper

- (void)p_initialize {
  m_presentAvailable = false;
  m_lastViewSize = CGRectZero;
  m_apiVersion = [EAGLView supportedApiVersion];

  // Correct retina display support in renderbuffer.
  self.contentScaleFactor = [[UIScreen mainScreen] nativeScale];
  
  CAEAGLLayer* layer = (CAEAGLLayer *)[self layer];
  [layer setOpaque:YES];
  [layer setDrawableProperties:@{
    kEAGLDrawablePropertyRetainedBacking : @NO,
    kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8}];
  
  auto& f = GetFramework();
  f.SetGraphicsContextInitializationHandler([self]() {
    [self setGraphicContextInitialized:YES];
  });
  
  [self setPresentAvailable:YES];
  [self p_registerNotifications];
}

#pragma mark - Drape Engine Creation

- (void)createDrapeEngineWithWidth:(int)width height:(int)height {
  LOG(LINFO, ("CreateDrapeEngine Started", width, height, m_apiVersion));
  CHECK(m_factory != nullptr, ());
  
  Framework::DrapeCreationParams p;
  p.m_apiVersion = m_apiVersion;
  p.m_surfaceWidth = width;
  p.m_surfaceHeight = height;
  p.m_visualScale = dp::VisualScale(getExactDPI(self.contentScaleFactor));
  p.m_hints.m_isFirstLaunch = [Alohalytics isFirstSession];
  p.m_hints.m_isLaunchByDeepLink = self.isLaunchByDeepLink;

  GetFramework().CreateDrapeEngine(make_ref(m_factory), std::move(p));

  self->_drapeEngineCreated = YES;
  LOG(LINFO, ("CreateDrapeEngine Finished"));
}

#pragma mark - Map Navigation Helpers

- (BOOL)p_hasForceTouch {
  return self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
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
{
  NSArray*  allTouches = [[event allTouches] allObjects];
  if ([allTouches count] < 1) {
    return;
  }
  
  const CGFloat scaleFactor = self.contentScaleFactor;
  
  df::TouchEvent e;
  UITouch* touch = [allTouches objectAtIndex:0];
  const CGPoint point = [touch locationInView:self];
  
  e.SetTouchType(type);
  
  df::Touch t0;
  t0.m_location = m2::Point(point.x * scaleFactor, point.y * scaleFactor);
  t0.m_id = reinterpret_cast<int64_t>(touch);
  if ([self p_hasForceTouch]) {
    t0.m_force = touch.force / touch.maximumPossibleForce;
  }
  e.SetFirstTouch(t0);
  
  if ([allTouches count] > 1) {
    UITouch* touch = [allTouches objectAtIndex:1];
    const CGPoint point = [touch locationInView:self];
    
    df::Touch t1;
    t1.m_location = m2::PointD(point.x * scaleFactor, point.y * scaleFactor);
    t1.m_id = reinterpret_cast<int64_t>(touch);
    if ([self p_hasForceTouch]) {
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

#pragma mark - Notifications Handling

- (void)p_registerNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(p_onSceneDidDisconnectNotification:)
                                               name:UISceneDidDisconnectNotification object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(p_onSceneDidActivateNotification:)
                                               name:UISceneDidActivateNotification object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(p_onSceneWillDeactivateNotification:)
                                               name:UISceneWillDeactivateNotification object:nil];
}

- (void)p_onSceneDidDisconnectNotification:(NSNotification *)notification {
  [self deallocateNative];
}

- (void)p_onSceneDidActivateNotification:(NSNotification *)notification {
  [self setPresentAvailable:YES];
}

- (void)p_onSceneWillDeactivateNotification:(NSNotification *)notification {
  [self setPresentAvailable:NO];
}

@end
