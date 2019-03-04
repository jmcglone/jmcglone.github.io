#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
#define LENGTH 170000
    int NUM = ((argc == 2) ? atoi(argv[1]) : LENGTH);
    static char flags[8192 + 1];
    long i, k;
    long sqrt_max = sqrt(8192);
    int count;

    while (NUM--) {
        for (i=3; i < 8192; i+=2) {
            flags[i] = 1;   // odd numbers might be prime
        }

        // start from i=3 and iterate over odd numbers
	for (i=3; i <= sqrt_max; i+=2) { 
	    if (flags[i]) {
                /* remove all multiples of prime: i */
		// 1. less than i*i already marked
		// 2. only mark odd multiples (i*i+i will
		//    produce even number, which is already marked)
		for (k=i*i; k <= 8192; k+=2*i) {
		    flags[k] = 0;
		}
	    }
	}
	count = 1; // accounting for 2 is prime
        for (long i = 3; i <= 8192; i+=2) { // skip evens again
          if (flags[i]) {
            count++;
          }
        }
    }

    printf("Count: %d\n", count);
    return(0);
}
