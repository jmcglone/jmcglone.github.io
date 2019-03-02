#include <stdio.h>
#include <stdlib.h>

constexpr int calc()
{
	char flags[8192 + 1] = { 0 };
	int count = 0;
	for(long i = 2; i <= 8192; i++)
		flags[i] = 1;
	for(long i = 2; i <= 8192; i++)
	{
		if(flags[i])
		{
			for(long k = i + i; k <= 8192; k += i)
				flags[k] = 0;
			count++;
		}
	}

	return count;
}

int main(int argc, char *argv[])
{
#define LENGTH 170000
	int NUM = ((argc == 2) ? atoi(argv[1]) : LENGTH);

	int count = 0;
	while(NUM--)
	{
		enum { _count = calc() };
		count = _count;
	}
	printf("Count: %d\n", count);
	return(0);
}
