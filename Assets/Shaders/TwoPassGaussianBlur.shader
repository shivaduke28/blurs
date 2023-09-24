Shader "Blur/TwoPassGaussianBlur"
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

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        float _Sigma;

        #define KERNEL_RADIUS 4

        inline float un_normalized_gaussian(float x, float sigma)
        {
            return exp(- (x * x) / (2 * sigma * sigma));
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
                float4 color;
                float2 uv = i.uv;
                float sum = 0;
                for (int i = -KERNEL_RADIUS; i <= KERNEL_RADIUS; i++)
                {
                    float x = (float)i * _MainTex_TexelSize.x;
                    float weight = un_normalized_gaussian(x, _Sigma);
                    color += tex2Dlod(_MainTex, float4(uv + float2(x, 0), 0, 0)) * weight;
                    sum += weight;
                }
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
                float4 color;
                float2 uv = i.uv;
                float sum = 0;
                for (int i = -KERNEL_RADIUS; i <= KERNEL_RADIUS; i++)
                {
                    float y = (float)i * _MainTex_TexelSize.y;
                    float weight = un_normalized_gaussian(y, _Sigma);
                    color += tex2Dlod(_MainTex, float4(uv + float2(0, y), 0, 0)) * weight;
                    sum += weight;
                }
                return color / sum;
            }
            ENDCG
        }

    }
}