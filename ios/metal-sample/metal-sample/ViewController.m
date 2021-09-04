//
//  ViewController.m
//  metal-sample
//
//  Created by Apple on 2021/7/12.
//

#import "ViewController.h"

// https://developer.apple.com/documentation/metal/basic_tasks_and_concepts/performing_calculations_on_a_gpu

void func() {
_mAddFunctionPSO = [_mDevice newComputePipelineStateWithFunction: addFunction error:&error];
_mCommandQueue = [_mDevice newCommandQueue];

_mBufferA = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
_mBufferB = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
_mBufferResult = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];

[self generateRandomFloatData:_mBufferA];
[self generateRandomFloatData:_mBufferB];
    
id<MTLCommandBuffer> commandBuffer = [_mCommandQueue commandBuffer];

id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];

}

- (void) generateRandomFloatData: (id<MTLBuffer>) buffer
{
    float* dataPtr = buffer.contents;

    for (unsigned long index = 0; index < arrayLength; index++)
    {
        dataPtr[index] = (float)rand()/(float)(RAND_MAX);
    }
}


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


@end
