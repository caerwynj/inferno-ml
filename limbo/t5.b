implement Command;
include "cmd.m";

xdarray: adt {
	m, L, n: int;
	a: array of real;

	sum: fn(nd: self xdarray): xdarray;
	mean: fn(nd: self xdarray): xdarray;
	std: fn(nd: self xdarray): xdarray;
	print: fn(nd: self xdarray, name: string);
	apply: fn(nd: self xdarray, val: real, f: ufunc): xdarray;
	broadcast: fn(nd: self xdarray, val: xdarray, f: ufunc): xdarray;
	dot: fn(nd: self xdarray, x: xdarray): xdarray;
	col: fn(nd: self xdarray, start, end: int): xdarray;

# flatten, transpose, item, reshape, argmax
# max, min, var, all, any, lt, le, gt, ge, eq, ne
# inplace apply
# inplace broadcast  
# reduce
};

ufunc: type ref fn(x, y: real): real;

main(argv: list of string)
{
	print("%s\n", hd argv);
	argv = tl argv;
	if(argv == nil){
		print("no arg");
		exit;
	}

	print("%s\n", hd argv);
	(m, lda, n, a) := read_csv(hd argv);
	nd := xdarray(m, lda, n, a);

	#printmat("a", a, lda, 30, n);

	sums := nd.sum();
	means := nd.mean();
	stds := nd.std();
	sums.print("sum");
	means.print("mean");
	stds.print("std");
	
	z := stds.apply(2., minus).apply(.0, relu);
	z.print("z");
	znorm := nd.broadcast(means, minus).broadcast(stds, div);

	#xdarray(nd.m, nd.L, 1, nd.a[3*nd.L:4*nd.L]).print("slice");

	x := znorm.col(0,3);
	targ := nd.col(3,4);
	x.print("X");
	targ.print("targ");

	w := randn(3, 3);
	w.print("w");

}

xdarray.col(nd: self xdarray, start, end: int): xdarray
{
	return xdarray(nd.m, nd.L, end - start, nd.a[start*nd.L:end*nd.L]);
}

randn(m, n: int): xdarray
{
	r := array[m * n] of real;
	bigg: int = (1<<30);
	for (i := 0; i < len r; i++) {
		r[i] = real rand(bigg) / real bigg;
	}
	return xdarray(m, m, n, r);
}

# prep data
# forward 
# backward
# update

relu(x, y: real): real
{
	if(x > y)
		return x;
	else return y;
}

add(x, y: real): real
{
	return x + y;
}

minus(x, y: real): real
{
	return x - y;
}

div(x, y: real): real
{
	return x / y;
}

xdarray.dot(nd: self xdarray, x: xdarray): xdarray
{
	ar := array[nd.m * x.n] of {* => .0};

	gemm('N', 'N', nd.m, x.n, nd.n, 1., nd.a, nd.L, x.a, x.L, 1., ar, nd.L);
	return xdarray(nd.m, nd.L, x.n, ar);;
}

xdarray.broadcast(nd: self xdarray, val: xdarray, f: ufunc): xdarray
{
	if(val.m != nd.n) {
		print("invalid broadcast\n");
		return nd;
	}
	ar := array[nd.m*nd.n] of {* => .0};

	for(i := 0; i < nd.m; i++) {
		for(j := 0; j < nd.n; j++) {
			ar[i+nd.L*j] = f(nd.a[i+nd.L*j], val.a[j]);
		}
	}
	return xdarray(nd.m, nd.L, nd.n, ar);
}

xdarray.apply(nd: self xdarray, val: real, f: ufunc): xdarray
{
	ar := array[nd.m*nd.n] of {* => .0};

	for(i := 0; i < nd.m; i++)
		for(j := 0; j < nd.n; j++)
			ar[i+nd.L*j] = f(nd.a[i+nd.L*j], val);
	return xdarray(nd.m, nd.L, nd.n, ar);
}

xdarray.print(nd: self xdarray, name: string)
{
	m := nd.m;
	if(m > 30)
		m = 30;
	printmat(name, nd.a, nd.L, m, nd.n);
}

xdarray.sum(nd: self xdarray): xdarray
{
	sums := array[nd.n] of { * => 0.0};

	for(i := 0; i < nd.m; i++){
		for(j := 0; j < nd.n; j++) {
			sums[j] += nd.a[i+nd.L*j];
		}
	}
	return xdarray(nd.n, nd.n, 1, sums);
}

xdarray.mean(nd: self xdarray): xdarray
{
	means := nd.sum();
	for (i := 0; i < len means.a; i++)
		means.a[i] = means.a[i] / real nd.m;
	return means;
}

xdarray.std(nd: self xdarray): xdarray
{
	means := nd.mean();
	stds := array[nd.n] of {* => 0.0};

	for(i := 0; i < nd.m; i++) {
		for(j := 0; j < nd.n; j++) {
			stds[j] += (nd.a[i+nd.L*j] - means.a[j]) ** 2;
		}
	}
	for(i = 0; i < nd.n; i++) {
		stds[i] = sqrt(stds[i] / real nd.m);
	}
	return xdarray(nd.n, nd.n, 1, stds);
}


read_csv(name: string): (int, int, int, array of real)
{
	fd := bufio->open(name, bufio->OREAD);
	header := csv->getline(fd);
	s : list of string = nil;
	lines : list of list of string;
	while((s = csv->getline(fd)) != nil){
		lines = s :: lines;
	}

	m, n : int = 0;
	m = len lines;
	n = len header;
	lda := m;
	v := array[m * n] of {* => 0.0};

	print("m %d n %d\n", m, n);
	for (i := 0; i < m; i++) {
		row := hd lines;
		for (j := 0; j < n; j++) {
			rr: real;
			w: string;
			(rr, w) = toreal(hd row, 10);
			v[i+lda*j] = rr;
			row = tl row;
		}
		lines = tl lines;
	}
	for (h := header; h != nil; h = tl h)
		print("%s ", hd h);
	print("\n");

	#printmat("a", v, lda, 30, n);

	return (m, lda, n, v);
}
