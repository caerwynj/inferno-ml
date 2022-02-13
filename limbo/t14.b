implement Command;
include "cmd.m";

main(argv: list of string)
{
	argv = tl argv;
	if(argv == nil)
		raise "no arg";

	(m, lda, n, a) := np->read_csv(hd argv);
	y := ndarray(m, lda, n, a);
	x := np->range(0, m);

	plot(x, y);
}

plot(x, y: ndarray)
{
	p := plotinit("plot");
	p.pen(GR->CIRCLE);
	p.graph(x.a,y.a);
	p.paint("iteration",nil,"cost",nil);
	p.bye();
}
