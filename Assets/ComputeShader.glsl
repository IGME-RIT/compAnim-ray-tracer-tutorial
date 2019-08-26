/*
Title: Advanced Ray Tracer
File Name: FragmentShader.glsl
Copyright © 2019
Original authors: Niko Procopi
Written under the supervision of David I. Schwartz, Ph.D., and
supported by a professional development seed grant from the B. Thomas
Golisano College of Computing & Information Sciences
(https://www.rit.edu/gccis) at the Rochester Institute of Technology.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

References:
https://github.com/LWJGL/lwjgl3-wiki/wiki/2.6.1.-Ray-tracing-with-OpenGL-Compute-Shaders-(Part-I)

Description:
This program serves to demonstrate the concept of ray tracing. This
builds off a previous Intermediate Ray Tracer, adding in reflections. 
There are four point lights, specular and diffuse lighting, and shadows. 
It is important to note that the light positions and triangles being 
rendered are all hardcoded in the shader itself. Usually, you would 
pass those values into the Fragment Shader via a Uniform Buffer.

WARNING: Framerate may suffer depending on your hardware. This is a normal 
problem with Ray Tracing. If it runs too slowly, try removing the second 
cube from the triangles array in the Fragment Shader (and also adjusting 
NUM_TRIANGLES accordingly). There are many optimization techniques out 
there, but ultimately Ray Tracing is not typically used for Real-Time 
rendering.
*/

// Compute shaders are part of openGL core since version 4.3
#version 430

// Inputs from the particle system.
uniform float time;

struct triangle {
	vec3 a;
	vec3 b;
	vec3 c;
	vec3 normal;
	vec3 color;
};

struct light {
	vec3 pos;
	vec3 color;
	float radius;
	float brightness;
};


light lights[] = light[1](
	//pos, color, radius, brightness

	// white light
	light(vec3(-1.0, 4.0, -1.0), vec3(1.0, 1.0, 1.0), 7.0, 1.0)
);

// Here we are setting the triangles up as constants in the shader code itself.
// Obviously, these could be passed in via uniform buffers as well. The key thing to realize here is that these values aren't being sent to the Vertex Shader.
triangle triangles[] = triangle[14](
	
	// Floor
	/* Top face triangles */
	triangle(vec3(-5.0, 0.0, 5.0), vec3(-5.0, 0.0, -5.0), vec3(5.0, 0.0, -5.0), vec3(0.0, 1.0, 0.0), vec3(1.0, 1.0, 1.0)),
	triangle(vec3(-5.0, 0.0, 5.0), vec3(5.0, 0.0, -5.0), vec3(5.0, 0.0, 5.0), vec3(0.0, 1.0, 0.0), vec3(1.0, 1.0, 1.0)),

	// Orange Box
	/* Cube Box */
	/* Back face triangles */
	triangle(vec3(-0.5, 1.0, -0.5), vec3(0.5, 1.0, -0.5), vec3(-0.5, 2.0, -0.5), vec3(0.0, 0.0, -1.0), vec3(1.0, 0.5, 0.1)),
	triangle(vec3(0.5, 1.0, -0.5), vec3(0.5, 2.0, -0.5), vec3(-0.5, 2.0, -0.5), vec3(0.0, 0.0, -1.0), vec3(1.0, 0.5, 0.1)),
	/* Front face triangles*/
	triangle(vec3(-0.5, 1.0, 0.5), vec3(-0.5, 2.0, 0.5), vec3(0.5, 2.0, 0.5), vec3(0.0, 0.0, 1.0), vec3(1.0, 0.5, 0.1)),
	triangle(vec3(-0.5, 1.0, 0.5), vec3(0.5, 2.0, 0.5), vec3(0.5, 1.0, 0.5), vec3(0.0, 0.0, 1.0), vec3(1.0, 0.5, 0.1)),
	/* Right face triangles */
	triangle(vec3(0.5, 1.0, 0.5), vec3(0.5, 2.0, 0.5), vec3(0.5, 2.0, -0.5), vec3(1.0, 0.0, 0.0), vec3(1.0, 0.5, 0.1)),
	triangle(vec3(0.5, 1.0, 0.5), vec3(0.5, 2.0, -0.5), vec3(0.5, 1.0, -0.5), vec3(1.0, 0.0, 0.0), vec3(1.0, 0.5, 0.1)),
	/* Left face triangles */
	triangle(vec3(-0.5, 1.0, -0.5), vec3(-0.5, 2.0, -0.5), vec3(-0.5, 2.0, 0.5), vec3(-1.0, 0.0, 0.0), vec3(1.0, 0.5, 0.1)),
	triangle(vec3(-0.5, 1.0, -0.5), vec3(-0.5, 2.0, 0.5), vec3(-0.5, 1.0, 0.5), vec3(-1.0, 0.0, 0.0), vec3(1.0, 0.5, 0.1)),
	/* Top face triangles */
	triangle(vec3(-0.5, 2.0, 0.5), vec3(-0.5, 2.0, -0.5), vec3(0.5, 2.0, -0.5), vec3(0.0, 1.0, 0.0), vec3(1.0, 0.5, 0.1)),
	triangle(vec3(-0.5, 2.0, 0.5), vec3(0.5, 2.0, -0.5), vec3(0.5, 2.0, 0.5), vec3(0.0, 1.0, 0.0), vec3(1.0, 0.5, 0.1)),
	/* Bottom face triangles */
	triangle(vec3(-0.5, 1.0, 0.5), vec3(0.5, 1.0, 0.5), vec3(0.5, 1.0, -0.5), vec3(0.0, -1.0, 0.0), vec3(1.0, 0.5, 0.1)),
	triangle(vec3(-0.5, 1.0, 0.5), vec3(0.5, 1.0, -0.5), vec3(-0.5, 1.0, -0.5), vec3(0.0, -1.0, 0.0), vec3(1.0, 0.5, 0.1))
);


// A layout describing the vertex buffer.
layout(binding = 0) buffer block
{
	light lights[1];
	triangle triangles[14];
} outBuffer;


// This will just run once for each particle.
layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

// Declare main program function which is executed when
void main()
{

	// Get the index of this object into the buffer
	uint i = gl_GlobalInvocationID.x;
	int j = i - 14;

	// move the cube
	if(i >= 0 && < 14)
	{
		if(i >= 2 && i < 14)
		{
			triangles[i].a.x += 4 * sin(time);
			triangles[i].b.x += 4 * sin(time);
			triangles[i].c.x += 4 * sin(time);
		}

		outBuffer.triangles[i] = triangles[i];
	}

	// move the light
	if(j >= 0)
	{
		if(j == 0)
		{
			lights[j].pos = vec3(
				2*sin(time),
				4,
				2*cos(time)
			);
		}

		outBuffer.lights[j] = lights[j];
	}
}