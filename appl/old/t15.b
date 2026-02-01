implement Command;
include "cmd.m";

# Bug on Ubuntu AMD64 running in 386/ubuntu docker container.
main(nil: list of string)
{
#	print("%s\n", hd argv);
#	(m, lda, n, a) := np->read_csv(hd argv);
#	nd := ndarray(m, lda, n, a);
#	nd.print("nd");
	s := "49.07256321908844";

	(r, nil) := toreal(s, 10);

	sprint("%f\n", r);
}

