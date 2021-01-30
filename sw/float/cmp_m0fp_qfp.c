// SPDX-License-Identifier: ISC

#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include "qfplib-m0-full.h"

extern float  m0_f32add         (float x,float y);
extern float  m0_f32sub         (float x,float y);
extern float  m0_f32mul         (float x,float y);
extern float  m0_f32div         (float x,float y);

extern float  m0_f32sin         (float x);
extern float  m0_f32cos         (float x);
extern float  m0_f32tan         (float x);
extern float  m0_f32atan2       (float y, float x);



typedef union {
    float f;
    uint32_t u;
} uf32_t;

float f32_rand()
{
    uf32_t x;
    do {
        x.u = rand();
    } while (0);//(!isnormal(x.f));
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
/*
        compare("f32_add", iteration, qfp_fadd(a, b), m0_f32add(a, b));
        compare("f32_mul", iteration, qfp_fmul(a, b), m0_f32mul(a, b));
        compare("f32_div", iteration, qfp_fdiv(a, b), m0_f32div(a, b));
*/
        compare("f32_sin", iteration, qfp_fsin(a), m0_f32sin(a));
        compare("f32_cos", iteration, qfp_fcos(a), m0_f32cos(a));
        compare("f32_tan", iteration, qfp_ftan(a), m0_f32tan(a));
        compare("f32_atan2", iteration, qfp_fatan2(a, b), m0_f32atan2(a, b));
    }
    printf("\nfaults: %lu of %lu\n", faults, total);
    return 0;
}

