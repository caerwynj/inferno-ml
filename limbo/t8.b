implement Command;
include "cmd.m";

main(argv: list of string)
{
	argv = tl argv;
	r := np->randn(4,4);
	r.print("r");

	r = r.transpose();
	r.print("r'");

	np->to_csv("test.csv", r);
}
