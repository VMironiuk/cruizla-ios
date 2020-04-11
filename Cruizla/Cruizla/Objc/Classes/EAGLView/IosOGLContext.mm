//
//  IosOGLContext.mm
//  Cruizla
//
//  Created by Vladimir Mironiuk on 26.10.2019.
//  Copyright © 2019 Vladimir Mironiuk. All rights reserved.
//

#import "IosOGLContext.h"

#include "base/assert.hpp"
#include "base/logging.hpp"

#include "drape/gl_functions.hpp"

IosOGLContext::IosOGLContext(
    CAEAGLLayer* layer,
    dp::ApiVersion apiVersion,
    IosOGLContext* contextToShareWith,
    bool needBuffers)
  : m_apiVersion(apiVersion)
  , m_layer(layer)
  , m_nativeContext(NULL)
  , m_needBuffers(needBuffers)
  , m_hasBuffers(false)
  , m_renderBufferId(0)
  , m_depthBufferId(0)
  , m_frameBufferId(0)
  , m_presentAvailable(true)
{
  // Select an appropriate OpenGL version.
  EAGLRenderingAPI api = IsOpenGLES3Version()
    ? kEAGLRenderingAPIOpenGLES3
    : kEAGLRenderingAPIOpenGLES2;
  
  // Create OpenGL ES rendering context.
  m_nativeContext = (contextToShareWith != nullptr)
    ? [[EAGLContext alloc] initWithAPI:api sharegroup:contextToShareWith->m_nativeContext.sharegroup]
    : [[EAGLContext alloc] initWithAPI:api];
}

IosOGLContext::~IosOGLContext() {
  DestroyBuffers();
}

void IosOGLContext::MakeCurrent() {
  ASSERT(m_nativeContext != nullptr, ());
  [EAGLContext setCurrentContext: m_nativeContext];

  if (m_needBuffers && !m_hasBuffers) {
    InitBuffers();
  }
}

void IosOGLContext::Present() {
  ASSERT(m_nativeContext != nullptr, ());
  ASSERT(m_renderBufferId, ());
  
  GLenum const discards[] = { GL_DEPTH_ATTACHMENT, GL_COLOR_ATTACHMENT0 };
  if (m_apiVersion == dp::ApiVersion::OpenGLES3) {
    GLCHECK(glInvalidateFramebuffer(GL_FRAMEBUFFER, 1, discards));
  }
  else {
    GLCHECK(glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, discards));
  }

  glBindRenderbuffer(GL_RENDERBUFFER, m_renderBufferId);
  
  if (m_presentAvailable) {
    [m_nativeContext presentRenderbuffer: GL_RENDERBUFFER];
  }

  if (/*m_apiVersion == dp::ApiVersion::OpenGLES3*/IsOpenGLES3Version()) {
    GLCHECK(glInvalidateFramebuffer(GL_FRAMEBUFFER, 1, discards + 1));
  }
  else {
    GLCHECK(glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, discards + 1));
  }
}

void IosOGLContext::SetFramebuffer(ref_ptr<dp::BaseFramebuffer> framebuffer) {
  if (framebuffer != nullptr) {
    framebuffer->Bind();
  }
  else {
    ASSERT(m_frameBufferId, ());
    glBindFramebuffer(GL_FRAMEBUFFER, m_frameBufferId);
  }
}

void IosOGLContext::Resize(int w, int h) {
  if (m_needBuffers && m_hasBuffers) {
    GLint width = 0;
    GLint height = 0;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    if (width == w && height == h) {
      return;
    }

    DestroyBuffers();
    InitBuffers();
  }
}

void IosOGLContext::SetPresentAvailable(bool available) {
  m_presentAvailable = available;
}

void IosOGLContext::InitBuffers() {
  ASSERT(m_needBuffers, ());

  if (!m_hasBuffers) {
    //{@ Color
    glGenRenderbuffers(1, &m_renderBufferId);
    glBindRenderbuffer(GL_RENDERBUFFER, m_renderBufferId);

    [m_nativeContext renderbufferStorage:GL_RENDERBUFFER fromDrawable: m_layer];
    //@} color

    //{@ Depth
    GLint width = 0;
    GLint height = 0;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);

    glGenRenderbuffers(1, &m_depthBufferId);
    glBindRenderbuffer(GL_RENDERBUFFER, m_depthBufferId);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    //@} depth

    //{@ Framebuffer
    glGenFramebuffers(1, &m_frameBufferId);
    glBindFramebuffer(GL_FRAMEBUFFER, m_frameBufferId);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, m_renderBufferId);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, m_depthBufferId);
    
    GLint fbStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (fbStatus != GL_FRAMEBUFFER_COMPLETE) {
      LOG(LERROR, ("Incomplete framebuffer:", fbStatus));
    }
    //@} framebuffer

    m_hasBuffers = true;
  }
}

void IosOGLContext::DestroyBuffers() {
  if (m_needBuffers && m_hasBuffers) {
    glFinish();
    glBindFramebuffer(GL_FRAMEBUFFER, m_frameBufferId);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, 0);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    glDeleteFramebuffers(1, &m_frameBufferId);
    glDeleteRenderbuffers(1, &m_renderBufferId);
    glDeleteRenderbuffers(1, &m_depthBufferId);

    m_hasBuffers = false;
  }
}

bool IosOGLContext::IsOpenGLES3Version() const {
  return (m_apiVersion == dp::ApiVersion::OpenGLES3);
}
