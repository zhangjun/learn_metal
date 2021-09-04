//
//  basic.metal
//  metal-app
//
//  Created by Apple on 2021/9/4.
//

#include <metal_stdlib>
using namespace metal;

kernel void square(const device float* input [[buffer(0)]],
                   device float* output [[buffer(1)]],
                   uint id [[thread_position_in_grid]]) {
  output[id] = input[id] * input[id];
}

kernel void add(const device float2 *input [[ buffer(0) ]],
                device float  *output [[ buffer(1) ]],
                uint id [[ thread_position_in_grid ]]) {
  output[id] = input[id].x + input[id].y;
}

kernel void add_tex(texture2d<float, access::sample> inTexture [[texture(0)]],
                        texture2d<float, access::write> outTexture [[texture(1)]],
                        const device int *radiusBuf [[buffer(0)]],
                        const device float *sumOfWeight [[buffer(1)]],
                        uint2 gid [[thread_position_in_grid]]) {
    if (gid.x >= outTexture.get_width() ||
        gid.y >= outTexture.get_height()) {
        return;
    }
    float4 input = inTexture.read(gid.xy);
    outTexture.write(input, gid.xy);
}
