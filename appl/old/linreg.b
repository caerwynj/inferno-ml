implement LinReg;

include "sys.m";
sys: Sys;
include "draw.m";
draw: Draw;
include "math.m";
math: Math;
ceil, fabs, floor, Infinity, log10, pow10, sqrt: import math;
dot, gemm, iamax: import math;

include "linalg.m";
linalg: LinAlg;
printmat, dgefa, dgesl: import linalg;


Vector: adt{
	a: array of real;
	make: fn(v: array of real): Vector;
	dot: fn(v: self  Vector, w:  Vector): real;
	print: fn(v: self Vector);
};

Matrix: adt{
	m, L, n: int;
	a: Vector;
};


Vector.make(a: array of real): Vector
{
	v := Vector(a);
	return v;
}

Vector.dot(v: self  Vector, w:  Vector): real
{
	return dot(v.a, w.a);
}


LinReg: module
{
	init: fn(nil: ref Draw->Context, argv: list of string);
};

init(nil: ref Draw->Context, nil: list of string)
{
	sys = load Sys Sys->PATH;
	math = load Math Math->PATH;
	linalg = load LinAlg LinAlg->PATH;

	benchmark(5);
}

benchmark(n: int)
{
	lda := 10;
	a := array [lda*n] of real;
	b := array [n] of real;
	x := array [n] of real;
	ipvt := array [n] of int;

	norma := matgen(a,lda,n,b);
	printmat("a",a,lda,n,n);
	printmat("b",b,lda,n,1);
	dgefa(a,lda,n,ipvt);
	printmat("a",a,lda,n,n);

	v := array[3] of {1.0};
	w := array[3] of {2.0};
	vv := Vector.make(v);
	vv.print();
	ww := Vector.make(w);
	sys->print("%f\n", vv.dot(ww));
}

#  L = f(W x)  where W is weight matrix, x is input vector, and f is relu.

Vector.print(v: self Vector)
{
	for (i := 0; i < len v.a; i++) {
		sys->print("%f ", v.a[i]);
	}
}

# Constant times a vector plus a vector.
daxpy(da:real, dx:array of real, dy:array of real)
{
	n := len dx;
	gemm('N','N',n,1,n,da,nil,0,dx,n,1.,dy,n);
}

# Scales a vector by a constant.
dscal(da:real, dx:array of real)
{
	n := len dx;
	gemm('N','N',n,1,n,0.,nil,0,nil,0,da,dx,n);
}

# generate a (fixed) random matrix and right hand side
# a[i][j] => a[lda*i+j]
matgen(a: array of real, lda, n: int, b: array of real): real
{
	seed := 1325;
	norma := 0.;
	for(j := 0; j < n; j++)
		for(i := 0; i < n; i++){
			seed = 3125*seed % 65536;
			a[lda*j+i] = (real seed - 32768.0)/16384.0;
			if(norma < a[lda*j+i]) norma = a[lda*j+i];
		}
	for (i = 0; i < n; i++)
		b[i] = 0.;
	for (j = 0; j < n; j++)
		for (i = 0; i < n; i++)
			b[i] += a[lda*j+i];
	return norma;
}
