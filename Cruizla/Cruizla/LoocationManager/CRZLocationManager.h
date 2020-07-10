//
//  CRZLocationManager.h
//  Cruizla
//
//  Created by Vladimir Mironiuk on 08.06.2020.
//  Copyright © 2020 Vladimir Mironiuk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRZLocationManager : NSObject

/**
 
 */
+ (instancetype)sharedManager;

/**
 
 */
- (void)start;

/**
 
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
