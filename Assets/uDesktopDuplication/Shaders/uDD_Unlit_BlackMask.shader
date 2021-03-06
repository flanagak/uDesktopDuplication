﻿Shader "uDesktopDuplication/Unlit BlackMask"
{

Properties
{
    _Color ("Color", Color) = (1, 1, 1, 1)
    _MainTex ("Texture", 2D) = "white" {}
    _Mask ("Mask", Range(0, 1)) = 0.1
    _CursorTex ("Cursor Texture", 2D) = "white" {}
    [KeywordEnum(Y, Z)] _Forward("Mesh Forward Direction", Int) = 0
    [Toggle(BEND_ON)] _Bend("Use Bend", Int) = 0
    [PowerSlider(10.0)] _Radius("Bend Radius", Range(1, 100)) = 30
    [PowerSlider(10.0)] _Thickness("Thickness", Range(0.01, 10)) = 1
    [KeywordEnum(Off, Front, Back)] _Cull("Culling", Int) = 2
}

SubShader
{

Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

Cull [_Cull]
ZWrite On
Blend SrcAlpha OneMinusSrcAlpha

CGINCLUDE

#include "./uDD_Common.cginc"

fixed _Mask;
half _Radius;
half _Width;
half _Thickness;

v2f vert(appdata v)
{
    v2f o;
    uddBendVertex(v.vertex, _Radius, _Width, _Thickness);
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    return o;
}

fixed4 frag(v2f i) : SV_Target
{
    fixed4 tex = uddGetScreenTexture(i.uv);
    fixed alpha = pow((tex.r + tex.g + tex.b) / 3.0, _Mask);
    return fixed4(tex.rgb * _Color.rgb, alpha * _Color.a);
}

ENDCG

Pass
{
    CGPROGRAM
    #pragma vertex vert
    #pragma fragment frag
    #pragma multi_compile ___ INVERT_X
    #pragma multi_compile ___ INVERT_Y
    #pragma multi_compile ___ ROTATE90 ROTATE180 ROTATE270
    #pragma multi_compile ___ USE_BEND
    #pragma multi_compile ___ USE_CLIP
    #pragma multi_compile _BEND_OFF _BEND_Y _BEND_Z
    ENDCG
}

}

Fallback "Unlit/Texture"

}
