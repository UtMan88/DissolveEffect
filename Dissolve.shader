// Source: https://halisavakis.com/my-take-on-shaders-dissolve-shader/
Shader "Custom/Dissolve" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Metallic("Metallic", Range(0,1)) = 0.0
		_Glossiness("Smoothness", Range(0,1)) = 0.0
		_SliceGuide("Slice Guide (RGB)", 2D) = "white" {}
		_SliceAmount("Slice Amount", Range(0.0, 1.0)) = 0

		_BurnSize("Burn Size", Range(0.0, 1.0)) = 0.15
		_BurnRamp("Burn Ramp (RGB)", 2D) = "white" {}
		_BurnColor("Burn Color", Color) = (1,1,1,1)

		_EmissionAmount("Emission amount", float) = 2.0
	}
	SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200
		Cull Off
		CGPROGRAM
#pragma surface surf Standard addshadow
#pragma target 3.0

		fixed4 _Color;
	sampler2D _MainTex;
	half _Glossiness;
	half _Metallic;
	sampler2D _SliceGuide;
	sampler2D _BumpMap;
	sampler2D _BurnRamp;
	fixed4 _BurnColor;
	float _BurnSize;
	float _SliceAmount;
	float _EmissionAmount;

	struct Input {
		float2 uv_MainTex;
	};


	void surf(Input IN, inout SurfaceOutputStandard o) {
		fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
		half test = tex2D(_SliceGuide, IN.uv_MainTex).rgb - _SliceAmount;
		clip(test);

		if (test < _BurnSize && _SliceAmount > 0) {
			o.Emission = tex2D(_BurnRamp, float2(test * (1 / _BurnSize), 0)) * _BurnColor * _EmissionAmount;
		}

		o.Albedo = c.rgb;
		o.Alpha = c.a;
		o.Metallic = _Metallic;
		o.Smoothness = _Glossiness;
	}
	ENDCG
	}
		FallBack "Diffuse"
}