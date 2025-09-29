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
	#x.print("x");

	theta := np->zeros(x.n, 1);

	j_hist: ndarray;

	(J, grad) := cost(x, y, theta);
	J.print("J");
	theta.print("theta");
	grad.print("grad");

	theta = np->from_list(-24. :: 0.2 :: 0.2 :: nil);
	theta.print("theta");
	(J, grad) = cost(x, y, theta);
	J.print("J");
	grad.print("grad");

	theta = np->from_list(.00299970729487982 :: .36026434536565227 :: .33787159497914404 :: nil);
	theta.print("theta");
	(J, grad) = cost(x, y, theta);
	J.print("J");
	grad.print("grad");

	return;
	theta = np->zeros(x.n, 1);
	(theta, j_hist) = gradient_descent(x, y, theta, 0.01, 400);
	np->to_csv("j_hist.csv", j_hist);
	theta.print("theta");

	(J, grad) = cost(x, y, theta);
	J.print("J");

}

log(x: ndarray): ndarray
{
	return x.apply1(math->log);
}

sigmoid(x: ndarray): ndarray
{
	return x.apply1(np->sigmoid);
}

cost(x, y, theta: ndarray): (ndarray, ndarray)
{
# z = sigmoid(X * theta);
# J = sum(-y' * log(z) - (1 - y)' * log(1 - z)) * 1 / length(X);
# grad(j) = sum(X(:, j)' * (z - y)) / lengh(x)

	z := sigmoid(x.dot(theta));
	z.print("z");
	z1 := y.transpose().dot(log(z)).scale(-1.0);
	z1.print("z1");
	one := np->const(1.0);
	z2 := one.subtract(y).transpose().dot(log(one.subtract(z)));
	z3 := z1.subtract(z2).scale(1./ real x.m);	
	z2.print("z2");
	z3.print("z3");

	t := array[theta.m] of {* => .0};
	for (j := 0; j < theta.m; j++) {
		t[j] = x.col(j, j+1).transpose().dot(z.subtract(y)).sum().scale(1. / real x.m).a[0];
	}
	return (z3, ndarray(theta.m, theta.m, 1, t));
}

gradient_descent(x, y, theta: ndarray, alpha: real, niter: int): (ndarray, ndarray)
{
	j_hist := ndarray(niter, niter, 1, array[niter] of real);

	for(i := 0; i < niter; i++){
		J, grad: ndarray;
		(J, grad) = cost(x, y, theta);
		for (j := 0; j < theta.m; j++) {
			theta.a[j] -= grad.a[j] * alpha;
		}
		j_hist.a[i] = J.a[0];
	}
	return (theta, j_hist);
}