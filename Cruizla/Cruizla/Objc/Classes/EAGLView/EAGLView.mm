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

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self initialize];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  if (self = [super initWithCoder:coder]) {
    [self initialize];
  }
  return self;
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

- (void)initialize {
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
}

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

- (void)addSubview:(UIView *)view {
  [super addSubview:view];
}

- (CGSize)pixelSize {
  CGSize const s = self.bounds.size;
  
  CGFloat const w = s.width * self.contentScaleFactor;
  CGFloat const h = s.height * self.contentScaleFactor;
  return CGSizeMake(w, h);
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

@end
