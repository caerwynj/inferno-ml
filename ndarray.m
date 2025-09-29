Ndarray: module {
	PATH: con "ndarray.dis";
	ndarray: adt {
		m, L, n: int;
		a: array of real;
	
		sum: fn(nd: self ndarray): ndarray;
		mean: fn(nd: self ndarray): ndarray;
		std: fn(nd: self ndarray): ndarray;
		print: fn(nd: self ndarray, name: string);
		apply: fn(nd: self ndarray, val: real, f: bfunc): ndarray;
		apply1: fn(nd: self ndarray, f: ufunc): ndarray;
		broadcast: fn(nd: self ndarray, val: ndarray, f: bfunc): ndarray;
		dot: fn(nd: self ndarray, x: ndarray): ndarray;
		col: fn(nd: self ndarray, start, end: int): ndarray;
		row: fn(nd: self ndarray, start, end: int): ndarray;
		subtract: fn(nd: self ndarray, val: ndarray): ndarray;
		divide: fn(nd: self ndarray, val: ndarray): ndarray;
		transpose: fn(nd: self ndarray): ndarray;
		scale: fn(nd: self ndarray, alpha: real): ndarray;
		copy: fn(nd: self ndarray): ndarray;

	# flatten, transpose, item, reshape, argmax
	# max, min, var, all, any, lt, le, gt, ge, eq, ne
	# inplace apply
	# inplace broadcast  
	# reduce
	};
	
	ufunc: type ref fn(x: real): real;
	bfunc: type ref fn(x, y: real): real;

	relu: fn(x, y:real):real;
	add: fn(x, y: real):real;
	minus: fn(x, y:real):real;
	div: fn(x, y: real):real;
	mul: fn(x, y: real): real;
	sigmoid: fn(x: real): real;

	read_csv: fn(name: string): (int, int, int, array of real);
	to_csv: fn(filename: string, nd: ndarray);
	from_list: fn(a: list of real): ndarray;
	randn: fn(m, n: int): ndarray;
	zeros: fn(m, n: int): ndarray;
	ones: fn(m, n: int): ndarray;
	concatenate: fn(alist: list of ndarray): ndarray;
	range: fn(start, end: int): ndarray;
	const: fn(alpha: real): ndarray;

	init:fn(); 

};
