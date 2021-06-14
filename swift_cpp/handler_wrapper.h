#pragma once

#import <Foundation/Foundation.h>

@interface HandlerWrapper:NSObject
- (instancetype)initWithName:(NSString*)name;
- (NSString *) getName;
- (void)setName:(NSString*)name;
@end
