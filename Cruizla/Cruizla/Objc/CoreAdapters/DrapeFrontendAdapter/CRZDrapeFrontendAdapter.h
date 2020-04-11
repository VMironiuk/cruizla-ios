//
//  CRZDrapeFrontendAdapter.h
//  Cruizla
//
//  Created by Vladimir Mironiuk on 04.04.2020.
//  Copyright © 2020 Vladimir Mironiuk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CRZDrapeFrontendTouchType) {
  CRZDrapeFrontendTouchTypeTouchDown,
  CRZDrapeFrontendTouchTypeTouchMove,
  CRZDrapeFrontendTouchTypeTouchUp,
  CRZDrapeFrontendTouchTypeTouchCancel
};

@interface CRZDrapeFrontendAdapter : NSObject

/**
 
 */
+ (instancetype)sharedDrapeFrontendAdapter;

/**
 
 */
- (void)sendTouchType:(CRZDrapeFrontendTouchType)type
          withTouches:(NSSet *)touches
                event:(UIEvent *)event
              mapView:(UIView *)mapView;

@end
