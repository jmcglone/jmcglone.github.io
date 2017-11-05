
void add_arrays_scalar(unsigned char* a, unsigned char* b, unsigned n)
{
  unsigned stride = 32 / n;
  for (unsigned k = 0; k < stride; ++k)  
  {
    for (unsigned i = 0; i < n; ++i)  
      a[i] += b[i];
    a += stride;
    b += stride;
  }
}

void add_arrays_vectorization_width_4(unsigned char* a, unsigned char* b, unsigned n)
{
  unsigned stride = 32 / n;
  for (unsigned k = 0; k < stride; ++k)  
  {
    #pragma clang loop vectorize(enable) vectorize_width(4) interleave(disable) unroll(disable)
    for (unsigned i = 0; i < n; ++i) 
      a[i] += b[i];
    a += stride;
    b += stride;
  }
}

void add_arrays_vectorization_width_8(unsigned char* a, unsigned char* b, unsigned n)
{
  unsigned stride = 32 / n;
  for (unsigned k = 0; k < stride; ++k)  
  {
    #pragma clang loop vectorize(enable) vectorize_width(8) interleave(disable) unroll(disable)
    for (unsigned i = 0; i < n; ++i) 
      a[i] += b[i];
    a += stride;
    b += stride;
  }
}

void add_arrays_vectorization_width_16(unsigned char* a, unsigned char* b, unsigned n)
{
  unsigned stride = 32 / n;
  for (unsigned k = 0; k < stride; ++k)  
  {
    #pragma clang loop vectorize(enable) vectorize_width(16) interleave(disable) unroll(disable)
    for (unsigned i = 0; i < n; ++i) 
      a[i] += b[i];
    a += stride;
    b += stride;
  }
}

void add_arrays_multiver_by_trip_counts(unsigned char* a, unsigned char* b, unsigned n)
{
  unsigned stride = 32 / n;
  for (unsigned k = 0; k < stride; ++k)  
  {
	  if (n == 4)
	  {
	    #pragma clang loop vectorize(enable) vectorize_width(4) interleave(disable) unroll(disable)
	    for (unsigned i = 0; i < 4; ++i) 
	      a[i] += b[i];
	  }
	  else if (n == 8)
	  {
	    #pragma clang loop vectorize(enable) vectorize_width(8) interleave(disable) unroll(disable)
	    for (unsigned i = 0; i < 8; ++i) 
	      a[i] += b[i];
	  }
	  else if (n == 16)
	  {
	    #pragma clang loop vectorize(enable) vectorize_width(16) interleave(disable) unroll(disable)
	    for (unsigned i = 0; i < 16; ++i) 
	      a[i] += b[i];
	  }
	  else
	  {
	    for (unsigned i = 0; i < n; ++i)  
	      a[i] += b[i];
	  }
    a += stride;
    b += stride;
  }
}
