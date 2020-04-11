//
//  EAGLView.h
//  Cruizla
//
//  Created by Vladimir Mironiuk on 26.10.2019.
//  Copyright © 2019 Vladimir Mironiuk. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView

@property(nonatomic, readonly) BOOL drapeEngineCreated;
@property(nonatomic, getter=isLaunchByDeepLink) BOOL launchByDeepLink;
@property(nonatomic, readonly) CGSize pixelSize;
@property(nonatomic, readonly) BOOL graphicContextInitialized;

- (void)createDrapeEngine;
- (void)deallocateNative;
- (void)setPresentAvailable:(BOOL)available;
- (void)updateVisualScaleTo:(CGFloat)visualScale;
- (void)updateVisualScaleToMain;

@end

NS_ASSUME_NONNULL_END
