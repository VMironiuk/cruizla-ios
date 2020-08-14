//
//  CRZFramework.h
//  Cruizla
//
//  Created by Vladimir Mironiuk on 19.06.2020.
//  Copyright © 2020 Vladimir Mironiuk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRZFramework : NSObject

/**
 
 */
+ (instancetype)sharedFramework;

/**
 
 */
- (void)switchMyPositionNextMode;

/**
 
 */
- (void)zoomIn;

/**
 
 */
- (void)zoomOut;

/**
 
 */
- (void)compassTapped;

@end

// Position mode notification names
extern NSNotificationName const CRZFrameworkUserPositionModePendingPositionNotification;
extern NSNotificationName const CRZFrameworkUserPositionModeNotFollowNoPositionNotification;
extern NSNotificationName const CRZFrameworkUserPositionModeNotFollowNotification;
extern NSNotificationName const CRZFrameworkUserPositionModeFollowNotification;
extern NSNotificationName const CRZFrameworkUserPositionModeFollowAndRotateNotification;

// Viewport angle change notification name
extern NSNotificationName const CRZFrameworkViewportAngleChangedNotification;

NS_ASSUME_NONNULL_END
