//
//  IosOGLContext.h
//  Cruizla
//
//  Created by Vladimir Mironiuk on 26.10.2019.
//  Copyright © 2019 Vladimir Mironiuk. All rights reserved.
//

#ifndef IosOGLContext_h
#define IosOGLContext_h

#include <atomic>

#include "drape/drape_global.hpp"
#include "drape/gl_includes.hpp"
#include "drape/oglcontext.hpp"

#import <QuartzCore/CAEAGLLayer.h>

class IosOGLContext : public dp::OGLContext {
public:
  IosOGLContext(
      CAEAGLLayer* layer,
      dp::ApiVersion apiVersion,
      IosOGLContext* contextToShareWith,
      bool needBuffers = false);
  ~IosOGLContext() override;

  void MakeCurrent() override;
  void Present() override;
  void SetFramebuffer(ref_ptr<dp::BaseFramebuffer> framebuffer) override;
  void Resize(int w, int h) override;
  void SetPresentAvailable(bool available) override;

private:
  void InitBuffers();
  void DestroyBuffers();
  
  // Helpers
  bool IsOpenGLES3Version() const;
  
  //{@ Buffers
  bool m_needBuffers;
  bool m_hasBuffers;
  
  GLuint m_renderBufferId;
  GLuint m_depthBufferId;
  GLuint m_frameBufferId;
  //@} buffers
  
  dp::ApiVersion m_apiVersion;
  CAEAGLLayer* m_layer;
  EAGLContext* m_nativeContext;
  
  std::atomic<bool> m_presentAvailable;
};


#endif /* IosOGLContext_h */
