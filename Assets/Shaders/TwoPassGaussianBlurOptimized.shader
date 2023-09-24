Shader "Blur/TwoPassGaussianBlurOptimized"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        CGINCLUDE
        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        Texture2D _MainTex;
        float4 _MainTex_TexelSize;
        SamplerState linear_clamp_sampler;
        float _Sigma;

        #define KERNEL_RADIUS 4

        inline float un_normalized_gaussian(float x, float sigma)
        {
            return exp(- (x * x) / (2 * sigma * sigma));
        }

        float get_offset(float delta, float p, out float weight)
        {
            float w1 = un_normalized_gaussian(delta * p, _Sigma);
            float w2 = un_normalized_gaussian(delta * (p + 1.0), _Sigma);
            weight = w1 + w2;
            return delta * (p + w1 / weight);
        }
        ENDCG

        Cull Off ZWrite Off ZTest Always

        Pass
        {
            Name "Horizontal"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                #if UNITY_UV_STARTS_AT_TOP
                o.uv.y = 1 - o.uv.y;
                #endif
                return o;
            }


            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float sum = 0;

                float delta = _MainTex_TexelSize.x;
                float weight0 = un_normalized_gaussian(0, _Sigma);
                float4 color = _MainTex.Sample(linear_clamp_sampler, uv, 0) * weight0;
                sum += weight0;

                float weight1;
                float offset1 = get_offset(delta, 1.0, weight1);
                color += _MainTex.SampleBias(linear_clamp_sampler, uv + float2(offset1, 0), 1) * weight1;
                color += _MainTex.SampleBias(linear_clamp_sampler, uv - float2(offset1, 0), 1) * weight1;
                sum += weight1 * 2.0;

                float weight2;
                float offset2 = get_offset(delta, 3.0, weight2);
                color += _MainTex.SampleBias(linear_clamp_sampler, uv + float2(offset2, 0), 1) * weight2;
                color += _MainTex.SampleBias(linear_clamp_sampler, uv - float2(offset2, 0), 1) * weight2;
                sum += weight2 * 2.0;
                return color / sum;
            }
            ENDCG
        }
        Pass
        {
            Name "Vertical"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float sum = 0;

                float delta = _MainTex_TexelSize.y;
                float weight0 = un_normalized_gaussian(0, _Sigma);
                float4 color = _MainTex.Sample(linear_clamp_sampler, uv, 0) * weight0;
                sum += weight0;

                float weight1;
                float offset1 = get_offset(delta, 1.0, weight1);
                color += _MainTex.SampleBias(linear_clamp_sampler, uv + float2(0, offset1), 1) * weight1;
                color += _MainTex.SampleBias(linear_clamp_sampler, uv - float2(0, offset1), 1) * weight1;
                sum += weight1 * 2.0;

                float weight2;
                float offset2 = get_offset(delta, 3.0, weight2);
                color += _MainTex.SampleBias(linear_clamp_sampler, uv + float2(0, offset2), 1) * weight2;
                color += _MainTex.SampleBias(linear_clamp_sampler, uv - float2(0, offset2), 1) * weight2;
                sum += weight2 * 2.0;
                return color / sum;
            }
            ENDCG
        }

    }
}