//
//  main.m
//  metal-macapp
//
//  Created by arm_mac on 2021/10/21.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        id <MTLDevice> device = MTLCreateSystemDefaultDevice();
        NSLog(@" %@", device.name);
        // id <MTLLibrary> defaultLibrary   = [device newDefaultLibrary];
        // id <MTLFunction> fragmentProgram = [defaultLibrary newFunctionWithName:@"basic_fragment"];
    }
    return 0;
}
