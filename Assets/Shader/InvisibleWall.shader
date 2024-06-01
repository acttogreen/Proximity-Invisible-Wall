Shader "Custom/InvisibleWallShader"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTex("Main Texture", 2D) = "white" {}
        _PlayerPos("Player Position", Vector) = (0, 0, 0, 0)
        _Range("Range", Float) = 5.0
        _Transparency("Transparency", Range(0, 1)) = 0.5
        _MainTex_Tiling("Main Tex Tiling", Vector) = (1, 1, 0, 0)
        _ScrollSpeed("Scroll Speed", Vector) = (0.1, 0.1, 0, 0)
        _ProjectionMask("Projection Mask", 2D) = "white" {}
        _ProjectionMask_Tiling("Projection Mask Tiling", Vector) = (1, 1, 0, 0)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        LOD 200

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
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
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _ProjectionMask;
            float4 _Color;
            float4 _PlayerPos;
            float _Range;
            float _Transparency;
            float4 _MainTex_Tiling;
            float4 _ScrollSpeed;
            float4 _ProjectionMask_Tiling;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float2 scrollOffset = _ScrollSpeed.xy * _Time.y;
                o.uv = v.uv * _MainTex_Tiling.xy + _MainTex_Tiling.zw + scrollOffset;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float dist = distance(i.worldPos, _PlayerPos.xyz);
                float mask = smoothstep(_Range, 0.0, dist);

                fixed4 mainTex = tex2D(_MainTex, i.uv) * _Color;
                mainTex.a *= _Transparency;

                // Apply projection mask with tiling
                float2 maskedUV = i.uv * _ProjectionMask_Tiling.xy;
                fixed4 projectionMask = tex2D(_ProjectionMask, maskedUV);
                mainTex.a *= projectionMask.a;

                // Apply radial mask based on player position
                mainTex.a *= mask;

                return mainTex;
            }
            ENDCG
        }
    }
    Fallback "Transparent/Cutout/VertexLit"
}
