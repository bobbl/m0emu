// SPDX-License-Identifier: ISC

#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include "qfplib-m0-full.h"


typedef union {
    float f;
    uint32_t u;
} uf32_t;

float f32_rand()
{
    uf32_t x;
    do {
        x.u = rand();
    } while (!isnormal(x.f));
    return x.f;
}


void print_float_hex(float f)
{
    uf32_t x;
    x.f = f;
    printf("%c1.%06Xp%+i",
        (x.u & 0x80000000) ? '-' : '+',
        (x.u<<1) & 0xFFFFFF,
        ((x.u>>23) & 0xFF) - 127);
}



unsigned long faults=0;


void compare(const char *name, unsigned long i, float ef, float tf)
{
    uf32_t e, t;
    e.f = ef;
    t.f = tf;
    if (isnormal(ef) && e.u != t.u) {
        faults++;
        printf("\n%lu: %s ", i, name);
        print_float_hex(t.f);
        printf(" expected: ");
        print_float_hex(e.f);
    }
}


int main(int argc,char *argv[])
{
    float a, b;
    uf32_t e, t;
    unsigned long total = 100000;

    srand(1);

    unsigned long iteration;
    for (iteration=0; iteration<total; iteration++) {
        a = f32_rand();
        b = f32_rand();
        compare("f32_add", iteration, a+b, qfp_fadd(a, b));
        compare("f32_mul", iteration, a*b, qfp_fmul(a, b));
        compare("f32_div", iteration, a/b, qfp_fdiv(a, b));
    }
    printf("\nfaults: %lu of %lu\n", faults, total);
    return 0;
}

