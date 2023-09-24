Shader "Blur/NaiveGaussianBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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

            sampler2D _MainTex;
            // 1/w, 1/h, w, h
            float4 _MainTex_TexelSize;
            float _Sigma;

            #define KERNEL_RADIUS 4

            inline float un_normalized_gaussian_2d(float x, float y, float sigma)
            {
                return exp(- (x * x + y * y) / (2 * sigma * sigma));
            }

            // not used
            float gaussian(float x, float sigma)
            {
                return 1 / (sqrt(UNITY_TWO_PI) * sigma) * exp(- x * x / (2 * sigma * sigma));
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 color;
                float2 uv = i.uv;
                float sum = 0;
                for (int i = -KERNEL_RADIUS; i <= KERNEL_RADIUS; i++)
                {
                    float x = (float)i * _MainTex_TexelSize.x;
                    for (int j = -KERNEL_RADIUS; j <= KERNEL_RADIUS; j++)
                    {
                        float y = (float)j * _MainTex_TexelSize.y;
                        float weight = un_normalized_gaussian_2d(x, y, _Sigma);
                        color += tex2Dlod(_MainTex, float4(uv + float2(x, y), 0, 0)) * weight;
                        sum += weight;
                    }
                }
                return color / sum;
            }
            ENDCG
        }
    }
}