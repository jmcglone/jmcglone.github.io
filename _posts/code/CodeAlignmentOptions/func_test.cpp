void __attribute__((noinline)) func(int* a);

void dummy(int* a)
{
    for (int i = 0; i < 32; ++i)
	a[i] += 1;
    if (a[0] == 1)
        a[1] = 0;
    func(a);
}

void __attribute__((noinline)) func(int* a)
{
    for (int i = 0; i < 32; ++i)
	a[i] += 1;
    if (a[0] == 1)
        a[1] = 0;
}
