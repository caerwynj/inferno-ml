implement Ndarray;
include "ndarray.m";

include "sys.m";
sys: Sys;
print, sprint: import sys;

include "math.m";
math: Math;
ceil, fabs, floor, Infinity, log10, pow10, pow, sqrt, exp: import math;
dot, gemm, iamax: import math;

include "linalg.m";
linalg: LinAlg;
printmat, dgefa, dgesl: import linalg;

include "string.m";
str: String;
tobig, toint, toreal, tolower, toupper: import str;

include "bufio.m";
bufio: Bufio;
Iobuf: import bufio;

include "csv.m";
csv: CSV;

include "rand.m";
randmod: Rand;
rand: import randmod;

init()
{
	sys = load Sys Sys->PATH;
	math = load Math Math->PATH;
	linalg = load LinAlg LinAlg->PATH;
	str = load String String->PATH;
	bufio = load Bufio Bufio->PATH;
	csv = load CSV CSV->PATH;
	randmod = load Rand Rand->PATH;
	randmod->init(1337);
	csv->init(bufio);
}

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

mul(x, y: real): real
{
	return x * y;
}

sigmoid(x: real): real
{
	return 1. / (1. + exp(-x));
}

const(alpha: real): ndarray
{
	return ndarray(1, 1, 1, array[1] of {alpha});
}

ndarray.scale(nd: self ndarray, alpha: real): ndarray
{
	n := nd.m * nd.n;
	gemm('N','N',n,1,n,0.,nil,0,nil,0,alpha,nd.a,n);
	return nd;
}

ndarray.copy(nd: self ndarray): ndarray
{
	ar := array[nd.m * nd.n] of real;
	ar[0:] = nd.a;
	return ndarray(nd.m, nd.L, nd.n, ar);
}

ndarray.col(nd: self ndarray, start, end: int): ndarray
{
	return ndarray(nd.m, nd.L, end - start, nd.a[start*nd.L:end*nd.L]);
}

ndarray.row(nd: self ndarray, start, end: int): ndarray
{
	return ndarray(end - start, nd.L, nd.n, nd.a[start:]);
}

ndarray.transpose(nd: self ndarray): ndarray
{
	ar := array[nd.m * nd.n] of real;

	lda := nd.n;
	for(i := 0; i< nd.m; i++)
		for(j := 0; j < nd.n; j++)
			ar[j+lda*i] = nd.a[i+nd.L*j];
	return ndarray(nd.n, lda, nd.m, ar);
}

from_list(a: list of real): ndarray
{
	ar := array[len a] of real;

	for(i := 0; a != nil; a = tl a){
		ar[i++] = hd a;
	}

	return ndarray(len ar, len ar, 1, ar);
}

randn(m, n: int): ndarray
{
	r := array[m * n] of real;
	bigg: int = (1<<30);
	for (i := 0; i < len r; i++) {
		r[i] = real rand(bigg) / real bigg;
	}
	return ndarray(m, m, n, r);
}

zeros(m, n: int): ndarray
{
	r := array[m*n] of {* => 0.0};
	return ndarray(m, m, n, r);
}

ones(m, n: int): ndarray
{
	r := array[m*n] of {* => 1.0};
	return ndarray(m, m, n, r);
}

# concatenate column vectors from left to right
concatenate(alist: list of ndarray): ndarray
{
	m := (hd alist).m;

	total_cols := 0;
	for (l := alist; l != nil; l = tl l){
		total_cols += (hd l).n;
	}

	ar := array[m * total_cols] of real;
	c := 0;
	for (l = alist; l != nil; l = tl l) {
		ar[c:] = (hd l).a;
		c += len (hd l).a;
	}
	return ndarray(m, m, total_cols, ar);

}

ndarray.dot(nd: self ndarray, x: ndarray): ndarray
{
	ar := array[nd.m * x.n] of {* => .0};

	gemm('N', 'N', nd.m, x.n, nd.n, 1., nd.a, nd.L, x.a, x.L, 1., ar, nd.L);
	return ndarray(nd.m, nd.L, x.n, ar);;
}

ndarray.subtract(nd: self ndarray, val: ndarray): ndarray
{
	return nd.broadcast(val, minus);
}

ndarray.divide(nd: self ndarray, val: ndarray): ndarray
{
	return nd.broadcast(val, div);
}

# valid broadcasts
# (m, n) == (m, n)   shape match
# (m, n) == (1,n)  
# (m, n) == (1,1)
# (b,m,n) == (b,m,n)
# (b,m,n) == (1,m,n)
# (b,m,n) == (1,1,n)
# (b,m,n) == (1,1,1)

