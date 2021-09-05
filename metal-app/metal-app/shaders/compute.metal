//
//  compute.metal
//  metal-app
//
//  Created by Apple on 2021/9/4.
//

#include <metal_stdlib>
using namespace metal;

kernel void compute(texture2d<float, access::write> output [[texture(0)]],
                    texture2d<float, access::sample> input [[texture(1)]],
                    constant float &timer [[buffer(0)]],
                    uint2 gid [[thread_position_in_grid]])
{
    float4 color = input.read(gid);
    output.write(color, gid);
}

#define ftype half
#define ftype4 half4

struct MetalParams {
    int input_width;
    int input_height;
    int input_size;
    int input_slice;
    int output_width;
    int output_height;
    int output_size;
    int output_slice;
    int batch;
};

kernel void mul_normal(const device ftype4 *src0 [[buffer(0)]],
                       const device ftype4 *src1 [[buffer(1)]],
                       device ftype4 *dst        [[buffer(2)]],
                       constant MetalParams& params     [[buffer(3)]],
                       uint3 gid [[thread_position_in_grid]]) {
    if (any(gid >= uint3(params.output_size, params.output_slice, params.batch)))
        return;
    
    int index_in = (int)gid.z * params.input_slice * params.input_size  + (int)gid.y * params.input_size + (int)gid.x;
    int index_out = (int)gid.z * params.output_slice * params.output_size + (int)gid.y * params.output_size + (int)gid.x;
    
    dst[index_out] = src0[index_in] * src1[index_in];
}
