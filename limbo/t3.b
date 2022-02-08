implement Command;
include "cmd.m";

main(nil: list of string)
{
	print("init\n");
	t9();
}

Vector: adt{
	a: array of real;
	zeros: fn(n: int): Vector;
	ones: fn(n: int): Vector;
	mk: fn(a: array of real): Vector;
	dot: fn(v: self  Vector, w:  Vector): real;
	print: fn(v: self Vector);
};

Matrix: adt{
	m, L, n: int;
	a: array of real;

	add: fn(a: self Matrix, b: Matrix): Matrix;
	multiply: fn(a: self Matrix, b: Matrix): Matrix;
	gemm: fn(a: self Matrix, b, c: Matrix, alpha, beta: real, transa, transb: int): Matrix;
	print: fn(a: self Matrix);
};


Vector.zeros(n: int): Vector
{
	a := array[n] of { * => 0.0};
	v := Vector(a);
	return v;
}

Vector.ones(n: int): Vector
{
	a := array[n] of { * => 1.0};
	v := Vector(a);
	return v;
}

Vector.mk(a: array of real): Vector
{
	v := Vector(a);
	return v;
}


Vector.dot(v: self  Vector, w:  Vector): real
{
	return dot(v.a, w.a);
}

Vector.print(v: self Vector)
{
	print("%d\n [", len v.a);
	for (i :=0; i < len v.a; i++) {
		print("%f, ", v.a[i]);
	}
	print("]\n");
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

t1()
{
	v := Vector.zeros(3);
	v.a[1] = 2.0;
	v.print();
	w := Vector.ones(3);
	s := v.dot(w);
	print("%f\n", s);
}

t2()
{
	a := array[9] of { * => 0.0};
	b := array[3] of { * => 0.0};

	matgen(a, 3, 3, b);
	printmat("a", a, 3, 3, 3);
	printmat("b", b, 1, 3, 1);
	printmat("b", b, 1, 1, 3);
}

# Constant times a vector plus a vector.
# beta = 1
daxpy(da:real, dx:array of real, dy:array of real)
{
	n := len dx;
	gemm('N','N',n,1,n,da,nil,0,dx,n,1.,dy,n);
}

# Scales a vector by a constant.
# X = n x 1
# X = a X
dscal(da:real, dx:array of real)
{
	n := len dx;
	gemm('N','N',n,1,n,0.,nil,0,nil,0,da,dx,n);
}

# scale a vector
t3()
{
	a:= array[] of {1.0, 2.0, 3.0};

	dscal(2.0, a);
	printmat("a", a, 3, 3, 1);
}

# 2a + b;  assumed to be vectos
t4()
{
	a:= array[] of {1.0, 2.0, 3.0};
	b:= array[] of {1.0, 1.0, 1.0};
	daxpy(2.0, a, b);
	printmat("a", a, 3, 3, 1);
	printmat("b", b, 3, 3, 1);
}

# C = alpha * A * B  + beta * C
t5()
{
	w := array[] of {
		1.0, 2.0, 3.0, 
		4.0, 5.0, 6.0, 
		7.0, 8.0, 9.0};
	x := array[] of {2.0, 2.0, 2.0};
	c := array[3] of {* => 0.0};

	lda, ldb, ldc :int = 3;
	m := 3;   # A is m x k,  B is k x n, c is m x n.
	n := 1;
	k := 3;
	alpha := 1.0;
	beta := 1.0;

	gemm('N', 'N', m, n, k, alpha, w, lda, x, ldb, beta, c, ldc);
	printmat("c", c, ldc, 3, 1);
}

# b = a + b
Matrix.add(a: self Matrix, b: Matrix): Matrix
{
	gemm('N','N',a.m,a.m,a.n,1., nil, 0, a.a, a.L,1., b.a, b.L);
	return b;
}

# c = AB
Matrix.multiply(A: self Matrix, B: Matrix): Matrix
{
	C := Matrix(A.m, A.m, B.n, array[A.m*B.n] of {* => 0.0});

	gemm('N', 'N', A.m, B.n, A.n, 1., A.a, A.L, B.a, B.L, 1., C.a, C.L);
	return C;
}

Matrix.gemm(a: self Matrix, b, c: Matrix, alpha, beta: real, transa, transb: int): Matrix
{
	gemm(transa, transb, a.m, b.n, a.n, alpha, a.a, a.L, b.a, b.L, beta, c.a, c.L);
	return c;
}


Matrix.print(a: self Matrix)
{
	printmat("a", a.a, a.L, a.m, a.n);
}

# add matrix a + b
t6()
{
	w := array[] of { 
		1.0, 4.0, 7.0, 
		2.0, 5.0, 8.0, 
		3.0, 6.0, 9.0};	
	a := Matrix(3, 3, 3, w[:]);
	b := Matrix(3, 3, 3, w[:]);

	printmat("w", w, 3, 3, 3);
	a.add(b);
	printmat("b", b.a, b.L, b.m, b.n);

}

# C = AB
t7()
{
	a := array[3] of {1.0, 2.0, 3.0};
	A := Matrix(3, 3, 1, a[:]);
	B := Matrix(1, 1, 3, a[:]);
	C := Matrix(3, 3, 3, array[9] of {* => 0.0});

	# gemm('N', 'N', A.m, B.n, A.n, 1., A.a, A.L, B.a, B.L, 1., C.a, C.L);
	C = A.multiply(B);


	printmat("C", C.a, C.L, C.m, C.n);
}


# dot product using gemm
t8()
{
	a := Matrix(1, 1, 3, array[] of {1.0, 2.0, 3.0});
	b := Matrix(3, 3, 1, array[] of {4.0, 5., 6.});

	c := a.multiply(b);
	c.print();
}

# y = Wx + b
t9()
{
	w := Matrix(3, 3, 3, array[9] of {* => 1.0});
	x := Matrix(3, 3, 1, array[3] of {1., 2., 3.});
	b := Matrix(3, 3, 1, array[3] of {* => 0.0});

	#c := w.multiply(x);
	#c.add(b);
	c := w.gemm(x, b, 1. , 1.,  'N', 'N');
	c.print();
	w.print();
	x.print();
}
