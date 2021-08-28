/*

    This file was generated with gl3w_gen.cmake, part of glXXw
    (hosted at https://github.com/paroj/glXXw-cmake)

    This is free and unencumbered software released into the public domain.

    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.

    In jurisdictions that recognize copyright laws, the author or authors
    of this software dedicate any and all copyright interest in the
    software to the public domain. We make this dedication for the benefit
    of the public at large and to the detriment of our heirs and
    successors. We intend this dedication to be an overt act of
    relinquishment in perpetuity of all present and future rights to this
    software under copyright law.

    THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
    OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    OTHER DEALINGS IN THE SOFTWARE.

*/

#include <GL/gl3w.h>

#ifdef _WIN32
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN 1
#endif
#include <windows.h>

static HMODULE libgl;
static PROC (__stdcall *wgl_get_proc_address)(LPCSTR);

static void open_libgl(void)
{
    libgl = LoadLibraryA(\"opengl32.dll\");
    *(void **)(&wgl_get_proc_address) = GetProcAddress(libgl, \"wglGetProcAddress\");
}

static void close_libgl(void)
{
	FreeLibrary(libgl);
}

static GL3WglProc get_proc(const char *proc)
{
	GL3WglProc res;

	res = (GL3WglProc)wgl_get_proc_address(proc);
	if (!res)
		res = (GL3WglProc)GetProcAddress(libgl, proc);
	return res;
}
#elif defined(__APPLE__) || defined(__APPLE_CC__)
#include <dlfcn.h>

static void *libgl;

static void open_libgl(void)
{
	libgl = dlopen(\"/System/Library/Frameworks/OpenGL.framework/OpenGL\", RTLD_LAZY | RTLD_LOCAL);
}

static void close_libgl(void)
{
	dlclose(libgl);
}

static GL3WglProc get_proc(const char *proc)
{
    GL3WglProc res;

    *(void **)(&res) = dlsym(libgl, proc);
	return res;
}
#else
#include <dlfcn.h>

typedef GL3WglProc (*PFNGLXGETPROCADDRESSPROC)(const GLubyte *);
static void *libgl;
static PFNGLXGETPROCADDRESSPROC glx_get_proc_address;

static void open_libgl(void)
{
	libgl = dlopen(\"libGL.so.1\", RTLD_LAZY | RTLD_LOCAL);
    *(void **)(&glx_get_proc_address) = dlsym(libgl, \"glXGetProcAddressARB\");
}

static void close_libgl(void)
{
	dlclose(libgl);
}

static GL3WglProc get_proc(const char *proc)
{
	GL3WglProc res;

	res = glx_get_proc_address((const GLubyte *)proc);
    if (!res)
		*(void **)(&res) = dlsym(libgl, proc);
	return res;
}
#endif

static struct {
	int major, minor;
} version;

static int parse_version(void)
{
	if (!glGetIntegerv)
		return -1;

	glGetIntegerv(GL_MAJOR_VERSION, &version.major);
	glGetIntegerv(GL_MINOR_VERSION, &version.minor);

	if (version.major < 3)
		return -1;
	return 0;
}

static void load_procs(GL3WGetProcAddressProc proc);

int gl3wInit(void)
{
	open_libgl();
	load_procs(get_proc);
	close_libgl();
	return parse_version();
}

int gl3wInit2(GL3WGetProcAddressProc proc)
{
	load_procs(proc);
	return parse_version();
}

int gl3wIsSupported(int major, int minor)
{
	if (major < 3)
		return 0;
	if (version.major == major)
		return version.minor >= minor;
	return version.major >= major;
}

GL3WglProc gl3wGetProcAddress(const char *proc)
{
	return get_proc(proc);
}

${DECLARATIONS}
static void load_procs(GL3WGetProcAddressProc proc)
{
${LOADS}}
