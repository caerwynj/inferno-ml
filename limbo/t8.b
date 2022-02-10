implement Command;
include "cmd.m";

include "ndarray.m";
np: Ndarray;
ndarray: import np;

main(argv: list of string)
{
	np = load Ndarray Ndarray->PATH;
	np->init(nil,nil);

	r := np->randn(3,2);
	r.print("r");

	r = r.transpose();
	r.print("r'");

	np->to_csv("test.csv", r);
}
