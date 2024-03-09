// $MinimumShaderProfile: ps_3_0
// Black floor simulator

const static float peaknits  = 100.0;
const static float contrast  = 100.0;
const static float blackfloor = peaknits / contrast / 10000.0;

//PQ constants
const static float m1 = 2610.0 / 16384;
const static float m2 = 2523.0 / 32;
const static float m1inv = 16384 / 2610.0;
const static float m2inv = 32 / 2523.0;
const static float c1 = 3424 / 4096.0;
const static float c2 = 2413 / 128.0;
const static float c3 = 2392 / 128.0;

sampler s0 : register(s0);

// Convert PQ to linear RGB
float3 pq_to_lin(float3 pq) { 
  float3 p = pow(pq, m2inv);
  float3 d = max(p - c1, 0) / (c2 - c3 * p);
  return pow(d, m1inv);
}

// Convert linear RGB to PQ
float3 lin_to_pq(float3 lin) {
  float3 y = lin; 
  float3 p = (c1 + c2 * pow(y, m1)) / (1 + c3 * pow(y, m1));
  return pow(p, m2);
}

float4 main(float2 tex : TEXCOORD0) : COLOR {
	float4 c0 = tex2D(s0, tex);
	float3 lin = pq_to_lin(c0.rgb);     
	lin = lin + blackfloor;
	float3 rgb = lin_to_pq(lin);
	return float4(rgb.r, rgb.g, rgb.b, blackfloor); //store blackfloor in alpha channel for optional 2nd pass
}