ndarray.broadcast(nd: self ndarray, val: ndarray, f: bfunc): ndarray
{
	ar := array[nd.m * nd.n] of {* => .0};
	if(nd.m == val.m && nd.n == val.n) {  # arrays are same shape
		for(i := 0; i < nd.m; i++) {
			for(j := 0; j < nd.n; j++) {
				ar[i+nd.L*j] = f(nd.a[i+nd.L*j], val.a[i+nd.L*j]);
			}
		}
	}else if(nd.n == val.n && val.m == 1) { # broadcast val
		for(i := 0; i < nd.m; i++) {
			for(j := 0; j < nd.n; j++) {
				ar[i+nd.L*j] = f(nd.a[i+nd.L*j], val.a[j]);
			}
		}
	}else if(val.n == 1 && val.m == 1) { # broadcast val
		for(i := 0; i < nd.m; i++) {
			for(j := 0; j < nd.n; j++) {
				ar[i+nd.L*j] = f(nd.a[i+nd.L*j], val.a[0]);
			}
		}
	} else if(nd.n == 1 && nd.m == 1) { # broadcast nd
		ar = array[val.m * val.n] of {* => .0};
		for(i := 0; i < val.m; i++)
			for(j := 0; j < val.n; j++)
				ar[i+val.L*j] = f(nd.a[0], val.a[i+val.L*j]);
		return ndarray(val.m, val.L, val.n, ar);
	}else{
		print("(%d,%d), (%d, %d)\n", nd.m, nd.n, val.m, val.n);
		raise "shape mismatch";
	}

	return ndarray(nd.m, nd.L, nd.n, ar);
}

ndarray.apply(nd: self ndarray, val: real, f: bfunc): ndarray
{
	ar := array[nd.m*nd.n] of {* => .0};

	for(i := 0; i < nd.m; i++)
		for(j := 0; j < nd.n; j++)
			ar[i+nd.L*j] = f(nd.a[i+nd.L*j], val);
	return ndarray(nd.m, nd.L, nd.n, ar);
}

ndarray.apply1(nd: self ndarray, f: ufunc): ndarray
{
	ar := array[nd.m*nd.n] of {* => .0};

	for(i := 0; i < nd.m; i++)
		for(j := 0; j < nd.n; j++)
			ar[i+nd.L*j] = f(nd.a[i+nd.L*j]);
	return ndarray(nd.m, nd.L, nd.n, ar);
}

ndarray.print(nd: self ndarray, name: string)
{
	m := nd.m;
	n := nd.n;
	if(m > 30)
		m = 30;
	if(n > 10)
		n = 10;
	printmat(name, nd.a, nd.L, m, n);
}

ndarray.sum(nd: self ndarray): ndarray
{
	sums := array[nd.n] of { * => 0.0};

	for(i := 0; i < nd.m; i++){
		for(j := 0; j < nd.n; j++) {
			sums[j] += nd.a[i+nd.L*j];
		}
	}
	return ndarray(1, 1, nd.n, sums);
}

ndarray.mean(nd: self ndarray): ndarray
{
	means := nd.sum();
	for (i := 0; i < len means.a; i++)
		means.a[i] = means.a[i] / real nd.m;
	return means;
}

ndarray.std(nd: self ndarray): ndarray
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
	return ndarray(1, 1, nd.n, stds);
}

read_csv(name: string): (int, int, int, array of real)
{
	fd := bufio->open(name, bufio->OREAD);
	#header := csv->getline(fd);
	s : list of string = nil;
	lines : list of list of string;
	while((s = csv->getline(fd)) != nil){
		lines = s :: lines;
	}

	print("all lines read\n");
	m, n : int = 0;
	m = len lines;
	n = len hd lines;
	lda := m;
	v := array[m * n] of {* => 0.0};

	print("m %d n %d\n", m, n);
	for (i := m-1; i >= 0; i--) {
		row := hd lines;
		for (j := 0; j < n; j++) {
			rr: real;
			w: string;
			(rr, w) = toreal(hd row, 10);
			v[i+lda*j] = rr;
			#print("%d, %g\n", i, rr);
			row = tl row;
		}
		lines = tl lines;
	}
#	for (h := header; h != nil; h = tl h)
#		print("%s ", hd h);
#	print("\n");

	#printmat("a", v, lda, 30, n);

	return (m, lda, n, v);
}

to_csv(filename: string, nd: ndarray)
{
	fd := bufio->create(filename, bufio->OWRITE, 8r660);
	
	for(i := 0; i < nd.m; i++) {
		fd.puts(sprint("%.3e", nd.a[i]));
		for(j := 1; j < nd.n; j++)
			fd.puts(sprint(",%.3e", nd.a[i+nd.L*j]));
		fd.puts("\n");

	}
	fd.flush();
	fd.close();
}

range(start, end: int): ndarray
{
	a := array[end - start] of real;

	for(i:=0; i< len a; i++)
		a[i] = real (i+start);

	return ndarray(len a, len a, 1, a);
}

