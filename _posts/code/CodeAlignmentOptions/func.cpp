void dummy(int* a)
{
    for (int i = 0; i < 32; ++i)
	a[i] += 1;
    if (a[0] == 1)
        a[1] = 0;
}

int foo();
int bar();

void func(int* a)
{
    for (int i = 0; i < 32; ++i)
	a[i] += 1;
    if (a[0] == 1)
        a[0] += foo();
    else
        a[0] += bar();
}
