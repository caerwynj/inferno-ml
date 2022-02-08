Ndarray: module {
	PATH: con "ndarray.dis";
	ndarray: adt {
		m, L, n: int;
		a: array of real;
	
		sum: fn(nd: self ndarray): ndarray;
		mean: fn(nd: self ndarray): ndarray;
		std: fn(nd: self ndarray): ndarray;
		print: fn(nd: self ndarray, name: string);
		apply: fn(nd: self ndarray, val: real, f: ufunc): ndarray;
		broadcast: fn(nd: self ndarray, val: ndarray, f: ufunc): ndarray;
		dot: fn(nd: self ndarray, x: ndarray): ndarray;
	
	# flatten, transpose, item, reshape, argmax
	# max, min, var, all, any, lt, le, gt, ge, eq, ne
	# inplace apply
	# inplace broadcast  
	# reduce
	};
	
	ufunc: type ref fn(x, y: real): real;

};
