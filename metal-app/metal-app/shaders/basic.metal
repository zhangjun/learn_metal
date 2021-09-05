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

#define ftype half
#define ftype4 half4

kernel void compare(texture2d_array<ftype, access::read> inputX [[texture(0)]],
                    texture2d_array<ftype, access::read> inputY [[texture(1)]],
                    texture2d_array<ftype, access::write> outTexture [[texture(2)]],
                    uint3 gid [[thread_position_in_grid]]) {
    
  if (gid.x >= outTexture.get_width() || gid.y >= outTexture.get_height() ||
      gid.z >= outTexture.get_array_size())
      return;
  
  ftype4 rx = inputX.read(gid.xy, gid.z);
  ftype4 ry = inputY.read(gid.xy, gid.z);
  ftype4 out = ftype4(0.0);
  out = select(ftype4(0.0), ftype4(1.0), (rx >= ry));
  out = ftype4((rx.x >= ry.x) ? 1.0 : 0.0,
                       (rx.y >= ry.y) ? 1.0 : 0.0,
                       (rx.z >= ry.z) ? 1.0 : 0.0,
                       (rx.w >= ry.w) ? 1.0 : 0.0);
  outTexture.write(out, gid.xy, gid.z);
}
