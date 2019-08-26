Documentation Author: Niko Procopi 2019

This tutorial was designed for Visual Studio 2017 / 2019
If the solution does not compile, retarget the solution
to a different version of the Windows SDK. If you do not
have any version of the Windows SDK, it can be installed
from the Visual Studio Installer Tool

Welcome to the Compute Animation Tutorial!
Prerequesites: Basic Animation, Compute Shaders

This tutorial does the same thing as last tutorial,
except now the animation requires less processing.

Rather than processing the position of the light and the
positions of each cube vertex for every pixel, it does the
calculation once per frame, and then final results of the
positions are used for each pixel

A compute shader takes the original Lights and Triangles
array, modifies the array by altering positions, and then
sends the final arrays to a GPU buffer. This GPU buffer
is then read by the Fragment Shader while the Ray Tracing
shader program is running