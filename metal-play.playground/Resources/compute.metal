#include <metal_stdlib>
using namespace metal;

kernel void add(const device float2 *in [[ buffer(0) ]],
                device float  *out [[ buffer(1) ]],
                uint id [[ thread_position_in_grid ]]) {
  out[id] = in[id].x + in[id].y;
}

kernel void compare(const device float4 *inputX [[ buffer(0) ]],
                const device float4 *inputY [[ buffer(1) ]],
                device float4  *output [[ buffer(2) ]],
                uint id [[ thread_position_in_grid ]]) {
  output[id] = select(float4(0.0), float4(1.0), (inputX[id] >= inputY[id]));
}
