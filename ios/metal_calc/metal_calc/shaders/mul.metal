//
//  mul.metal
//  metal_calc
//
//  Created by Apple on 2021/11/6.
//

#include <metal_stdlib>
using namespace metal;

typedef float ftype;
typedef float4 ftype4;

kernel void mul(texture2d_array<ftype, access::sample> inputX[[texture(0)]],
    texture2d_array<ftype, access::sample> inputY[[texture(1)]],
    texture2d_array<ftype, access::write> outTexture[[texture(2)]],
    uint3 gid[[thread_position_in_grid]]) {
    if (gid.x >= outTexture.get_width() || gid.y >= outTexture.get_height() ||
        gid.z >= outTexture.get_array_size())
        return;
    constexpr sampler sample(coord::pixel, filter::nearest, address::clamp_to_zero);
    int xLen = inputX.get_width();
    ftype4 r = ftype4(0, 0, 0, 0);
    for (int i = 0; i < xLen; i++) {
        ftype4 iX = inputX.sample(sample, float2(i, gid.y), 0);
        ftype4 iY1 = inputY.sample(sample, float2(gid.x, i * 4), 0);
        ftype4 iY2 = inputY.sample(sample, float2(gid.x, i * 4 + 1), 0);
        ftype4 iY3 = inputY.sample(sample, float2(gid.x, i * 4 + 2), 0);
        ftype4 iY4 = inputY.sample(sample, float2(gid.x, i * 4 + 3), 0);
        ftype4 tY1 = ftype4(iY1.x, iY2.x, iY3.x, iY4.x);
        ftype4 tY2 = ftype4(iY1.y, iY2.y, iY3.y, iY4.y);
        ftype4 tY3 = ftype4(iY1.z, iY2.z, iY3.z, iY4.z);
        ftype4 tY4 = ftype4(iY1.w, iY2.w, iY3.w, iY4.w);
        r.x += dot(iX, tY1);
        r.y += dot(iX, tY2);
        r.z += dot(iX, tY3);
        r.w += dot(iX, tY4);
    }
    outTexture.write(r, gid.xy, gid.z);
}

kernel void mul_add(texture2d_array<ftype, access::sample> inputX[[texture(0)]],
    texture2d_array<ftype, access::sample> inputY[[texture(1)]],
    texture2d_array<ftype, access::sample> biasY[[texture(2)]],
    texture2d_array<ftype, access::write> outTexture[[texture(3)]],
    uint3 gid[[thread_position_in_grid]]) {
    if (gid.x >= outTexture.get_width() || gid.y >= outTexture.get_height() ||
        gid.z >= outTexture.get_array_size())
        return;
    constexpr sampler sample(coord::pixel, filter::nearest, address::clamp_to_zero);
    int xLen = inputX.get_array_size();
    ftype4 r = ftype4(0, 0, 0, 0);
    for (int i = 0; i < xLen; i++) {
        ftype4 iX = inputX.sample(sample, float2(0, 0), i);
        ftype4 iY1 = inputY.sample(sample, float2(i * 4, 0), gid.z);
        ftype4 iY2 = inputY.sample(sample, float2(i * 4 + 1, 0), gid.z);
        ftype4 iY3 = inputY.sample(sample, float2(i * 4 + 2, 0), gid.z);
        ftype4 iY4 = inputY.sample(sample, float2(i * 4 + 3, 0), gid.z);
        ftype4 tY1 = ftype4(iY1.x, iY2.x, iY3.x, iY4.x);
        ftype4 tY2 = ftype4(iY1.y, iY2.y, iY3.y, iY4.y);
        ftype4 tY3 = ftype4(iY1.z, iY2.z, iY3.z, iY4.z);
        ftype4 tY4 = ftype4(iY1.w, iY2.w, iY3.w, iY4.w);
        r.x += dot(iX, tY1);
        r.y += dot(iX, tY2);
        r.z += dot(iX, tY3);
        r.w += dot(iX, tY4);
    }
    r += biasY.sample(sample, float2(0, 0), gid.z);
    outTexture.write(r, gid.xy, gid.z);
}


kernel void mat_mul(texture2d_array<ftype, access::sample> inputX[[texture(0)]],
    texture2d_array<ftype, access::sample> inputY[[texture(1)]],
    texture2d_array<ftype, access::write> outTexture[[texture(2)]],
    uint3 gid[[thread_position_in_grid]]) {
    if (gid.x >= outTexture.get_width() || gid.y >= outTexture.get_height() ||
        gid.z >= outTexture.get_array_size())
        return;
    constexpr sampler sample(coord::pixel, filter::nearest, address::clamp_to_zero);
    int xLen = inputX.get_array_size();
    ftype4 r = ftype4(0, 0, 0, 0);
    for (int i = 0; i < xLen; i++) {
        ftype4 iX = inputX.sample(sample, float2(gid.x, gid.y), i);

        ftype4 iY1 = inputY.sample(sample, float2(gid.x, gid.y), i);
        ftype4 iY2 = inputY.sample(sample, float2(gid.x + 1, gid.y), i);
        ftype4 iY3 = inputY.sample(sample, float2(gid.x + 2, gid.y), i);
        ftype4 iY4 = inputY.sample(sample, float2(gid.x + 3, gid.y), i);

        r.x += dot(iX, iY1);
        r.y += dot(iX, iY2);
        r.z += dot(iX, iY3);
        r.w += dot(iX, iY4);
    }
    outTexture.write(r, gid.xy, gid.z);
}

struct MetalMatMulParams {
    int batch_c;
    int batch_a;
    int batch_b;
    int M;
    int N;
    int K;
};

kernel void matmul_common(const device ftype *mat_a  [[buffer(0)]],
                          const device ftype *mat_b     [[buffer(1)]],
                          device ftype *mat_c   [[buffer(2)]],
                          constant MetalMatMulParams & params  [[buffer(3)]],
                           uint3 gid   [[thread_position_in_grid]]) {
    if ((int)gid.x >= params.K || (int)gid.y >= params.M || (int)gid.z >= params.batch_c) return;
        int batch_a = (int)gid.z % params.batch_a;
        int batch_b = (int)gid.z % params.batch_b;

        auto ptr_a = mat_a + (batch_a * params.M + (int)gid.y) * params.N;
        auto ptr_b = mat_b + (batch_b * params.K * params.N) + (int)gid.x;

        ftype result = 0;
        for(int i = 0; i < params.N; i++){
            auto a_t =  ptr_a + i;
            auto b_t =  ptr_b + i * params.K;
            result += ftype(*a_t) * ftype(*b_t);
        }

        mat_c[((int)gid.z*params.M + (int)gid.y) * params.K + (int)gid.x] = ftype(result);
}
