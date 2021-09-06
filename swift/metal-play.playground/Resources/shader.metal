#include <metal_stdlib>
using namespace metal;

using namespace metal;

typedef half ftype;
typedef half2 ftype2;
typedef half3 ftype3;
typedef half4 ftype4;
typedef half2x2 ftype2x2;
typedef half2x3 ftype2x3;
typedef half2x4 ftype2x4;
typedef half3x2 ftype3x2;
typedef half3x3 ftype3x3;
typedef half3x4 ftype3x4;
typedef half4x2 ftype4x2;
typedef half4x3 ftype4x3;
typedef half4x4 ftype4x4;

struct ShuffleChannelParam {
  uint32_t group;
  uint32_t channel_per_group;
};

kernel void shuffle_channel(
    texture2d_array<ftype, access::read> inTexture [[texture(0)]],
    texture2d_array<ftype, access::write> outTexture [[texture(1)]],
    constant ShuffleChannelParam &param [[buffer(0)]],
    uint3 gid [[thread_position_in_grid]]) {
  if (gid.x >= outTexture.get_width() || gid.y >= outTexture.get_height() ||
      gid.z >= outTexture.get_array_size())
    return;

  const uint group = param.group;
  const uint group_per_channel = param.channel_per_group;

  ftype4 output;
  for (int i = 0; i < 4; ++i) {
    uint out_ch_idx = gid.z * 4 + i;
    uint in_ch_idx = out_ch_idx % group * group_per_channel + out_ch_idx / group;
    uint input_z = in_ch_idx >> 2;
    const ftype4 input = inTexture.read(gid.xy, input_z);
    output[i] = input[in_ch_idx % 4];
  }
  outTexture.write(output, gid.xy, gid.z);
}
