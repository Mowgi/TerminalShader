#version 330 compatibility

uniform sampler2D colortex0;
uniform float viewWidth;
uniform float viewHeight;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

vec4 retroGreen(vec4 col) {
	// Preserve texture detail - map grayscale to green spectrum
	float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));
	// Map to varying shades of green based on brightness with more contrast in dark areas
	float brightness = mix(0.0, 0.7, pow(gray, 0.5)); // Pure black to moderate bright green
	return vec4(vec3(0.0, brightness, 0.0), col.a);
}

void main() {
	vec2 pixelSize = vec2(1.0 / viewWidth, 1.0 / viewHeight);
	color = texture(colortex0, texcoord);
	
	// Apply green monochrome
	color = retroGreen(color);
}
}