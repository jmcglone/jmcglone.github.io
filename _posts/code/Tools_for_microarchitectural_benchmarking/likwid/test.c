#include <stdlib.h>
#include <stdio.h>
// This block enables compilation of the code with and without LIKWID in place
#ifdef LIKWID_PERFMON
#include <likwid.h>
#else
#define LIKWID_MARKER_INIT
#define LIKWID_MARKER_THREADINIT
#define LIKWID_MARKER_SWITCH
#define LIKWID_MARKER_REGISTER(regionTag)
#define LIKWID_MARKER_START(regionTag)
#define LIKWID_MARKER_STOP(regionTag)
#define LIKWID_MARKER_CLOSE
#define LIKWID_MARKER_GET(regionTag, nevents, events, time, count)
#endif

#define N 10000

void benchmark(int iters, void* ptr);

int main(int argc, char* argv[])
{
    int data[N];
    LIKWID_MARKER_INIT;
    LIKWID_MARKER_THREADINIT;
    LIKWID_MARKER_START("foo");
    benchmark(N, data);
    LIKWID_MARKER_STOP("foo");
    LIKWID_MARKER_CLOSE;
    return 0;
}
