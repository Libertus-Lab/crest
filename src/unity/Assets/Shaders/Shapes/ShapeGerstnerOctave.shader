// This file is subject to the MIT License as seen in the root of this folder structure (LICENSE)

// A single Gerstner Octave
Shader "Ocean/Shape/Gerstner Octave"
{
	Properties
	{
		_Amplitude ("Amplitude", float) = 1
		_Wavelength("Wavelength", range(0,180)) = 100
		_Angle ("Angle", range(-180, 180)) = 0
	}

	Category
	{
		Tags{ "Queue" = "Transparent" }

		SubShader
		{
			Pass
			{
				Name "BASE"
				Tags { "LightMode" = "Always" }
				Blend One One
			
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fog
				#include "UnityCG.cginc"
				#include "MultiscaleShape.cginc"

				#define PI 3.141592653

				struct appdata_t {
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD0;
					float3 color : COLOR0;
				};

				struct v2f {
					float4 vertex : SV_POSITION;
					float3 worldPos : TEXCOORD0;
					float3 weight : COLOR0;
				};

				#define MAX_COMPONENTS_PER_OCTAVE 32

				uniform float _Wavelengths[MAX_COMPONENTS_PER_OCTAVE];
				uniform float _Amplitudes[MAX_COMPONENTS_PER_OCTAVE];

				v2f vert( appdata_t v )
				{
					v2f o;
					o.vertex = UnityObjectToClipPos( v.vertex );
					o.worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
					o.weight = v.color;

					//o.weight *= ComputeSortedShapeWeight(_Wavelengths[i]);

					return o;
				}

				// respects the gui option to freeze time
				uniform float _MyTime;
				uniform float _Chop;
				uniform float _Angles[MAX_COMPONENTS_PER_OCTAVE];
				uniform float _Phases[MAX_COMPONENTS_PER_OCTAVE];

				float3 frag (v2f i) : SV_Target
				{
					float3 result = (float3)0.;

					for (int j = 0; j < MAX_COMPONENTS_PER_OCTAVE; j++)
					{
						if (_Wavelengths[j] == 0.)
							break;

						float C = ComputeWaveSpeed(_Wavelengths[j]);

						// direction
						float2 D = float2(cos(PI * _Angles[j] / 180.0), sin(PI * _Angles[j] / 180.0));
						// wave number
						float k = 2. * PI / _Wavelengths[j];

						float3 result_i;

						float x = dot(D, i.worldPos.xz);
						result_i.y = _Amplitudes[j] * cos(k*(x + C*_MyTime) + _Phases[j]);
						result_i.xz = -_Chop * D * _Amplitudes[j] * sin(k*(x + C * _MyTime) + _Phases[j]);

						result_i *= i.weight.x;

						result += result_i;
					}

					return result;
				}

				ENDCG
			}
		}
	}
}
