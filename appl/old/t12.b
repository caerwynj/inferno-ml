implement Command;
include "cmd.m";

# Normal equations;  pinv() not implemented!
main(argv: list of string)
{
	argv = tl argv;
	if(argv == nil){
		raise "no arg";
	}

	print("%s\n", hd argv);
	(m, lda, n, a) := np->read_csv(hd argv);
	nd := ndarray(m, lda, n, a);
	nd.print("x");
	
	x := nd.col(0, 2);
	y := nd.col(2, 3);

	b := np->ones(x.m, 1);
	x = np->concatenate(b :: normx :: nil);

	xt = x.transpose();
	theta := xt.dot(x).pinv().dot(xt).dot(y);

	theta.print("theta");
}
