implement Command;
include "cmd.m";

# Linear regression with multiple features
main(argv: list of string)
{
	argv = tl argv;
	if(argv == nil){
		print("no arg");
		exit;
	}

	print("%s\n", hd argv);
	(m, lda, n, a) := np->read_csv(hd argv);
	nd := ndarray(m, lda, n, a);
	nd.print("x");
	
	x := nd.col(0, 2);
	y := nd.col(2, 3);

	x.print("x");
	(mu, sigma, normx) := normalize(x);

	b := np->ones(x.m, 1);
	xx := np->concatenate(b :: normx :: nil);
	xx.print("xx");

	theta := np->zeros(xx.n, 1);
	j_hist: ndarray;

	(theta, j_hist) = gradient_descent(xx, y, theta, 0.01, 400);

	np->to_csv("j_hist.csv", j_hist);
	theta.print("theta");

	sample := np->from_list(1600.0 :: 3.0 :: nil);
	sample.print("sample");
	r := predict(sample.transpose(), mu, sigma, theta);
	r.print("r");
	print("predict house value $%.2f\n", r.a[0]);
}

predict(x, mu, sigma, theta: ndarray): ndarray
{
	xx := np->concatenate(np->ones(x.m, 1) :: x.subtract(mu).divide(sigma) :: nil);
	return xx.dot(theta);
}

normalize(x: ndarray): (ndarray, ndarray, ndarray)
{
	mean := x.mean();
	sigma := x.std();

	return (mean, sigma, x.subtract(mean).divide(sigma));
}

cost(x, y, theta: ndarray): ndarray
{
# J = sum((X * theta - y) .^2) * 1 / (2 * length(X));

	m := x.m;
	scale := 1.0 / (2.0 * real m);

#	t1 := x.dot(theta).subtract(y).apply(2.0, pow);
#	t2 := t1.apply(scale, np->mul);
#	result := t2.sum();

	t1 := x.dot(theta).subtract(y);
	result := t1.transpose().dot(t1).apply(scale, np->mul);
	return result;
}

gradient_descent(x, y, theta: ndarray, alpha: real, niter: int): (ndarray, ndarray)
{
	j_hist := ndarray(niter, niter, 1, array[niter] of real);
	t := array[theta.m] of {* => .0};

	for(i := 0; i < niter; i++){
		for (j := 0; j < theta.m; j++) {
			t[j] = x.col(j, j+1).transpose().dot(x.dot(theta).subtract(y)).sum().a[0];
			t[j] = theta.a[j] - (t[j] / real x.m) * alpha;
		}
		theta.a[0:] = t[:];
		J := cost(x, y, theta);
		j_hist.a[i] = J.a[0];
	}
	return (theta, j_hist);
}