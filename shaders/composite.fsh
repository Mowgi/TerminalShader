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

vec3 bloomEffect(sampler2D tex, vec2 uv, vec2 pixelSize) {
	// Sample bloom from surrounding pixels for light spread
	vec3 bloom = vec3(0.0);
	float bloomStrength = 0.05;
	
	// Multi-scale bloom sampling
	float distances[5] = float[](2.0, 4.0, 6.0, 8.0, 10.0);
	float weights[5] = float[](0.25, 0.20, 0.15, 0.10, 0.05);
	
	for(int i = 0; i < 5; i++) {
		vec2 offset = pixelSize * distances[i];
		// Sample in cross pattern for light rays
		bloom += texture(tex, uv + vec2(offset.x, 0.0)).rgb * weights[i];
		bloom += texture(tex, uv - vec2(offset.x, 0.0)).rgb * weights[i];
		bloom += texture(tex, uv + vec2(0.0, offset.y)).rgb * weights[i];
		bloom += texture(tex, uv - vec2(0.0, offset.y)).rgb * weights[i];
	}
	
	return bloom * bloomStrength;
}

vec3 lightShafts(sampler2D tex, vec2 uv, vec2 pixelSize) {
	// Create god rays / light shaft effect
	vec3 shafts = vec3(0.0);
	vec2 center = vec2(0.5); // Screen center as light source
	vec2 direction = normalize(uv - center);
	
	float intensity = 0.02;
	float raySteps = 8.0;
	
	for(float i = 0.0; i < raySteps; i++) {
		vec2 rayPos = uv - direction * (i / raySteps) * 0.15;
		vec3 rayColor = texture(tex, rayPos).rgb;
		float rayBright = max(rayColor.g, 0.0); // Green channel
		shafts += rayColor * rayBright * intensity;
	}
	
	return shafts;
}

vec3 neonEdgeGlow(sampler2D tex, vec2 uv, vec2 pixelSize) {
	// Detect edges in bright areas and add neon glow
	vec3 center = texture(tex, uv).rgb;
	float centerBright = max(center.g, 0.0);
	
	// Sample neighboring pixels for edge detection
	float edges = 0.0;
	
	// Simple edge detection - sample around pixel
	vec2 offsets[8] = vec2[](
		vec2(-1, -1), vec2(0, -1), vec2(1, -1),
		vec2(-1,  0),             vec2(1,  0),
		vec2(-1,  1), vec2(0,  1), vec2(1,  1)
	);
	
	float edgeWeight = 0.0;
	for(int i = 0; i < 8; i++) {
		vec3 sampleCol = texture(tex, uv + offsets[i] * pixelSize * 1.5).rgb;
		float sampleBright = max(sampleCol.g, 0.0);
		edges += abs(sampleBright - centerBright) * 0.12;
		edgeWeight += 1.0;
	}
	
	edges = edges / edgeWeight;
	// Only glow on edges of bright areas
	edges = max(edges - 0.2, 0.0) * 1.5;
	return vec3(0.0, edges * centerBright, 0.0);
}

void main() {
	vec2 pixelSize = vec2(1.0 / viewWidth, 1.0 / viewHeight);
	color = texture(colortex0, texcoord);
	
	// Apply green monochrome with enhanced lighting
	color = retroGreen(color);
}