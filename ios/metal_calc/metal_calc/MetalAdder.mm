//
//  MetalAdder.m
//  metal_calc
//
//  Created by Apple on 2021/11/6.
//

#import "MetalAdder.h"


// The number of floats in each array, and the size of the arrays in bytes.
const unsigned int arrayLength = 1 << 24;
const unsigned int bufferSize = arrayLength * sizeof(float);

@implementation MetalAdder
{
    id<MTLDevice> _mDevice;
    id<MTLLibrary> _defaultLibrary;

    // The compute pipeline generated from the compute kernel in the .metal shader file.
    id<MTLComputePipelineState> _pipelineState;

    // The command queue used to pass commands to the device.
    id<MTLCommandQueue> _mCommandQueue;

    // Buffers to hold data.
    id<MTLBuffer> _mBufferA;
    id<MTLBuffer> _mBufferB;
    id<MTLBuffer> _mBufferResult;

}

- (instancetype) initWithDevice: (id<MTLDevice>) device library:(id<MTLLibrary>)library
{
    self = [super init];
    if (self)
    {
        _mDevice = device;

        NSError* error = nil;
        if (library == nil)
        {
            NSLog(@"Failed to find the default library.");
            return nil;
        }
        _defaultLibrary = library;
    }

    return self;
}
- (void) setupPipeline: (NSString*)name
{
    NSError* error = nil;
    id<MTLFunction> addFunction = [_defaultLibrary newFunctionWithName:name];
    if (addFunction == nil)
    {
        NSLog(@"Failed to find the adder function.");
        return;
    }

    // Create a compute pipeline state object.
    _pipelineState = [_mDevice newComputePipelineStateWithFunction: addFunction error:&error];
    if (_pipelineState == nil)
    {
        //  If the Metal API validation is enabled, you can find out more information about what
        //  went wrong.  (Metal API validation is enabled by default when a debug build is run
        //  from Xcode)
        NSLog(@"Failed to created pipeline state object, error %@.", error);
        return;
    }

    _mCommandQueue = [_mDevice newCommandQueue];
    if (_mCommandQueue == nil)
    {
        NSLog(@"Failed to find the command queue.");
        return;
    }
//    [self startCapture];
}

- (void) prepareData
{
    // Allocate three buffers to hold our initial data and the result.
    _mBufferA = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferB = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferResult = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    
    [self generateRandomFloatData:_mBufferA];
    [self generateRandomFloatData:_mBufferB];
}

- (void) sendComputeCommand
{
    // Create a command buffer to hold commands.
    id<MTLCommandBuffer> commandBuffer = [_mCommandQueue commandBuffer];
    assert(commandBuffer != nil);

    // Start a compute pass.
    id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    assert(computeEncoder != nil);

    [self encodeAddCommand:computeEncoder];

    [commandBuffer setLabel:@"add_array"];
//    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> cb) {
//        CFTimeInterval executionDuration = cb.GPUEndTime - cb.GPUStartTime;
//        CFTimeInterval cpuDuration = cb.kernelEndTime - cb.kernelStartTime;
//        NSLog(@"label: %@, gpu cost: %f s, kernel: %f s [%f, %f]", cb.label, executionDuration, cpuDuration, cb.kernelStartTime, cb.kernelEndTime);
//    }];
    // End the compute pass.
    [computeEncoder endEncoding];

    // Execute the command.
    [commandBuffer commit];
    
//    [self stopCapture];
//    NSLog(@"finish");

    // Normally, you want to do other work in your app while the GPU is running,
    // but in this example, the code simply blocks until the calculation is complete.
    [commandBuffer waitUntilCompleted];
    
    CFTimeInterval executionDuration = commandBuffer.GPUEndTime - commandBuffer.GPUStartTime;
    CFTimeInterval cpuDuration = commandBuffer.kernelEndTime - commandBuffer.kernelStartTime;
    NSLog(@"label: %@, gpu cost: %f s, kernel: %f s [%f, %f]", commandBuffer.label, executionDuration, cpuDuration, commandBuffer.kernelStartTime, commandBuffer.kernelEndTime);

    [self verifyResults];
}

- (void)encodeAddCommand:(id<MTLComputeCommandEncoder>)computeEncoder {

    // Encode the pipeline state object and its parameters.
    [computeEncoder setComputePipelineState:_pipelineState];
    [computeEncoder setBuffer:_mBufferA offset:0 atIndex:0];
    [computeEncoder setBuffer:_mBufferB offset:0 atIndex:1];
    [computeEncoder setBuffer:_mBufferResult offset:0 atIndex:2];

//    MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);

    // Calculate a threadgroup size.
    NSUInteger width = _pipelineState.threadExecutionWidth;
    NSUInteger height = 1;
    width = MIN(width, arrayLength);
    
    NSUInteger groupWidth = (arrayLength + width - 1) / width;
    NSUInteger groupHeight = 1;
    MTLSize threadgroupSize = MTLSizeMake(width, height, 1);
    MTLSize gridSize = MTLSizeMake(groupWidth, groupHeight, 1);

    // Encode the compute command.
    [computeEncoder dispatchThreadgroups:gridSize
              threadsPerThreadgroup:threadgroupSize];
}

- (void) generateRandomFloatData: (id<MTLBuffer>) mtlBuffer
{
    float* dataPtr = (float*)mtlBuffer.contents;
    for (unsigned long index = 0; index < arrayLength; index++)
    {
        dataPtr[index] = (float)rand()/(float)(RAND_MAX);
    }
}

//MTLRegion region = {
//        {0,0,0},
//        {image.size.width, image.size.height, 1.0}
//    };
//
//NSUInteger bytesPerRow = image.size.width * 4;
//[_texture replaceRegion:region
//                mipmapLevel:0
//                  withBytes:imageBytes
//                bytesPerRow:bytesPerRow];

- (void) verifyResults
{
    float* a = (float*)_mBufferA.contents;
    float* b = (float*)_mBufferB.contents;
    float* result = (float*)_mBufferResult.contents;

    for (unsigned long index = 0; index < arrayLength; index++)
    {
        if (result[index] != (a[index] + b[index]))
        {
            printf("Compute ERROR: index=%lu result=%g vs %g=a+b\n",
                   index, result[index], a[index] + b[index]);
            assert(result[index] == (a[index] + b[index]));
        }
    }
    printf("Compute results as expected\n");
}

#pragma mark - capture

- (void)startCapture {
    if (@available(iOS 13.0, *)) {
        MTLCaptureManager* captureManager = [MTLCaptureManager sharedCaptureManager];
        MTLCaptureDescriptor* captureDescriptor = [[MTLCaptureDescriptor alloc] init];
        captureDescriptor.captureObject = self->_mDevice;

        NSError* error;
        if (![captureManager startCaptureWithDescriptor:captureDescriptor error:&error]) {
            NSLog(@"Failed to start capture, error %@", error);
        }
    }
}

- (void)stopCapture {
    if (@available(iOS 13.0, *)) {
        MTLCaptureManager* captureManager = [MTLCaptureManager sharedCaptureManager];
        [captureManager stopCapture];
    }
}

@end
