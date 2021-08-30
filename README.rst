==========================================
gl3w++: Simple OpenGL core profile loading
==========================================

Changes
-------

Inspired by both `gl3w`_ and `glXXw`_. It differentiates itself from the former by
useing **CMake** instead of Python and thus natively integrateing with the
de-facto standard C/C++ build system and from the latter mostly by being
**up-to-date**.

Furthermore, it uses templates and thus aims to be **easier to modify** than the
former two.

Introduction
------------

`gl3w++`_ is the easiest way to get your hands on the functionality offered by the
OpenGL core profile specification. It provides the same features as `gl3w`_ but
uses CMake instead of Python and thus natively integrates with it.

Its main part is a simple gl3w_gen.cmake_ CMake script that provides a function
to download the `Khronos`_ supported `glcorearb.h`_ header and to generate gl3w.h
and gl3w.c from it. Those files can then be added and linked (statically or
dynamically) into your project.

Requirements
------------

CMake

Usage
-----

It can both be used stand-alone::

   cmake -P gl3w_gen.cmake

As well as from any CMake file by including the gl3w_gen.cmake file and calling
the provided function::

   LIST(APPEND CMAKE_MODULE_PATH "<path to this directory>")
   include(gl3w_gen)
   gl3w_gen([OUTDIR <dir>] [GET_EXTENSIONS])

Example
-------

Here is a simple example of using `gl3w`_ with glut. Note that GL/gl3w.h must be
included before any other OpenGL related headers::

   #include <stdiof.h>
   #include <GL/gl3w.h>
   #include <GL/glut.h>

   // ...

   int main(int argc, char **argv)
   {
           glutInit(&argc, argv);
           glutInitDisplayMode(GLUT_RGBA | GLUT_DEPTH | GLUT_DOUBLE);
           glutInitWindowSize(width, height);
           glutCreateWindow("cookie");

           glutReshapeFunc(reshape);
           glutDisplayFunc(display);
           glutKeyboardFunc(keyboard);
           glutSpecialFunc(special);
           glutMouseFunc(mouse);
           glutMotionFunc(motion);

           if (gl3wInit()) {
                   fprintf(stderr, "failed to initialize OpenGL\n");
                   return -1;
           }
           if (!gl3wIsSupported(3, 2)) {
                   fprintf(stderr, "OpenGL 3.2 not supported\n");
                   return -1;
           }
           printf("OpenGL %s, GLSL %s\n", glGetString(GL_VERSION),
                  glGetString(GL_SHADING_LANGUAGE_VERSION));

           // ...

           glutMainLoop();
           return 0;
   }

API Reference
-------------

The `gl3w`_ API consists of just three functions:

``int gl3wInit(void)``

    Initializes the library. Should be called once after an OpenGL context has
    been created. Returns ``0`` when `gl3w`_ was initialized successfully,
    ``non-zero`` if there was an error.

``int gl3wIsSupported(int major, int minor)``

    Returns ``1`` when OpenGL core profile version *major.minor* is available
    and ``0`` otherwise.

``GL3WglProc gl3wGetProcAddress(const char *proc)``

    Returns the address of an OpenGL extension function. Generally, you won't
    need to use it since `gl3w`_ loads all functions defined in the OpenGL core
    profile on initialization. It allows you to load OpenGL extensions outside
    of the core profile.

Options
-------

The generator function optionally takes the arguments:

``GET_EXTENSIONS`` to include the GL Extensions in output header.

``OUTPUTDIR <dir>`` to set the location for the output to something else than
the project directory.

License
-------

The templates and generated files are part of the public domain. See their
headers for more information.

For the license of the code please view LICENSE and NOTICE.

Credits
-------

Benedikt Schaber [https://github.com/benedikt-schaber]
    New & improved CMake implementation

Pavel Rojtberg [https://github.com/paroj]
    Initial CMake implementation

Slavomir Kaslev <slavomir.kaslev@gmail.com>
    Initial Python implementation

Copyright
---------

OpenGL_ is a registered trademark of SGI_.

.. _gl3w: https://github.com/skaslev/gl3w
.. _gl3w++: https://github.com/benedikt-schaber/gl3w-plus-plus
.. _glXXw: https://github.com/paroj/glXXw
.. _gl3w_gen.cmake:
   https://github.com/benedikt-schaber/gl3w++/blob/master/gl3w_gen.cmake
.. _glcorearb.h: https://www.opengl.org/registry/api/GL/glcorearb.h
.. _OpenGL: http://www.opengl.org/
.. _Khronos: http://www.khronos.org/
.. _SGI: http://www.sgi.com/
