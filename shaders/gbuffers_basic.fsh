#version 330 compatibility

uniform sampler2D lightmap;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec4 glcolor;

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
	vec4 lightSample = texture(lightmap, lmcoord);
	color = glcolor * lightSample;
	
	// Amplify bright light sources for environmental effect
	float lightBrightness = max(lightSample.r, lightSample.g);
	if(lightBrightness > 0.7) {
		color.rgb += color.rgb * (lightBrightness - 0.7) * 0.8;
	}
	
	color = retroGreen(color);
	if (color.a < alphaTestRef) {
		discard;
	}
}