implement Command;
include "cmd.m";

# Linear regression with one feature
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
	
	x := nd.col(0, 1);
	y := nd.col(1, 2);

	b := np->ones(x.m, x.n);
	xx := np->concatenate(b :: x :: nil);
	xx.print("xx");

	theta := np->zeros(2, 1);
	j := cost(xx, y, theta);
	j.print("J");  # answer should be 32.07

	theta = ndarray(2, 2, 1, array[] of {-1., 2.});
	j = cost(xx, y, theta);
	j.print("J");  # answer should be 54.24

	(final_theta, j_hist) := gradient_descent(xx, y, theta, 0.01, 1500);

	np->to_csv("j_hist.csv", j_hist);
	final_theta.print("theta");
}

cost(x, y, theta: ndarray): ndarray
{
# J = sum((X * theta - y) .^2) * 1 / (2 * length(X));

	m := x.m;
	scale := 1.0 / (2.0 * real m);

	t1 := x.dot(theta);
	t2 := t1.subtract(y);
	t3 := t2.apply(2.0, pow);
	t4 := t3.apply(scale, np->mul);
	result := t4.sum();
	return result;
}

gradient_descent(x, y, theta: ndarray, alpha: real, niter: int): (ndarray, ndarray)
{
	j_hist := ndarray(niter, niter, 1, array[niter] of real);
	for(i := 0; i < niter; i++){
		t1 := x.col(0, 1).transpose().dot(x.dot(theta).subtract(y)).sum().a[0];
		t1 = theta.a[0] - (t1 / real x.m) * alpha;

		t2 := x.col(1, 2).transpose().dot(x.dot(theta).subtract(y)).sum().a[0];
		t2 = theta.a[1] - (t2 / real x.m) * alpha;

		theta = ndarray(2, 2, 1, array[] of {t1, t2});

		j := cost(x, y, theta);
		j_hist.a[i] = j.a[0];
	}
	return (theta, j_hist);
}