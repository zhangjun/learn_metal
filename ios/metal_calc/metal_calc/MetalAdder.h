//
//  MetalAdder.h
//  metal_calc
//
//  Created by Apple on 2021/11/6.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@interface MetalAdder : NSObject
- (instancetype) initWithDevice: (id<MTLDevice>) device library:(id<MTLLibrary>)library;
- (void) setupPipeline: (NSString*)name;
- (void) prepareData;
- (void) sendComputeCommand;
@end

@interface MetalTask : MetalAdder
- (instancetype) initWithDevice: (id<MTLDevice>) device library:(id<MTLLibrary>)library;
- (void) setupPipeline: (NSString*)name;
- (void) prepareData;
- (void) sendComputeCommand;
@end

NS_ASSUME_NONNULL_END
