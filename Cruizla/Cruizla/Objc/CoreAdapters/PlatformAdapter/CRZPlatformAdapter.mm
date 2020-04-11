//
//  CRZPlatformAdapter.mm
//  Cruizla
//
//  Created by Vladimir Mironiuk on 9/14/19.
//  Copyright © 2019 Vladimir Mironiuk. All rights reserved.
//

#import "CRZPlatformAdapter.h"

#include "platform/platform.hpp"

@implementation CRZPlatformAdapter

+ (NSUInteger)cpuCoresCount {
  return GetPlatform().CpuCores();
}

@end
