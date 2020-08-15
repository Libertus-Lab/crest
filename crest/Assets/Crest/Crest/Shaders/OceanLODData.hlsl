// Crest Ocean System

// This file is subject to the MIT License as seen in the root of this folder structure (LICENSE)

// Ocean LOD data - data, samplers and functions associated with LODs

// Conversions for world space from/to UV space. All these should *not* be clamped otherwise they'll break fullscreen triangles.

float2 LD_UVToWorld(in float2 i_uv, in float2 i_centerPos, in float i_res, in float i_texelSize)
{
	return i_texelSize * i_res * (i_uv - 0.5) + i_centerPos;
}

float2 UVToWorld(in float2 i_uv, in float i_sliceIndex) { return LD_UVToWorld(i_uv, _LD_Pos_Scale[i_sliceIndex].xy, _LD_Params[i_sliceIndex].y, _LD_Params[i_sliceIndex].x); }

// Shortcuts if _LD_SliceIndex is set
float2 UVToWorld(in float2 i_uv) { return UVToWorld(i_uv, _LD_SliceIndex); }
