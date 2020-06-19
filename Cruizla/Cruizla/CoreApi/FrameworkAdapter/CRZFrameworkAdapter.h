//
//  CRZFrameworkAdapter.h
//  Cruizla
//
//  Created by Vladimir Mironiuk on 19.06.2020.
//  Copyright © 2020 Vladimir Mironiuk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRZFrameworkAdapter : NSObject

+ (instancetype)sharedFramework;

- (void)switchMyPositionNextMode;

@end

NS_ASSUME_NONNULL_END
