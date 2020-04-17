//
//  IosOGLContextFactory.h
//  Cruizla
//
//  Created by Vladimir Mironiuk on 26.10.2019.
//  Copyright © 2019 Vladimir Mironiuk. All rights reserved.
//

#ifndef IosOGLContextFactory_h
#define IosOGLContextFactory_h

#include <condition_variable>
#include <mutex>

#include "drape/drape_global.hpp"
#include "drape/graphics_context_factory.hpp"

#import "IosOGLContext.h"

class IosOGLContextFactory: public dp::GraphicsContextFactory
{
public:
  IosOGLContextFactory(CAEAGLLayer* layer, dp::ApiVersion apiVersion, bool presentAvailable);
  ~IosOGLContextFactory();

  dp::GraphicsContext* GetDrawContext() override;
  dp::GraphicsContext* GetResourcesUploadContext() override;

  bool IsDrawContextCreated() const override;
  bool IsUploadContextCreated() const override;
  
  void WaitForInitialization(dp::GraphicsContext* context) override;
  
  void SetPresentAvailable(bool available) override;

private:
  CAEAGLLayer* m_layer;
  dp::ApiVersion m_apiVersion;
  IosOGLContext* m_drawContext;
  IosOGLContext* m_uploadContext;
  
  bool m_isInitialized;
  size_t m_initializationCounter;
  bool m_presentAvailable;
  std::condition_variable m_initializationCondition;
  std::mutex m_initializationMutex;
};

#endif /* IosOGLContextFactory_h */
