//
//  CRZFrameworkAdapter.m
//  Cruizla
//
//  Created by Vladimir Mironiuk on 19.06.2020.
//  Copyright © 2020 Vladimir Mironiuk. All rights reserved.
//

#import "CRZFrameworkAdapter.h"

#include "Framework.h"

@implementation CRZFrameworkAdapter

+ (instancetype)sharedFramework {
  static CRZFrameworkAdapter* framework = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    framework = [[CRZFrameworkAdapter alloc] init];
  });
  return framework;
}

- (void)switchMyPositionNextMode {
  GetFramework().SwitchMyPositionNextMode();
}

@end
