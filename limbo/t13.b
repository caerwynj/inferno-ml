implement Command;
include "cmd.m";

# Logistic regression with multiple features
main(argv: list of string)
{
	argv = tl argv;
	if(argv == nil)
		raise "no arg";

	print("%s\n", hd argv);
	(m, lda, n, a) := np->read_csv(hd argv);
	nd := ndarray(m, lda, n, a);

	x := nd.col(0, 2);
	y := nd.col(2, 3);

	b := np->ones(x.m, 1);
	x= np->concatenate(b :: x :: nil);
	x.print("x");

	theta := np->zeros(x.n, 1);
	z := sigmoid(x.dot(theta));
	z.print("z");

	j_hist: ndarray;

}

sigmoid(x: ndarray): ndarray
{
# g = 1 ./ (1 + exp(-z));	
#	a := array[x.m*x.n] of {* => 0.0};
#	for (i := 0; i < x.m; i++)
#		for(j := 0; j < x.n; j++) 
#			a[i+x.L*j] = 1. / (1. + exp(-x.a[i+x.L*j]));
	return x.apply(0., np->sigmoid);
}

cost(x, y, theta: ndarray): ndarray
{
# z = sigmoid(X * theta);
# J = sum(-y' * log(z) - (1 - y)' * log(1 - z)) * 1 / length(X);

	return ndarray(0,0,0,nil);
}

gradient_descent(x, y, theta: ndarray, alpha: real, niter: int): (ndarray, ndarray)
{
	return (ndarray(0,0,0,nil), ndarray(0,0,0,nil));
}
