struct A { 
    virtual void foo(int N) = 0; 
};

struct B : public A { 
    void foo(int N) override; 
};

struct C : public A { 
    void foo(int N) override; 
};

struct D : public A { 
    void foo(int N) override; 
};

void B::foo(int N) {}
void C::foo(int N) {}
void D::foo(int N) {}
