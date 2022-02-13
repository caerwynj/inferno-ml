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
	
}

find(nd: ndarray, val: real): ndarray
{
# return a boolean array

}
