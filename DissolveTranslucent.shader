// This is gonna hurt. Tell my wife I said "Hello."
Shader "Custom/Translucent-Dissolve"
{
    Properties
    {
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normal (Normal)", 2D) = "bump" {}

		// Translucent Properties
		_SpecColor("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
		_Shininess("Shininess", Range(0.03, 1)) = 0.078125
		_Thickness("Thickness (R)", 2D) = "bump" {}
		_Power("Subsurface Power", Float) = 1.0
		_Distortion("Subsurface Distortion", Float) = 0.0
		_Scale("Subsurface Scale", Float) = 0.5
		_SubColor("Subsurface Color", Color) = (1.0, 1.0, 1.0, 1.0)

		// Dissolve Properties
		_SliceGuide("Slice Guide (RGB)", 2D) = "white" {}
		_SliceAmount("Slice Amount", Range(0.0, 1.0)) = 0
		_BurnSize("Burn Size", Range(0.0, 1.0)) = 0.15
		_BurnRamp("Burn Ramp (RGB)", 2D) = "white" {}
		_BurnColor("Burn Color", Color) = (1,1,1,1)
		_EmissionAmount("Emission amount", float) = 2.0
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Translucent
		#pragma exclude_renderers flash
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BumpMap; 
		sampler2D _Thickness;
		float _Scale; 
		float _Power; 
		float _Distortion;
		fixed4 _Color;
		fixed4 _SubColor;
		half _Shininess;
		sampler2D _SliceGuide;
		sampler2D _BurnRamp;
		fixed4 _BurnColor;
		float _BurnSize;
		float _SliceAmount;
		float _EmissionAmount;

		struct Input {
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutput o) {
			//fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			half test = tex2D(_SliceGuide, IN.uv_MainTex).rgb - _SliceAmount;
			clip(test);

			if (test < _BurnSize && _SliceAmount > 0) {
				o.Emission = tex2D(_BurnRamp, float2(test * (1 / _BurnSize), 0)) * _BurnColor * _EmissionAmount;
			}

			o.Albedo = c.rgb;
			o.Alpha = tex2D(_Thickness, IN.uv_MainTex).r * c.a;
			o.Gloss = c.a;
			//o.Albedo = tex.rgb * _Color.rgb;
			//o.Alpha = tex2D(_Thickness, IN.uv_MainTex).r;
			//o.Gloss = tex.a;
			o.Specular = _Shininess;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
		}

		inline fixed4 LightingTranslucent(SurfaceOutput s, fixed3 lightDir, fixed3 viewDir, fixed atten)
		{
			// You can remove these two lines,
			// to save some instructions. They're just
			// here for visual fidelity.
			viewDir = normalize(viewDir);
			lightDir = normalize(lightDir);

			// Translucency.
			half3 transLightDir = lightDir + s.Normal * _Distortion;
			float transDot = pow(max(0, dot(viewDir, -transLightDir)), _Power) * _Scale;
			fixed3 transLight = (atten * 2) * (transDot)* s.Alpha * _SubColor.rgb;
			fixed3 transAlbedo = s.Albedo * _LightColor0.rgb * transLight;

			// Regular BlinnPhong.
			half3 h = normalize(lightDir + viewDir);
			fixed diff = max(0, dot(s.Normal, lightDir));
			float nh = max(0, dot(s.Normal, h));
			float spec = pow(nh, s.Specular*128.0) * s.Gloss;
			fixed3 diffAlbedo = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * _SpecColor.rgb * spec) * (atten * 2);

			// Add the two together.
			fixed4 c;
			c.rgb = diffAlbedo + transAlbedo;
			c.a = _LightColor0.a * _SpecColor.a * spec * atten;
			return c;
		}

		ENDCG

    }
    FallBack "Diffuse"
}
